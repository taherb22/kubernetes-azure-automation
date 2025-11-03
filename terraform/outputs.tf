output "vm_names" {
  value = [for name in local.vm_names : "${name}-vm"]
}

output "vm_private_ips" {
  value = {
    for name, nic in azurerm_network_interface.nic :
    name => nic.private_ip_address
  }
}

output "vm_public_ips" {
  value = {
    for name, ip in azurerm_public_ip.pubip :
    name => ip.ip_address
  }
}

output "ssh_commands" {
  value = {
    for name, ip in azurerm_public_ip.pubip :
    name => "ssh ${var.admin_username}@${ip.ip_address}"
  }
}
