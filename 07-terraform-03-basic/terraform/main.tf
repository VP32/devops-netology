provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_region
}

locals {
  instances_count_map = {
    stage = 1,
    prod  = 2
  }
  instances_image_type_map = {
    stage = var.image_id_stage,
    prod  = var.image_id_prod
  }
  preemptible_map = {
    stage = true,
    prod  = false
  }
}

resource "yandex_compute_instance" "vp_netology_vm_count" {
  name = "test-${terraform.workspace}-${count.index}"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      // Для пункта 3 задания 2: В уже созданный aws_instance добавьте зависимость типа инстанса от вокспейса, что бы в разных ворскспейсах использовались разные instance_type. - С поправкой для Яндекс облака вместо instance_type меняем образ ОС.
      image_id = local.instances_image_type_map[terraform.workspace]
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
  }

  // Для п.4 Добавим count. Для stage должен создаться один экземпляр ec2, а для prod два.
  count = local.instances_count_map[terraform.workspace]

  // Для п.6 Чтобы при изменении типа инстанса не возникло ситуации, когда не будет ни одного инстанса добавьте параметр жизненного цикла create_before_destroy = true в один из рессурсов aws_instance. В документации по Яндексу такую настройку не нашел, похоже она игнорируется, актуальна для Амазона.
  lifecycle {
    create_before_destroy = true
  }

  // Для п.7 При желании поэкспериментируйте с другими параметрами и рессурсами.
  scheduling_policy {
    preemptible = local.preemptible_map[terraform.workspace]
  }
}


locals {
  instance_ids_map = {
    stage = toset([
      "1",
    ])
    prod = toset([
      "1",
      "2",
    ])
  }
}

resource "yandex_compute_instance" "vp_netology_vm_foreach" {
  // Для п.5. Создайте рядом еще один aws_instance, но теперь определите их количество при помощи for_each, а не count.
  for_each = local.instance_ids_map[terraform.workspace]
  name     = "foreach-test-${terraform.workspace}-${each.key}"
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      // Для пункта 3 задания 2: В уже созданный aws_instance добавьте зависимость типа инстанса от вокспейса, что бы в разных ворскспейсах использовались разные instance_type. - С поправкой для Яндекс облака вместо instance_type меняем образ ОС.
      image_id = local.instances_image_type_map[terraform.workspace]
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = var.yc_region
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.0.0/16"]
}
