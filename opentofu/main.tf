terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }

    postgresql = {
      source = "cyrilgdn/postgresql"
    }

    vault = {
      source = "hashicorp/vault"
    }
  }
}

provider "vault" {
  address = var.vault_address
  token   = var.vault_token
  skip_tls_verify = var.vault_insecure
}

import {
  to = vault_mount.kvv2
  id = "kv"
}

resource "vault_mount" "kvv2" {
  path        = "kv"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
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


module "postgresql_cluster" {
  source = "./modules/postgresql_cluster"

  vault_mount = vault_mount.kvv2.path

  proxmox_node_name = var.proxmox_node_name
  image_file_id     = module.pve_templates.debian_12_disk_id

  cluster_name   = "postgresql"
  domain         = var.domain
  ssh_public_key = data.local_file.ssh_public_key.content

  primary = {
    cpu_cores    = 2
    memory_mb    = 4096
    disk_size_gb = 20
    datastore_id = var.vm_datastore_id
  }
}

provider "postgresql" {
  host     = module.postgresql_cluster.primary_ip
  port     = 5432
  username = "terraform"
  password = module.postgresql_cluster.terraform_password
}

module "adguard" {
  source = "./modules/complete_vm"

  image_file_id     = module.pve_templates.debian_12_disk_id
  vm_datastore_id   = var.vm_datastore_id
  proxmox_node_name = var.proxmox_node_name

  name                = "adguard"
  fqdn                = "adguard.${var.domain}"
  network_mac_address = "BC:24:11:16:6B:33"
  cpu_cores           = 2
  memory_mb           = 4096
  disk_size_gb        = 10
  ssh_public_key      = data.local_file.ssh_public_key.content
}

module "vault" {
  source = "./modules/complete_vm"

  image_file_id     = module.pve_templates.debian_12_disk_id
  vm_datastore_id   = var.vm_datastore_id
  proxmox_node_name = var.proxmox_node_name

  name           = "vault"
  fqdn           = "vault.${var.domain}"
  cpu_cores      = 2
  memory_mb      = 4096
  disk_size_gb   = 20
  ssh_public_key = data.local_file.ssh_public_key.content
}

module "edge" {
  source = "./modules/complete_vm"

  image_file_id     = module.pve_templates.debian_12_disk_id
  vm_datastore_id   = var.vm_datastore_id
  proxmox_node_name = var.proxmox_node_name

  name           = "edge"
  fqdn           = "edge.${var.domain}"
  cpu_cores      = 2
  memory_mb      = 4096
  disk_size_gb   = 10
  ssh_public_key = data.local_file.ssh_public_key.content
}

module "authentik" {
  source = "./modules/complete_vm"

  image_file_id     = module.pve_templates.debian_12_disk_id
  vm_datastore_id   = var.vm_datastore_id
  proxmox_node_name = var.proxmox_node_name

  name           = "auth"
  fqdn           = "auth.${var.domain}"
  cpu_cores      = 2
  memory_mb      = 4096
  disk_size_gb   = 10
  ssh_public_key = data.local_file.ssh_public_key.content
}


output "adguard_ip" {
  value = module.adguard.ip_address
}

output "vault_ip" {
  value = module.vault.ip_address
}
