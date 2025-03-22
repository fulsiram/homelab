variable "proxmox_node_name" {
  type        = string
  description = "The name of the node to create resources on"
}

variable "vm_datastore_id" {
  type        = string
  description = "The ID of the datastore to store VM data in"
}

variable "image_datastore_id" {
  type        = string
  description = "The ID of the datastore to store images in"
}

variable "ssh_public_key_path" {
  type        = string
  description = "The path to the public key to use for cloud-init"
}

variable "ssh_private_key_path" {
  type        = string
  description = "The path to the private key to use for SSH"
}

variable "timezone" {
  type        = string
  description = "The timezone to use for the VM"
  default     = "America/Toronto"
}
