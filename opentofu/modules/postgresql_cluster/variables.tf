variable "cluster_name" {
  type        = string
  description = "The name of the PostgreSQL cluster"
}

variable "domain" {
  type        = string
  description = "The domain to use for the PostgreSQL cluster"
}

variable "ssh_public_key" {
  type        = string
  description = "The SSH public key to use for the PostgreSQL cluster"
}

variable "proxmox_node_name" {
  type        = string
  description = "The Proxmox node name to use for the PostgreSQL cluster"
}

variable "image_file_id" {
  type        = string
  description = "The image file ID to use for the PostgreSQL cluster"
}

variable "primary" {
  type = object({
    cpu_cores    = number
    memory_mb    = number
    disk_size_gb = number
    datastore_id = string
    mac_address  = string
  })
  description = "The primary node configuration"
}

variable "replicas" {
  type = map(object({
    cpu_cores         = number
    memory_mb         = number
    disk_size_gb      = number
    datastore_id      = string
    proxmox_node_name = string
    mac_address       = string
  }))
  description = "The replica nodes configuration"

  default = {}
}

variable "vault_mount" {
  type        = string
  description = "The Vault mount to use for the PostgreSQL cluster"
}
