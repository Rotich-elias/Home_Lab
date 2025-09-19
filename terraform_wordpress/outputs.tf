output "wordpress_vm_ip" {
  value = libvirt_domain.wordpress_vm.network_interface[0].addresses[0]
}
