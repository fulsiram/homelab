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
    agent       = true
    username    = "root"
    private_key = data.local_file.ssh_private_key.content
  }
}

module "pve_templates" {
  source = "./modules/pve_templates"

  proxmox_node_name  = var.proxmox_node_name
  vm_datastore_id    = var.vm_datastore_id
  image_datastore_id = var.image_datastore_id
  ssh_public_key     = data.local_file.ssh_public_key.content
  timezone           = var.timezone
}

module "pihole" {
  source = "./modules/complete_vm"

  image_file_id       = module.pve_templates.debian_12_disk_id
  vm_datastore_id     = var.vm_datastore_id
  proxmox_node_name   = var.proxmox_node_name

  name                = "pihole"
  fqdn                = "pihole.${var.domain}"
  network_mac_address = "BC:24:11:16:6B:33"
  cpu_cores           = 2
  memory_mb           = 4096
  disk_size_gb        = 20
  ssh_public_key      = data.local_file.ssh_public_key.content
}

module "vault" {
  source = "./modules/complete_vm"

  image_file_id       = module.pve_templates.debian_12_disk_id
  vm_datastore_id     = var.vm_datastore_id
  proxmox_node_name   = var.proxmox_node_name

  name                = "vault"
  fqdn                = "vault.${var.domain}"
  cpu_cores           = 2
  memory_mb           = 4096
  disk_size_gb        = 20
  ssh_public_key      = data.local_file.ssh_public_key.content
}

output "pihole_ip" {
  value = module.pihole.ip_address
}

output "vault_ip" {
  value = module.vault.ip_address
}
