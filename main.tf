terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token       = "AQAAAAALozx_AATuweq4SWtkWE-hoZSQs79d23k"
  zone        = "ru-central1-b"
  cloud_id    = "b1grn1e3krsr60esrsqh"
  folder_id   = "b1g8nrikjk854e3o02mb"
}
resource "yandex_lb_target_group" "ter-1" {
  name   = "terra-1" 
 
  target {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    address  = "${yandex_compute_instance.vm-1.network_interface.0.ip_address}"
  } 
 
  target {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    address  = "${yandex_compute_instance.vm-2.network_interface.0.ip_address}"
  }
}
resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd87kbts7j40q5b9rpjr"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }
 
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}
resource "yandex_compute_instance" "vm-2" {
  name = "terraform2"
#  count = 2
#  tags = {
#    Name = "vm${count.index}"
#  }
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd87kbts7j40q5b9rpjr"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }
 
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}
resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}
resource "yandex_lb_network_load_balancer" "terraform-1" {
  name = "test-vm"
listener {
    name = "my-listener"
    port = 80
  }  
attached_target_group {
    target_group_id = "${yandex_lb_target_group.ter-1.id}"
    healthcheck {
      name = "http"
        http_options {
          port = 80
          path = "/"
        }
    }
  }
}
#  target {
#    subnet_id = "subnet1"
#    address   = yandex_compute_instance.vm-1.network_interface.0.ip_address
#  }
#  target {
#    subnet_id = "subnet1"
#    address   = yandex_compute_instance.vm-2.network_interface.0.ip_address
#  }
#}
#resource "yandex_vpc_network" "network-2"{
#name = "network2"
#}
#resource "yandex_vpc_subnet" "subnet-2" {
#  name           = "subnet2"
#  zone           = "ru-central-b"
#  network_id     = yandex_vpc_network.network-2.id
#  v4_cidr_blocks = ["192.168.20.0/24"]
#}
output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}
output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}
output "internal_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.ip_address
}
output "external_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
}
