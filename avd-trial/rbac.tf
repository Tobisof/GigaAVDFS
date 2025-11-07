resource "azurerm_role_assignment" "avd_users_app_group" {
  scope                = azurerm_virtual_desktop_application_group.desktop.id
  role_definition_name = "Virtual Desktop User"
  principal_id         = var.avd_users_group_object_id

  depends_on = [azurerm_virtual_desktop_workspace_application_group_association.this]
}

resource "azurerm_role_assignment" "fslogix_share" {
  scope                = azurerm_storage_share.profiles.id
  role_definition_name = "Storage File Data SMB Share Contributor"
  principal_id         = var.avd_users_group_object_id

  # Propagacja uprawnień RBAC może potrwać 15-30 minut.
}
