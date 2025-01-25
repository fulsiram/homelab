terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
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
      hostname: ${var.name}
      fqdn: ${var.fqdn}

      network:
        version: 2
        ethernets:
          eth0:
            dhcp4: true

      runcmd:
        - apt update
        - apt install -y qemu-guest-agent net-tools
        - systemctl enable qemu-guest-agent
        - systemctl start qemu-guest-agent
    EOF

    file_name = "${var.name}-user-data-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "debian_12_vm" {
  name      = var.name
  node_name = var.proxmox_node_name

  tags = []

  agent {
    enabled = true
  }

  cpu {
    type  = "x86-64-v2-AES"
    cores = var.cpu_cores
  }

  memory {
    dedicated = var.memory_mb
  }

  bios    = "ovmf"
  machine = "q35"

  disk {
    datastore_id = var.vm_datastore_id
    file_id      = var.image_file_id
    file_format  = "qcow2"
    interface    = "virtio0"
    size         = var.disk_size_gb
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
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    datastore_id = var.vm_datastore_id
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  }

  serial_device {}

  network_device {
    bridge      = "vmbr0"
    mac_address = var.network_mac_address
  }
}

output "ip_address" {
  value = proxmox_virtual_environment_vm.debian_12_vm.ipv4_addresses[1][0]
}
