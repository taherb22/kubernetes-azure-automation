output "vm_names" {
  description = "Names of all VMs created"
  value       = [for name, vm in azurerm_linux_virtual_machine.vm : vm.name]
}

output "vm_private_ips" {
  description = "Private IP addresses of all VMs"
  value = {
    for name, nic in azurerm_network_interface.nic :
    name => nic.private_ip_address
  }
}

output "vm_public_ips" {
  description = "Public IP addresses of all VMs"
  value = {
    for name, ip in azurerm_public_ip.pubip :
    name => ip.ip_address
  }
}

output "ssh_commands" {
  description = "SSH commands to connect to each VM"
  value = {
    for name, ip in azurerm_public_ip.pubip :
    name => "ssh ${var.admin_username}@${ip.ip_address}"
  }
}

output "master_public_ip" {
  description = "Public IP of the master node"
  value       = azurerm_public_ip.pubip["master"].ip_address
}


output "worker_public_ips" {
  description = "Public IPs of all worker nodes"
  value = [
    azurerm_public_ip.pubip["worker1"].ip_address,
    azurerm_public_ip.pubip["worker2"].ip_address
  ]
}



output "worker1_public_ip" {
  description = "Public IP of worker node 1"
  value       = azurerm_public_ip.pubip["worker1"].ip_address
}

output "worker2_public_ip" {
  description = "Public IP of worker node 2"
  value       = azurerm_public_ip.pubip["worker2"].ip_address
}

output "master_private_ip" {
  description = "Private IP of the master node"
  value       = azurerm_network_interface.nic["master"].private_ip_address
}

output "worker1_private_ip" {
  description = "Private IP of worker node 1"
  value       = azurerm_network_interface.nic["worker1"].private_ip_address
}

output "worker2_private_ip" {
  description = "Private IP of worker node 2"
  value       = azurerm_network_interface.nic["worker2"].private_ip_address
}