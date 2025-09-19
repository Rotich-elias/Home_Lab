resource "libvirt_cloudinit_disk" "user_data" {
  name      = "wordpress-cloudinit.iso"
  user_data = file("cloud-init/user_data.yaml")
  pool      = "default"
}
terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu+ssh://smithhomelab@smithhomelab/system"
}
resource "libvirt_network" "wordpress_net" {
  name      = "wordpressnet"
  mode      = "nat"
  addresses = ["192.168.200.0/24"]
}
resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-22.04-base"
  pool   = "default"
  source = "/home/smithhomelab/kvm/images/ubuntu-22.04.qcow2"
  format = "qcow2"
}

resource "libvirt_domain" "wordpress_vm" {
  name   = "wordpress-vm"
  memory = 2048
  vcpu   = 2

  network_interface {
    network_name = libvirt_network.wordpress_net.name
  }

  disk {
    volume_id = libvirt_volume.ubuntu_base.id
  }

  cloudinit = libvirt_cloudinit_disk.user_data.id

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
}
