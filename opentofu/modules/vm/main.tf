terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

resource "proxmox_virtual_environment_file" "metadata_cloud_config" {
  content_type = "snippets"
  datastore_id = var.vm_datastore_id
  node_name    = var.proxmox_node_name

  source_raw {
    data = <<-EOF
      #cloud-config
      local-hostname: ${var.name}
      fqdn: ${var.fqdn}
      prefer_fqdn_over_hostname: true
    EOF

    file_name = "${var.name}-metadata-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  name      = var.name
  node_name = var.proxmox_node_name

  tags = []

  cpu {
    type  = var.cpu_type
    cores = var.cpu_cores
  }

  memory {
    dedicated = var.memory_mb
  }

  network_device {
    bridge      = var.network_bridge
    mac_address = var.network_mac_address
  }

  initialization {
    user_data_file_id = var.user_data_file_id
    meta_data_file_id = proxmox_virtual_environment_file.metadata_cloud_config.id
  }

  clone {
    vm_id = var.base_vm_id
  }
}
