resource "random_password" "postgres_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "terraform_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "vault_kv_secret_v2" "postgres_password" {
  mount = var.vault_mount
  name  = "postgresql/postgres_password"
  data_json = jsonencode({
    password = random_password.postgres_password.result
  })
}

resource "vault_kv_secret_v2" "terraform_password" {
  mount = var.vault_mount
  name  = "postgresql/terraform_password"
  data_json = jsonencode({
    password = random_password.terraform_password.result
  })
}

module "primary" {
  source = "../complete_vm"

  vm_datastore_id   = var.primary.datastore_id
  proxmox_node_name = var.proxmox_node_name
  image_file_id     = var.image_file_id

  name = "${var.cluster_name}-primary"
  fqdn = "${var.cluster_name}-primary.${var.domain}"

  cpu_cores    = var.primary.cpu_cores
  memory_mb    = var.primary.memory_mb
  disk_size_gb = var.primary.disk_size_gb

  ssh_public_key = var.ssh_public_key

  runcmd = [
    "apt-get update",
    "apt-get install -y curl ca-certificates",
    "install -d /usr/share/postgresql-common/pgdg",
    "curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc",
    "sh -c 'echo \"deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main\" > /etc/apt/sources.list.d/pgdg.list'",
    "apt-get update",
    "apt-get install -y postgresql-16",
    "systemctl enable postgresql",
    "systemctl start postgresql",
    "echo \"listen_addresses = '*'\" >> /etc/postgresql/16/main/postgresql.conf",
    "echo 'host all all 10.88.111.0/24 scram-sha-256' >> /etc/postgresql/16/main/pg_hba.conf",
    "systemctl restart postgresql",
    "su postgres -c \"psql -c \\\"ALTER USER postgres WITH PASSWORD '${random_password.postgres_password.result}';\\\"\"",
    "su postgres -c \"psql -c \\\"CREATE USER terraform WITH PASSWORD '${random_password.terraform_password.result}';\\\"\"",
    "su postgres -c \"psql -c \\\"ALTER USER terraform WITH SUPERUSER;\\\"\""
  ]
}

output "terraform_password" {
  value = random_password.terraform_password.result
}

output "postgres_password" {
  value = random_password.postgres_password.result
}

output "primary_ip" {
  value = module.primary.ip_address
}
