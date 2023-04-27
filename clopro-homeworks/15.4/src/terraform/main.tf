provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
}

######################################################################################################################
# Задание 1. Кластер MySQL

resource "yandex_vpc_network" "network-netology" {
  name = "network-netology"
}

resource "yandex_vpc_subnet" "private-a" {
  name           = "private-a"
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-netology.id
}

resource "yandex_vpc_subnet" "private-b" {
  name           = "private-b"
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-netology.id
}

resource "yandex_vpc_subnet" "private-c" {
  name           = "private-c"
  v4_cidr_blocks = ["192.168.30.0/24"]
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.network-netology.id
}

# Cluster data
resource "yandex_mdb_mysql_cluster" "vp-mysql-01" {
  name                = "vp-mysql-01"
  environment         = "PRESTABLE"
  network_id          = yandex_vpc_network.network-netology.id
  version             = "8.0"
  # TODO  remove it
  security_group_ids  = [ yandex_vpc_security_group.cluster-sg-1.id ]
  deletion_protection = true

  resources {
    resource_preset_id = "b1.medium"
    disk_type_id       = "network-ssd"
    disk_size          = "20"
  }

  maintenance_window {
    type = "ANYTIME"
  }

  backup_window_start {
    hours = "23"
    minutes = "59"
  }

  host {
    name = "node-a"
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.private-a.id
    # TODO remove it
    assign_public_ip = true
  }
  host {
    name = "node-b"
    zone      = "ru-central1-b"
    subnet_id = yandex_vpc_subnet.private-b.id
    # TODO remove it
    assign_public_ip = true
  }
  host {
    name = "node-c"
    zone      = "ru-central1-c"
    subnet_id = yandex_vpc_subnet.private-c.id
    # TODO remove it
    assign_public_ip = true
  }
}

resource "yandex_mdb_mysql_database" "netology" {
  cluster_id = yandex_mdb_mysql_cluster.vp-mysql-01.id
  name       = "netology"
}

resource "yandex_mdb_mysql_user" "connecter" {
  cluster_id = yandex_mdb_mysql_cluster.vp-mysql-01.id
  name       = "connecter"
  password   = "!QAZ1qaz" # TODO hide in envs
  permission {
    database_name = yandex_mdb_mysql_database.netology.name
    roles         = ["ALL"]
  }
}

# TODO  remove it
resource "yandex_vpc_security_group" "cluster-sg-1" {
  name        = "cluster-sg-1"
  description = "Группа безопасности для доступа к кластеру"
  network_id  = yandex_vpc_network.network-netology.id

  ingress {
    protocol       = "TCP"
    description    = "Входящий траффик кластера"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 3306
  }

  egress {
    protocol       = "TCP"
    description    = "Исходящий траффик кластера"
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]
    from_port      = 3306
    to_port        = 3306
  }
}


###################################################################################################################
output "connection_current_master" {
  # TODO
  value = "с-${yandex_mdb_mysql_cluster.vp-mysql-01.id}.rw.mdb.yandexcloud.net"
}
output "connection_nodes" {
  # TODO
  value = yandex_mdb_mysql_cluster.vp-mysql-01.host.*.fqdn
}
output "database_data" {
  value = yandex_mdb_mysql_database.netology.id
}