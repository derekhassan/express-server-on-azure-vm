output "vm_ip_address" {
  value = azurerm_linux_virtual_machine.express_server_vm.public_ip_address
}

output "vm_username" {
  value = azurerm_linux_virtual_machine.express_server_vm.admin_username
}

output "ssh_private_key" {
  value     = tls_private_key.generated_ssh_key.private_key_pem
  sensitive = true
}
