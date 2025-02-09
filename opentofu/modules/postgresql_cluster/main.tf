terraform {
  required_providers {
    postgresql = {
      source = "cyrilgdn/postgresql"
    }

    vault = {
      source = "hashicorp/vault"
    }
  }
}

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

resource "vault_kv_secret_v2" "primary_host" {
  mount = var.vault_mount
  name  = "postgresql/primary/host"
  data_json = jsonencode({
    host     = module.primary.ip_address
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
  network_mac_address = var.primary.mac_address

  ssh_public_key = var.ssh_public_key

  runcmd = split("\n", <<-EOT
    apt-get update
    apt-get install -y curl ca-certificates
    install -d /usr/share/postgresql-common/pgdg
    curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
    sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    apt-get update
    apt-get install -y postgresql-16

    systemctl enable postgresql
    systemctl start postgresql

    cat >> /etc/postgresql/16/main/postgresql.conf <<-EOF
    listen_addresses = '*'
    wal_level = 'replica'
    synchronous_commit = local
    max_wal_senders = 10
    max_replication_slots = 10
    wal_keep_size = 512MB
    hot_standby = on
    hot_standby_feedback = on
    EOF

    echo 'host all all 10.88.111.0/24 scram-sha-256' >> /etc/postgresql/16/main/pg_hba.conf
    echo 'host replication replicator 10.88.111.0/24 scram-sha-256' >> /etc/postgresql/16/main/pg_hba.conf

    systemctl restart postgresql

    su postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD '${random_password.postgres_password.result}';\""
    su postgres -c "psql -c \"CREATE USER terraform WITH PASSWORD '${random_password.terraform_password.result}';\""
    su postgres -c "psql -c \"ALTER USER terraform WITH SUPERUSER;\""
  EOT
  )
}

resource "random_password" "replicator_password" {
  length           = 64
  special          = false
}

resource "vault_kv_secret_v2" "replicator_password" {
  mount = var.vault_mount
  name  = "postgresql/replicator_password"
  data_json = jsonencode({
    password = random_password.replicator_password.result
  })
}

resource "postgresql_role" "replicator" {
  name     = "replicator"
  login    = true
  password = random_password.replicator_password.result
  replication = true
}

module "replica" {
  source = "../complete_vm"
  for_each = var.replicas

  vm_datastore_id   = each.value.datastore_id
  proxmox_node_name = each.value.proxmox_node_name
  image_file_id     = var.image_file_id

  name = "${var.cluster_name}-${each.key}"
  fqdn = "${var.cluster_name}-${each.key}.${var.domain}"

  cpu_cores    = each.value.cpu_cores
  memory_mb    = each.value.memory_mb
  disk_size_gb = each.value.disk_size_gb
  network_mac_address = each.value.mac_address

  ssh_public_key = var.ssh_public_key

  runcmd = split("\n", <<-EOT
    set -o xtrace
    apt-get update
    apt-get install -y curl ca-certificates
    install -d /usr/share/postgresql-common/pgdg
    curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
    sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    apt-get update
    apt-get install -y postgresql-16
    echo "listen_addresses = '*'" >> /etc/postgresql/16/main/postgresql.conf
    echo 'host all all 10.88.111.0/24 scram-sha-256' >> /etc/postgresql/16/main/pg_hba.conf

    systemctl stop postgresql

    rm -rf /var/lib/postgresql/16/main/
    export PGPASSWORD='${random_password.replicator_password.result}'
    pg_basebackup -h ${module.primary.ip_address} -U replicator -D /var/lib/postgresql/16/main -Fp -Xs -R -P
    chown -R postgres:postgres /var/lib/postgresql/16/main

    systemctl enable postgresql
    systemctl start postgresql
  EOT
  )
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
