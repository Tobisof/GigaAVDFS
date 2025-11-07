resource "azurerm_virtual_desktop_host_pool" "pooled" {
  name                     = local.host_pool_name
  resource_group_name      = azurerm_resource_group.core.name
  location                 = local.location
  type                     = "Pooled"
  friendly_name            = "${var.project_name}-pooled"
  load_balancer_type       = "BreadthFirst"
  maximum_sessions_allowed = 10
  preferred_app_group_type = "Desktop"
  start_vm_on_connect      = true
  tags                     = local.common_tags
}
# Dodaj "teraz" i przesunięcie o 48h (wymaga providera time – już masz)
resource "time_static" "now" {}

resource "time_offset" "registration_expiration" {
  base_rfc3339 = time_static.now.rfc3339
  offset_hours = 48
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "registration" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.pooled.id # <- bez podkreślnika po "host"
  expiration_date = time_offset.registration_expiration.rfc3339 # <- poprawne pole
}
resource "azurerm_virtual_desktop_workspace" "workspace" {
  name                = local.workspace_name
  resource_group_name = azurerm_resource_group.core.name
  location            = local.location
  friendly_name       = "${var.project_name}-workspace"
  description         = "Workspace for ${var.project_name} demo"
  tags                = local.common_tags
}

resource "azurerm_virtual_desktop_application_group" "desktop" {
  name                = local.application_group
  resource_group_name = azurerm_resource_group.core.name
  location            = local.location
  friendly_name       = "${var.project_name}-desktop"
  type                = "Desktop"
  host_pool_id        = azurerm_virtual_desktop_host_pool.pooled.id
  tags                = local.common_tags
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "this" {
  workspace_id         = azurerm_virtual_desktop_workspace.workspace.id
  application_group_id = azurerm_virtual_desktop_application_group.desktop.id
}
