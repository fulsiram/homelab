data "local_file" "ssh_private_key" {
  filename = pathexpand(var.ssh_private_key_path)
}

data "local_file" "ssh_public_key" {
  filename = pathexpand(var.ssh_public_key_path)
}
