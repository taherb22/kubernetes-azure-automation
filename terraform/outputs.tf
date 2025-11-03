output "vm_private_ips" {
  value = { for name, nic in azurerm_network_interface.nic : name => nic.ip_configuration[0].private_ip_address }
}

output "vm_names" {
  value = [for name in local.vm_names : "${name}-vm"]
}
