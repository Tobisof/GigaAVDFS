resource "random_string" "storage_suffix" {
  length  = 5
  lower   = true
  upper   = false
  numeric = true
  special = false
}

locals {
  storage_account_name = substr("${local.storage_account_base}${random_string.storage_suffix.result}", 0, 24)
}

resource "azurerm_storage_account" "files" {
  name                       = local.storage_account_name
  resource_group_name        = azurerm_resource_group.core.name
  location                   = local.location
  account_tier               = "Premium"
  account_replication_type   = "ZRS" # Zmień na LRS w regionach bez wsparcia ZRS
  account_kind               = "FileStorage"
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  azure_files_authentication {
    directory_type = "AADKERB"
  }

  tags = local.common_tags
}

resource "azurerm_storage_share" "profiles" {
  name                 = local.files_share_name
  storage_account_name = azurerm_storage_account.files.name
  quota                = var.fslogix_share_quota_gb
  enabled_protocol     = "SMB"
}
