resource "random_password" "vaultwarden_db_password" {
  length           = 32
  special          = true
  override_special = ".!$%&*()-_+[]{}<>:;?@"
}

resource "vault_kv_secret_v2" "secret_key" {
  mount = var.vault_mount
  name  = "vaultwarden/secret_key"
  data_json = jsonencode({
    secret_key = random_password.vaultwarden_db_password.result
  })
}

resource "vault_kv_secret_v2" "db_credentials" {
  mount = var.vault_mount
  name  = "vaultwarden/db_credentials"
  data_json = jsonencode({
    database = postgresql_database.vaultwarden.name
    user     = postgresql_role.vaultwarden.name
    password = random_password.vaultwarden_db_password.result
  })
}

resource "postgresql_role" "vaultwarden" {
  name     = "vaultwarden"
  login    = true
  password = random_password.vaultwarden_db_password.result
}

resource "postgresql_database" "vaultwarden" {
  name  = "vaultwarden"
  owner = postgresql_role.vaultwarden.name
}
