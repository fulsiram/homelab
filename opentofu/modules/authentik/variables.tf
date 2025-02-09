variable "domain" {
  type        = string
  description = "The domain name to use for the authentik server"
}

variable "ssh_public_key" {
  type        = string
  description = "The SSH public key to use for the authentik server"
}

variable "datastore_id" {
  type        = string
  description = "The datastore ID to use for the authentik server"
}

variable "proxmox_node_name" {
  type        = string
  description = "The Proxmox node name to use for the authentik server"
}

variable "image_file_id" {
  type        = string
  description = "The image file ID to use for the authentik server"
}

variable "vault_mount" {
  type        = string
  description = "The Vault mount to use for the authentik server"
}
