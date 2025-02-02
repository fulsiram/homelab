variable "proxmox_node_name" {
  type        = string
  description = "The name of the node to create resources on"
}

variable "domain" {
  type        = string
  description = "The base domain for the VMs"
}

variable "vm_datastore_id" {
  type        = string
  description = "The ID of the datastore to store VM data in"
}

variable "image_file_id" {
  type        = string
  description = "The ID of the image file to use for the VM"
}

variable "ssh_public_key" {
  type        = string
  description = "The public key to use for the VM"
}
