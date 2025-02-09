variable "proxmox_api_host" {
  type        = string
  description = "Proxmox API host"
}

variable "proxmox_api_token" {
  type        = string
  description = "Proxmox API token"
}

variable "proxmox_api_insecure" {
  type        = bool
  description = "Whether to skip TLS verification of the Proxmox API"
  default     = false
}

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

variable "vault_token" {
  type        = string
  description = "The Hashicorp Vault token"
  sensitive   = true
}

variable "vault_address" {
  type        = string
  description = "The Hashicorp Vault address"
}

variable "vault_insecure" {
  type        = bool
  description = "Whether to skip TLS verification of the Vault API"
  default     = false
}
