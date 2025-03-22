terraform {
  backend "local" {
    path = "../../states/core/postgres-cluster.tfstate"
  }
}

data "terraform_remote_state" "vm_templates" {
  backend = "local"
  config = {
    path = "../../states/core/vm-templates.tfstate"
  }
}

data "terraform_remote_state" "vault_engines" {
  backend = "local"
  config = {
    path = "../../states/core/vault-engines.tfstate"
  }
}

data "local_file" "ssh_public_key" {
  filename = pathexpand(var.ssh_public_key_path)
}

resource "random_password" "postgres" {
  length  = 64
  special = false
}

resource "vault_kv_secret_v2" "postgres" {
  mount = data.terraform_remote_state.vault_engines.outputs.kvv2_path
  name  = "${data.terraform_remote_state.vault_engines.outputs.base_core_path}/postgres/credentials/postgres"

  data_json = jsonencode({
    username = "postgres"
    password = random_password.postgres.result
  })
}

resource "random_password" "postgres_replication" {
  length  = 64
  special = false
}

resource "vault_kv_secret_v2" "postgres_replication" {
  mount = data.terraform_remote_state.vault_engines.outputs.kvv2_path
  name  = "${data.terraform_remote_state.vault_engines.outputs.base_core_path}/postgres/credentials/replicator"

  data_json = jsonencode({
    username = "replicator"
    password = random_password.postgres_replication.result
  })
}

resource "random_password" "terraform" {
  length  = 64
  special = false
}

resource "vault_kv_secret_v2" "terraform" {
  mount = data.terraform_remote_state.vault_engines.outputs.kvv2_path
  name  = "${data.terraform_remote_state.vault_engines.outputs.base_core_path}/postgres/credentials/terraform"

  data_json = jsonencode({
    username = "terraform"
    password = random_password.terraform.result
  })
}

module "primary" {
  source = "../../modules/complete_vm"

  proxmox_node_name = var.proxmox_node_name
  vm_datastore_id   = var.vm_datastore_id
  image_file_id     = data.terraform_remote_state.vm_templates.outputs.debian_12_disk_id

  name = "postgres-primary"
  fqdn = "postgres-primary.${var.domain}"

  cpu_cores    = 2
  memory_mb    = 4096
  disk_size_gb = 20

  ssh_public_key = data.local_file.ssh_public_key.content
}

module "replica-1" {
  source = "../../modules/complete_vm"

  proxmox_node_name = var.proxmox_node_name
  vm_datastore_id   = var.vm_datastore_id
  image_file_id     = data.terraform_remote_state.vm_templates.outputs.debian_12_disk_id

  name = "postgres-replica-1"
  fqdn = "postgres-replica-1.${var.domain}"

  cpu_cores    = 2
  memory_mb    = 4096
  disk_size_gb = 20

  ssh_public_key = data.local_file.ssh_public_key.content
}

module "replica-2" {
  source = "../../modules/complete_vm"

  proxmox_node_name = var.proxmox_node_name
  vm_datastore_id   = var.backup_vm_datastore_id
  image_file_id     = data.terraform_remote_state.vm_templates.outputs.debian_12_disk_id

  name = "postgres-replica-2"
  fqdn = "postgres-replica-2.${var.domain}"

  cpu_cores    = 2
  memory_mb    = 4096
  disk_size_gb = 20

  ssh_public_key = data.local_file.ssh_public_key.content
}

resource "vault_kv_secret_v2" "primary_host" {
  mount = data.terraform_remote_state.vault_engines.outputs.kvv2_path
  name  = "${data.terraform_remote_state.vault_engines.outputs.base_core_path}/postgres/primary"

  data_json = jsonencode({
    host = module.primary.ip_address
  })
}

output "primary-ip" {
  value = module.primary.ip_address
}
