variable "name" {
  type        = string
  description = "The name of the VM"
}

variable "fqdn" {
  type        = string
  description = "The FQDN of the VM"
}

variable "proxmox_node_name" {
  type        = string
  description = "The name of the Proxmox node to create the VM on"
}

variable "user_data_file_id" {
  type        = string
  description = "The ID of the user data file to use for the VM"
}

variable "vm_datastore_id" {
  type        = string
  description = "The ID of the datastore to store VM data in"
}

variable "cpu_type" {
  type        = string
  description = "The type of CPU to use for the VM"
  default     = "x86-64-v2-AES"
}

variable "cpu_cores" {
  type        = number
  description = "The number of cores to use for the VM"
  default     = 2
}

variable "memory_mb" {
  type        = number
  description = "The amount of memory to use for the VM"
  default     = 4096
}

variable "disk_size_gb" {
  type        = number
  description = "The size of the disk to use for the VM"
  default     = 10
}

variable "network_bridge" {
  type        = string
  description = "The bridge to use for the VM"
  default     = "vmbr0"
}

variable "network_mac_address" {
  type        = string
  description = "The MAC address to use for the VM"
  default     = ""
}

variable "base_vm_id" {
  type        = number
  description = "The ID of the base VM to use for the VM"
}
