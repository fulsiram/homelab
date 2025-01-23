variable "proxmox_node_name" {
  type        = string
  description = "The name of the node to create templates on"
}

variable "vm_datastore_id" {
  type        = string
  description = "The ID of the datastore to store VM data in"
}

variable "image_datastore_id" {
  type        = string
  description = "The ID of the datastore to store images in"
}

variable "ssh_public_key" {
  type        = string
  description = "The public key to use for cloud-init"
}

variable "timezone" {
  type        = string
  description = "The timezone to use for the VM"
  default     = "America/Toronto"
}
