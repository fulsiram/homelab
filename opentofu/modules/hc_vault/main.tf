# OpenBao is open source HashiCorp Vault.

module "vm" {
  source = "../complete_vm"

  proxmox_node_name = var.proxmox_node_name
  vm_datastore_id = var.vm_datastore_id
  image_file_id = var.image_file_id

  name = "openbao"
  fqdn = "openbao.${var.domain}"

  cpu_cores = 2
  memory_mb = 4096
  disk_size_gb = 20

  ssh_public_key = var.ssh_public_key

  runcmd = split("\n", <<-EOT
    apt-get update
    apt-get install -y curl ca-certificates gnupg
    wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    apt-get update
    apt-get install -y vault
    mkdir -p /etc/vault
    cat > /etc/vault/config.hcl <<-EOF
    ui            = true
    cluster_addr  = "http://0.0.0.0:8201"
    api_addr      = "http://0.0.0.0:8200"
    disable_mlock = true

    storage "raft" {
      path = "/var/lib/vault/data"
      node_id = "raft_node_1"
    }

    listener "tcp" {
      address       = "0.0.0.0:8200"
      tls_disable   = true
    }
    EOF
    mkdir -p /var/lib/vault/data
    chown -R vault:vault /var/lib/vault
    systemctl enable vault
    systemctl start vault
  EOT
  )
}

output "vault_address" {
  value = "http://${module.vm.fqdn}:8200"
}
