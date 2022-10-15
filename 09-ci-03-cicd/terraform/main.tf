provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_region
}

resource "yandex_compute_instance" "vp_netology_vm_sonar" {
  name = "test-${terraform.workspace}-sonar"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id_stage
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    nat = true
  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/id_yc_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "vp_netology_vm_nexus" {
  name = "test-${terraform.workspace}-nexus"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id_stage
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    nat = true
  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/id_yc_rsa.pub")}"
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

output "internal_ip_address_vm_nexus" {
  value = yandex_compute_instance.vp_netology_vm_nexus.network_interface.0.ip_address
}

output "internal_ip_address_vm_sonar" {
  value = yandex_compute_instance.vp_netology_vm_sonar.network_interface.0.ip_address
}


output "external_ip_address_vm_nexus" {
  value = yandex_compute_instance.vp_netology_vm_nexus.network_interface.0.nat_ip_address
}

output "external_ip_address_vm_sonar" {
  value = yandex_compute_instance.vp_netology_vm_sonar.network_interface.0.nat_ip_address
}
