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
  address         = var.vault_address
  token           = var.vault_token
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
    mac_address  = "bc:24:11:3d:a7:60"
  }

  replicas = {
    "replica-1" = {
      cpu_cores         = 2
      memory_mb         = 4096
      disk_size_gb      = 20
      datastore_id      = var.vm_datastore_id
      proxmox_node_name = var.proxmox_node_name
      mac_address       = "bc:24:11:3d:a7:61"
    },
    "replica-2" = {
      cpu_cores         = 2
      memory_mb         = 4096
      disk_size_gb      = 20
      datastore_id      = "local"
      proxmox_node_name = var.proxmox_node_name
      mac_address       = "bc:24:11:3d:a7:62"
    }
  }
}

provider "postgresql" {
  host      = "10.88.111.18"
  port      = 5432
  username  = "terraform"
  password  = module.postgresql_cluster.terraform_password
  superuser = true
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
  source = "./modules/vault"

  vault_mount       = vault_mount.kvv2.path
  domain            = var.domain
  proxmox_node_name = var.proxmox_node_name
  datastore_id      = var.vm_datastore_id
  ssh_public_key    = data.local_file.ssh_public_key.content
  image_file_id     = module.pve_templates.debian_12_disk_id
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

module "public_edge" {
  source = "./modules/complete_vm"

  image_file_id     = module.pve_templates.debian_12_disk_id
  vm_datastore_id   = var.vm_datastore_id
  proxmox_node_name = var.proxmox_node_name

  name           = "public-edge"
  fqdn           = "public-edge.${var.domain}"
  cpu_cores      = 2
  memory_mb      = 4096
  disk_size_gb   = 10
  ssh_public_key = data.local_file.ssh_public_key.content
}

module "authentik" {
  source     = "./modules/authentik"
  depends_on = [module.postgresql_cluster]

  vault_mount       = vault_mount.kvv2.path
  domain            = var.domain
  proxmox_node_name = var.proxmox_node_name
  datastore_id      = var.vm_datastore_id
  ssh_public_key    = data.local_file.ssh_public_key.content
  image_file_id     = module.pve_templates.debian_12_disk_id
}

output "adguard_ip" {
  value = module.adguard.ip_address
}

output "postgres_ip" {
  value = module.postgresql_cluster.primary_ip
}

output "vault_ip" {
  value = module.vault.ip_address
}
