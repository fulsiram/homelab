data "local_file" "ssh_private_key" {
  filename = pathexpand(var.ssh_private_key_path)
}

data "local_file" "ssh_public_key" {
  filename = pathexpand(var.ssh_public_key_path)
}

data "vault_kv_secret_v2" "postgresql_password" {
  mount = vault_mount.kvv2.path
  name  = "postgresql/terraform_password"
  depends_on = [
    module.postgresql_cluster
  ]
}
