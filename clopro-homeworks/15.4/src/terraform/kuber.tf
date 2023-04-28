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