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
