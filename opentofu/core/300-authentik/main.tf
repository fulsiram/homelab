terraform {
  required_providers {
    postgresql = {
      source = "cyrilgdn/postgresql"
    }

    vault = {
      source = "hashicorp/vault"
    }
  }
}

resource "random_password" "postgres_password" {
  length = 64
  special = false
}

resource "postgresql_role" "authentik" {
  name     = "authentik"
  login    = true
  password = random_password.postgres_password.result
}

resource "postgresql_database" "authentik" {
  name  = "authentik"
  owner = postgresql_role.authentik.name
}

resource "vault_kv_secret_v2" "postgres" {
  mount = data.terraform_remote_state.vault_engines.outputs.kvv2_path
  name  = "core/authentik/postgres"

  data_json = jsonencode({
    host = data.vault_kv_secret_v2.database_primary.data.host
    username = postgresql_role.authentik.name
    password = random_password.postgres_password.result
    database = postgresql_database.authentik.name
  })
}

resource "random_password" "secret_key" {
  length           = 64
  special          = false
}

resource "vault_kv_secret_v2" "secret_key" {
  mount = data.terraform_remote_state.vault_engines.outputs.kvv2_path
  name  = "core/authentik/secret_key"
  data_json = jsonencode({
    secret_key = random_password.secret_key.result
  })
}

data "local_file" "ssh_public_key" {
  filename = pathexpand(var.ssh_public_key_path)
}

data "terraform_remote_state" "vm_templates" {
  backend = "local"
  config = {
    path = "../../states/core/vm-templates.tfstate"
  }
}

module "vm" {
  source = "../../modules/complete_vm"

  vm_datastore_id   = var.vm_datastore_id
  proxmox_node_name = var.proxmox_node_name
  image_file_id     = data.terraform_remote_state.vm_templates.outputs.debian_12_disk_id

  name = "auth"
  fqdn = "auth.${var.domain}"

  cpu_cores = 2
  memory_mb = 4096

  ssh_public_key = data.local_file.ssh_public_key.content

  network_mac_address = "bc:24:11:0b:2a:cd"
}
