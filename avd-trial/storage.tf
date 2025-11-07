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
  name                      = local.storage_account_name
  resource_group_name       = azurerm_resource_group.core.name
  location                  = local.location
  account_tier              = "Premium"
  account_replication_type  = "ZRS" # Zmień na LRS w regionach bez wsparcia ZRS
  account_kind              = "FileStorage"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
  large_file_share_enabled  = true

  azure_files_identity_based_authentication {
    directory_service_options = "AADKERB"
    default_share_permission  = "None"
  }

  tags = local.common_tags
}

resource "azurerm_storage_share" "profiles" {
  name                 = local.files_share_name
  storage_account_name = azurerm_storage_account.files.name
  quota                = var.fslogix_share_quota_gb
  enabled_protocol     = "SMB"
}
