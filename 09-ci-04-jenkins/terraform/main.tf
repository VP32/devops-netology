provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_region
}

resource "yandex_compute_instance" "vp_jenkins_master" {
  name = "${terraform.workspace}-jenkins-master"

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

resource "yandex_compute_instance" "vp_jenkins_agent" {
  name = "${terraform.workspace}-jenkins-agent"

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

output "internal_ip_address_jenkins_master" {
  value = yandex_compute_instance.vp_jenkins_master.network_interface.0.ip_address
}

output "internal_ip_address_jenkins_agent" {
  value = yandex_compute_instance.vp_jenkins_agent.network_interface.0.ip_address
}


output "external_ip_address_jenkins_master" {
  value = yandex_compute_instance.vp_jenkins_master.network_interface.0.nat_ip_address
}

output "external_ip_address_jenkins_agent" {
  value = yandex_compute_instance.vp_jenkins_agent.network_interface.0.nat_ip_address
}
