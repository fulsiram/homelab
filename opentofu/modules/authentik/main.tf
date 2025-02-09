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
  override_special = ".!$%&*()-_+[]{}<>:;?@"
}

resource "random_password" "secret_key" {
  length  = 64
  special = true
  override_special = ".!$%&*()-_+[]{}<>:;?@"
}

resource "vault_kv_secret_v2" "secret_key" {
  mount = var.vault_mount
  name  = "authentik/secret_key"
  data_json = jsonencode({
    secret_key = random_password.secret_key.result
  })
}

resource "vault_kv_secret_v2" "db_credentials" {
  mount = var.vault_mount
  name  = "authentik/pg_credentials"
  data_json = jsonencode({
    database = postgresql_database.authentik.name
    user     = postgresql_role.authentik.name
    password = random_password.db_password.result
  })
}

resource "postgresql_role" "authentik" {
  name     = "authentik"
  login    = true
  password = random_password.db_password.result
}

resource "postgresql_database" "authentik" {
  name = "authentik"
  owner = postgresql_role.authentik.name
}

module "vm" {
  source = "../complete_vm"

  vm_datastore_id   = var.datastore_id
  proxmox_node_name = var.proxmox_node_name
  image_file_id     = var.image_file_id

  name = "auth"
  fqdn = "auth.${var.domain}"

  cpu_cores    = 2
  memory_mb    = 4096

  ssh_public_key = var.ssh_public_key

  network_mac_address = "bc:24:11:0b:2a:cd"
}
