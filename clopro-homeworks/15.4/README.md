# Домашнее задание к занятию «Кластеры. Ресурсы под управлением облачных провайдеров»


---
## Задание 1. Yandex Cloud

1. Настроить с помощью Terraform кластер баз данных MySQL.

 - Используя настройки VPC из предыдущих домашних заданий, добавить дополнительно подсеть private в разных зонах, чтобы обеспечить отказоустойчивость. 
 - Разместить ноды кластера MySQL в разных подсетях.
 - Необходимо предусмотреть репликацию с произвольным временем технического обслуживания.
 - Использовать окружение Prestable, платформу Intel Broadwell с производительностью 50% CPU и размером диска 20 Гб.
 - Задать время начала резервного копирования — 23:59.
 - Включить защиту кластера от непреднамеренного удаления.
 - Создать БД с именем `netology_db`, логином и паролем.

**Решение**

Код для Terraform находится в подпапке [src/terraform](./src/terraform).

Сделал единый проект для Терраформ, создающий кластеры БД и Kubernetes. Разбил по разным файлам планы этих кластеров. Содержимое плана для кластера MySQL находится в файле mysql.tf:

```terraform
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


```

Запускаю Терраформ для создания кластеров. Успешно запускается и кластера создаются:

![1.png](img%2F1.png)

![2.png](img%2F2-.png)

На выходе по кластеру MySQL выводятся:
 - адрес мастера в кластере БД
 - адреса всех нод кластера БД
 - в файл values.yaml для Helm chart для PHPMyAdmin выводится адрес мастера БД для подключения к нему PHPMyAdmin.


2. Настроить с помощью Terraform кластер Kubernetes.

 - Используя настройки VPC из предыдущих домашних заданий, добавить дополнительно две подсети public в разных зонах, чтобы обеспечить отказоустойчивость.
 - Создать отдельный сервис-аккаунт с необходимыми правами. 
 - Создать региональный мастер Kubernetes с размещением нод в трёх разных подсетях.
 - Добавить возможность шифрования ключом из KMS, созданным в предыдущем домашнем задании.
 - Создать группу узлов, состояющую из трёх машин с автомасштабированием до шести.
 - Подключиться к кластеру с помощью `kubectl`.
 - *Запустить микросервис phpmyadmin и подключиться к ранее созданной БД.
 - *Создать сервис-типы Load Balancer и подключиться к phpmyadmin. Предоставить скриншот с публичным адресом и подключением к БД.

**Решение**

Содержимое плана для кластера K8S находится в файле kuber.tf:

```terraform
#######################################################################################################################
# Задание 2. Кластер K8S

# Необходимые ресурсы для создания кластера
resource "yandex_vpc_subnet" "public-a" {
  name           = "public-a"
  v4_cidr_blocks = ["192.168.40.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-netology.id
}

resource "yandex_vpc_subnet" "public-b" {
  name           = "public-b"
  v4_cidr_blocks = ["192.168.50.0/24"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-netology.id
}

resource "yandex_vpc_subnet" "public-c" {
  name           = "public-c"
  v4_cidr_blocks = ["192.168.60.0/24"]
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.network-netology.id
}

resource "yandex_iam_service_account" "kuber-sa-account" {
  description = "Сервисный аккаунт для кластера K8S"
  name        = var.kuber-sa-name
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-clusters-agent" {
  # Сервисному аккаунту назначается роль "k8s.clusters.agent".
  folder_id = var.yc_folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.kuber-sa-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "vpc-public-admin" {
  # Сервисному аккаунту назначается роль "vpc.publicAdmin".
  folder_id = var.yc_folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.kuber-sa-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "images-puller" {
  # Сервисному аккаунту назначается роль "container-registry.images.puller".
  folder_id = var.yc_folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.kuber-sa-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "kuber-sa-lb-admin" {
  # Сервисному аккаунту назначается роль "load-balancer.admin" - даем возможность создавать сервис типа LoadBalancer.
  folder_id = var.yc_folder_id
  role      = "load-balancer.admin"
  member    = "serviceAccount:${yandex_iam_service_account.kuber-sa-account.id}"
}

resource "yandex_kms_symmetric_key" "kms-key" {
  # Ключ для шифрования важной информации, такой как пароли, OAuth-токены и SSH-ключи.
  name              = "kms-key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" # 1 год.
}

resource "yandex_kms_symmetric_key_iam_binding" "viewer" {
  # Даем сервисному аккаунту доступ к ключу шифрования.
  symmetric_key_id = yandex_kms_symmetric_key.kms-key.id
  role             = "viewer"
  members          = [
    "serviceAccount:${yandex_iam_service_account.kuber-sa-account.id}"
  ]
}

####################################################################################################################
# Кластер и группа узлов
resource "yandex_kubernetes_cluster" "k8s-regional" {
  description        = "Кластер K8S"
  name               = "vp-k8s-cluster-01"
  network_id         = yandex_vpc_network.network-netology.id
  cluster_ipv4_range = "10.1.0.0/16"
  service_ipv4_range = "10.2.0.0/16"
  master {
    version   = var.k8s_version
    public_ip = true
    # Создать региональный мастер Kubernetes с размещением нод в трёх разных подсетях.
    regional {
      region = "ru-central1"
      location {
        zone      = yandex_vpc_subnet.public-a.zone
        subnet_id = yandex_vpc_subnet.public-a.id
      }
      location {
        zone      = yandex_vpc_subnet.public-b.zone
        subnet_id = yandex_vpc_subnet.public-b.id
      }
      location {
        zone      = yandex_vpc_subnet.public-c.zone
        subnet_id = yandex_vpc_subnet.public-c.id
      }
    }
  }
  service_account_id      = yandex_iam_service_account.kuber-sa-account.id
  node_service_account_id = yandex_iam_service_account.kuber-sa-account.id

  #  Добавить возможность шифрования ключом из KMS, созданным в предыдущем домашнем задании.
  kms_provider {
    key_id = yandex_kms_symmetric_key.kms-key.id
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_member.vpc-public-admin,
    yandex_resourcemanager_folder_iam_member.images-puller,
    yandex_resourcemanager_folder_iam_member.kuber-sa-lb-admin,
    yandex_kms_symmetric_key.kms-key,
    yandex_kms_symmetric_key_iam_binding.viewer
  ]
}

# Создать группу узлов, состояющую из трёх машин с автомасштабированием до шести.
resource "yandex_kubernetes_node_group" "k8s-ng-01" {
  description = "Группа узлов для кластера"
  cluster_id  = yandex_kubernetes_cluster.k8s-regional.id
  name        = "k8s-ng-01"
  instance_template {
    platform_id = "standard-v2"
    container_runtime {
      type = "containerd"
    }
    network_interface {
      nat        = true
      subnet_ids = ["${yandex_vpc_subnet.public-a.id}"]
    }
    scheduling_policy {
      preemptible = true
    }
    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/id_yc_rsa.pub")}"
    }
  }

  scale_policy {
    auto_scale {
      initial = 3
      max     = 6
      min     = 3
    }
  }
  allocation_policy {
    location {
      zone = "ru-central1-a"
    }
  }

  depends_on = [
    yandex_kubernetes_cluster.k8s-regional,
    yandex_vpc_subnet.public-a
  ]

}

#######################################################################################################################
# Данные для вывода
output "k8s_external_v4_endpoint" {
  value       = yandex_kubernetes_cluster.k8s-regional.master[0].external_v4_endpoint
  description = "Эндпойнт для подключения к кластеру"
}
output "k8s_cluster_id" {
  value       = yandex_kubernetes_cluster.k8s-regional.id
  description = "ID созданного кластера"
}
```

Кластер уже создался при запуске Терраформа в задании 1:

![2.png](img%2F2-.png)

По кластеру Kubernetes выводится:
 - эндпойнт подключения к кластеру
 - id созданного кластера.

С помощью команды добавляем созданный кластер в конфиг для kubectl:

![3.png](img%2F3.png)

Проверяем работу кластера:

![4.png](img%2F4.png)

Кластер доступен и работает.

Helm-chart для деплоя phpmyadmin находится в папке [src/k8s/helm/pma](./src/k8s/helm/pma)

Разворачиваю phpmyadmin с помощью Deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pma-deployment
  labels:
    app: pma
spec:
  replicas: 2
  selector:
    matchLabels:
      app: pma
  template:
    metadata:
      labels:
        app: pma
    spec:
      containers:
        - name: pma
          image: phpmyadmin:5.2.1-apache
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 80
          env:
            - name: PMA_HOST
              value: {{ .Values.database.serverUrl }}

```

Для доступа к phpmyadmin создаю Service типа LoadBalancer:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: lb-service
spec:
  ports:
  # Порт сетевого балансировщика, на котором будут обслуживаться пользовательские запросы.
  - port: 80
    name: plaintext
    # Порт контейнера, на котором доступно приложение.
    targetPort: 80
  # Метки селектора, использованные в шаблоне подов при создании объекта Deployment.
  selector:
    app: pma
  type: LoadBalancer
```

С помощью Helm разворачиваем phpmyadmin:

![5.png](img%2F5.png)

Все успешно развернулось. Находим адрес LoadBalancer:

![6.png](img%2F6.png)

Это адрес 158.160.104.37

Пробую открыть этот адрес и подключиться с логином и паролем пользователя, созданного Терраформом:

Адрес открывается:

![7.png](img%2F7.png)

Вводим логин и пароль, авторизуемся. К БД успешно подключились:

![8.png](img%2F8.png)

Видим, что адрес сервера - адрес мастера нашего MySQL-кластера: c-c9q68aupstc1mljel1gn.rw.mdb.yandexcloud.net


