provider "libvirt" {
  uri = "qemu+ssh://smithhomelab@smithhomelab/system"
}

resource "libvirt_network" "wordpress_net" {
  name      = "wordpressnet"
  mode      = "nat"
  addresses = ["192.168.200.0/24"]
}

resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-wordpress-base"
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
    type     = "vnc"
    listen_type = "address"
    autoport = true
  }
}

resource "libvirt_cloudinit_disk" "user_data" {
  name      = "wordpress-cloudinit.iso"
  user_data = <<EOF
#cloud-config
users:
  - name: ubuntu
    ssh-authorized-keys:
      - ${file("~/.ssh/id_ed25519.pub")}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    shell: /bin/bash
EOF
  pool = "default"
}
