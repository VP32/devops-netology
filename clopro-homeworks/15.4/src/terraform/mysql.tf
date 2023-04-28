######################################################################################################################
# Задание 1. Кластер MySQL

# Необходимые ресурсы для создания кластера
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
}

######################################################################################################################
# Кластер MySQL
resource "yandex_mdb_mysql_cluster" "vp-mysql-01" {
  description        = "Кластер MySQL"
  name               = "vp-mysql-01"
  environment        = "PRESTABLE"
  network_id         = yandex_vpc_network.network-netology.id
  version            = "8.0"
  security_group_ids = [yandex_vpc_security_group.cluster-sg-1.id]

  #  Включить защиту кластера от непреднамеренного удаления
  deletion_protection = true

  #  Использовать окружение Prestable, платформу Intel Broadwell с производительностью 50% CPU и размером диска 20 Гб.
  resources {
    resource_preset_id = "b1.medium"
    disk_type_id       = "network-ssd"
    disk_size          = "20"
  }

  # Необходимо предусмотреть репликацию с произвольным временем технического обслуживания.
  maintenance_window {
    type = "ANYTIME"
  }

  #  Задать время начала резервного копирования — 23:59.
  backup_window_start {
    hours   = "23"
    minutes = "59"
  }

  host {
    name      = "node-a"
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.private-a.id
  }
  host {
    name      = "node-b"
    zone      = "ru-central1-b"
    subnet_id = yandex_vpc_subnet.private-b.id
  }
  host {
    name      = "node-c"
    zone      = "ru-central1-c"
    subnet_id = yandex_vpc_subnet.private-c.id
  }

  depends_on = [
    yandex_vpc_network.network-netology,
    yandex_vpc_subnet.private-a,
    yandex_vpc_subnet.private-b,
    yandex_vpc_subnet.private-c,
    yandex_vpc_security_group.cluster-sg-1
  ]
}

######################################################################################################################
# БД и пользователь
# Создаем БД в кластере
resource "yandex_mdb_mysql_database" "netology_db" {
  cluster_id = yandex_mdb_mysql_cluster.vp-mysql-01.id
  name       = var.database_name
}
# Создаем пользователя БД в кластере
resource "yandex_mdb_mysql_user" "database_user" {
  cluster_id = yandex_mdb_mysql_cluster.vp-mysql-01.id
  name       = var.database_user
  password   = var.database_password
  permission {
    database_name = yandex_mdb_mysql_database.netology_db.name
    roles         = ["ALL"]
  }
}

###################################################################################################################
# Данные для вывода
output "connection_current_master" {
  description = "Адрес мастера в кластере БД"
  value       = "c-${yandex_mdb_mysql_cluster.vp-mysql-01.id}.rw.mdb.yandexcloud.net"
}
output "connection_nodes" {
  description = "Адреса созданных нод в кластере БД"
  value       = yandex_mdb_mysql_cluster.vp-mysql-01.host.*.fqdn
}

# Записываем адрес мастера в кластере в файл переменных Helm chart для PHPMyAdmin
resource "local_file" "output_master_address" {
  content = <<-DOC
    database:
      serverUrl: "c-${yandex_mdb_mysql_cluster.vp-mysql-01.id}.rw.mdb.yandexcloud.net"
    DOC

  filename   = "../k8s/helm/pma/values.yaml"
  depends_on = [
    yandex_mdb_mysql_cluster.vp-mysql-01
  ]
}

