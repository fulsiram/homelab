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

resource "random_password" "db_password" {
  length  = 32
  special = true
}

resource "vault_kv_secret_v2" "db_password" {
  mount = var.vault_mount
  name  = "authentik/db_password"
  data_json = jsonencode({
    password = random_password.db_password.result
  })
}

resource "postgresql_role" "authentik" {
  name     = "authentik"
  login    = true
  password = random_password.db_password.result
}

resource "postgresql_database" "authentik" {
  name  = "authentik"
  owner = postgresql_role.authentik.name
}

module "vm" {
  source = "../complete_vm"

  vm_datastore_id   = var.datastore_id
  proxmox_node_name = var.proxmox_node_name
  image_file_id     = var.image_file_id

  name = "auth"
  fqdn = "auth.${var.domain}"

  cpu_cores = 2
  memory_mb = 4096

  ssh_public_key = var.ssh_public_key
}
