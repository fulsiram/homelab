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
    username = "root"
  }
}
