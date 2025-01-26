variable "proxmox_node_name" {
  type        = string
  description = "The name of the node to create the VM on"
}

variable "vm_datastore_id" {
  type        = string
  description = "The ID of the datastore to store the VM in"
}

variable "image_file_id" {
  type        = string
  description = "The ID of the image file to use for the VM"
}

variable "ssh_public_key" {
  type        = string
  description = "The public key to use for the cloud-init"
}

variable "timezone" {
  type        = string
  description = "The timezone to use for the VM"
  default     = "America/Toronto"
}

variable "name" {
  type        = string
  description = "The name to use for the VM"
}

variable "fqdn" {
  type        = string
  description = "The FQDN to use for the VM"
}

variable "runcmd" {
  type        = list(string)
  description = "The commands to run in cloud-init"
  default     = []
}

variable "network_mac_address" {
  type        = string
  description = "The MAC address to use for the VM's network interface"
  default     = ""
}

variable "disk_size_gb" {
  type        = number
  description = "The size of the VM's disk in GB"
  default     = 10
}

variable "cpu_cores" {
  type        = number
  description = "The number of CPU cores to use for the VM"
  default     = 2
}

variable "memory_mb" {
  type        = number
  description = "The amount of memory to use for the VM in MB"
  default     = 4096
}

variable "vm_id" {
  type        = number
  description = "The ID to use for the VM"
  default     = null
}
