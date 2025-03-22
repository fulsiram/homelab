terraform {
  backend "local" {
    path = "../../states/core/vault-engines.tfstate"
  }

  required_providers {
    vault = {
      source = "hashicorp/vault"
    }
  }
}

resource "vault_mount" "kvv2" {
  path        = "kv"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

output "kvv2_path" {
  value = vault_mount.kvv2.path
}

output "base_core_path" {
  value = "core/"
}

output "base_app_path" {
  value = "app/"
}
