terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

provider "proxmox" {
  endpoint  = "https://${var.proxmox_api_host}/api2/json"
  api_token = var.proxmox_api_token
  insecure  = var.proxmox_api_insecure
  ssh {
    agent = true
    username = "root"
    private_key = data.local_file.ssh_private_key.content
  }
}

module "pve_templates" {
  source = "./modules/pve_templates"

  proxmox_node_name = var.proxmox_node_name
  vm_datastore_id = var.vm_datastore_id
  image_datastore_id = var.image_datastore_id
  ssh_public_key = data.local_file.ssh_public_key.content
  timezone = var.timezone
}
