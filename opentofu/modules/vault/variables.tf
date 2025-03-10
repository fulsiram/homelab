variable "vault_mount" {
  type        = string
  description = "The mount point for the Vault instance"
}

variable "domain" {
  type        = string
  description = "The domain name for the Vault instance"
}

variable "ssh_public_key" {
  type        = string
  description = "The public key for the Vault instance"
}

variable "datastore_id" {
  type        = string
  description = "The datastore ID for the Vault instance"
}

variable "proxmox_node_name" {
  type        = string
  description = "The proxmox node name for the Vault instance"
}

variable "image_file_id" {
  type        = string
  description = "The image file ID for the Vault instance"
}
