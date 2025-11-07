output "workspace_name" {
  description = "Nazwa Workspace AVD."
  value       = azurerm_virtual_desktop_workspace.workspace.name
}

output "host_pool_name" {
  description = "Nazwa Host Pool."
  value       = azurerm_virtual_desktop_host_pool.pooled.name
}

output "application_group_name" {
  description = "Nazwa Desktop Application Group."
  value       = azurerm_virtual_desktop_application_group.desktop.name
}

output "storage_account_name" {
  description = "Nazwa konta Storage dla FSLogix."
  value       = azurerm_storage_account.files.name
}

output "fslogix_share_path" {
  description = "UNC udziału z profilami FSLogix."
  value       = format("\\\\%s.file.core.windows.net\\\\%s", azurerm_storage_account.files.name, local.files_share_name)
}

output "vm_public_ip" {
  description = "Publiczny adres IP hosta sesyjnego."
  value       = azurerm_public_ip.session_host.ip_address
}

output "vm_private_ip" {
  description = "Prywatny adres IP hosta sesyjnego."
  value       = azurerm_network_interface.session_host.private_ip_address
}
