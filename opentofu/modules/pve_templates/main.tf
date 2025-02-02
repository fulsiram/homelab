terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

resource "proxmox_virtual_environment_download_file" "debian_12_disk" {
  url          = "http://cdimage.debian.org/images/cloud/bookworm/20250115-1993/debian-12-generic-amd64-20250115-1993.qcow2"
  verify       = false
  datastore_id = var.image_datastore_id
  node_name    = var.proxmox_node_name
  content_type = "iso"
  file_name    = "debian-12-generic-amd64-20250115-1993.img"
}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  datastore_id = var.vm_datastore_id
  content_type = "snippets"
  node_name    = var.proxmox_node_name

  source_raw {
    data = <<-EOF
      #cloud-config
      users:
        - default
        - name: admin
          groups:
            - sudo
          shell: /bin/bash
          ssh_authorized_keys:
            - ${var.ssh_public_key}
          sudo: ALL=(ALL) NOPASSWD:ALL
      timezone: ${var.timezone}
      runcmd:
        - apt update
        - apt install -y qemu-guest-agent net-tools
        - systemctl enable qemu-guest-agent
        - systemctl start qemu-guest-agent
    EOF

    file_name = "user-data-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "debian_12_template" {
  name      = "debian-12-template"
  node_name = var.proxmox_node_name
  vm_id     = 9000

  template = true

  tags = []

  agent {
    enabled = true
  }

  cpu {
    type  = "x86-64-v2-AES"
    cores = 1
  }

  memory {
    dedicated = 1024
  }

  bios    = "ovmf"
  machine = "q35"

  disk {
    datastore_id = var.vm_datastore_id
    file_id      = proxmox_virtual_environment_download_file.debian_12_disk.id
    file_format  = "qcow2"
    interface    = "virtio0"
    size         = 10
    iothread     = true
  }

  efi_disk {
    datastore_id = var.vm_datastore_id
    type         = "4m"
  }

  tpm_state {
    datastore_id = var.vm_datastore_id
  }

  initialization {
    datastore_id = var.vm_datastore_id
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  }

  serial_device {}

  network_device {
    bridge      = "vmbr0"
    mac_address = ""
  }
}

output "debian_12_disk_id" {
  value = proxmox_virtual_environment_download_file.debian_12_disk.id
}

output "user_data_cloud_config_id" {
  value = proxmox_virtual_environment_file.user_data_cloud_config.id
}

output "debian_12_template_id" {
  value = proxmox_virtual_environment_vm.debian_12_template.id
}
