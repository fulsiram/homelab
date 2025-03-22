data "terraform_remote_state" "vm_templates" {
  backend = "local"
  config = {
    path = "../../states/core/vm-templates.tfstate"
  }
}

data "local_file" "ssh_public_key" {
  filename = pathexpand(var.ssh_public_key_path)
}

module "edge" {
  source = "../../modules/complete_vm"

  proxmox_node_name = var.proxmox_node_name
  vm_datastore_id   = var.vm_datastore_id
  image_file_id     = data.terraform_remote_state.vm_templates.outputs.debian_12_disk_id

  name = "edge"
  fqdn = "edge.${var.domain}"

  cpu_cores    = 2
  memory_mb    = 4096
  disk_size_gb = 20

  ssh_public_key = data.local_file.ssh_public_key.content
}

module "public_edge" {
  source = "../../modules/complete_vm"

  proxmox_node_name = var.proxmox_node_name
  vm_datastore_id   = var.vm_datastore_id
  image_file_id     = data.terraform_remote_state.vm_templates.outputs.debian_12_disk_id

  name = "public-edge"
  fqdn = "public-edge.${var.domain}"

  cpu_cores    = 2
  memory_mb    = 4096
  disk_size_gb = 20

  ssh_public_key = data.local_file.ssh_public_key.content
}
