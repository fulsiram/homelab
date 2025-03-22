data "terraform_remote_state" "vault_engines" {
  backend = "local"
  config = {
    path = "../../states/core/vault-engines.tfstate"
  }
}

data "vault_kv_secret_v2" "database_primary" {
  mount = data.terraform_remote_state.vault_engines.outputs.kvv2_path
  name = "core/postgres/primary"
}

data "vault_kv_secret_v2" "database_credentials" {
  mount = data.terraform_remote_state.vault_engines.outputs.kvv2_path
  name = "core/postgres/credentials/terraform"
}

provider "postgresql" {
  superuser = true
  host = data.vault_kv_secret_v2.database_primary.data.host
  username = data.vault_kv_secret_v2.database_credentials.data.username
  password = data.vault_kv_secret_v2.database_credentials.data.password
}
