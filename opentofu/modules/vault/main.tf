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


module "vm" {
  source = "../complete_vm"

  vm_datastore_id   = var.datastore_id
  proxmox_node_name = var.proxmox_node_name
  image_file_id     = var.image_file_id

  name = "vault"
  fqdn = "vault.${var.domain}"

  cpu_cores = 2
  memory_mb = 4096

  ssh_public_key = var.ssh_public_key
}
