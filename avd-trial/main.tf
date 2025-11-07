locals {
  location             = var.location
  resource_group_name  = "${var.project_name}-rg"
  vnet_name            = "${var.project_name}-vnet"
  subnet_name          = "${var.project_name}-subnet"
  nsg_name             = "${var.project_name}-nsg"
  public_ip_name       = "${var.project_name}-pip"
  nic_name             = "${var.project_name}-nic"
  vm_name              = "${var.project_name}-sh01"
  host_pool_name       = "${var.project_name}-hp"
  workspace_name       = "${var.project_name}-ws"
  application_group    = "${var.project_name}-dag"
  files_share_name     = "profiles"
  vnet_address_space   = ["10.10.0.0/16"]
  subnet_address_space = "10.10.1.0/24"
  storage_account_base = substr(regexreplace(lower(var.project_name), "[^a-z0-9]", ""), 0, 11)

  tags_base = {
    Project     = var.project_name
    Environment = "avd-trial"
    ManagedBy   = "Terraform"
  }
}

resource "time_static" "deployment" {}

locals {
  common_tags = merge(local.tags_base, {
    DeployedAt = time_static.deployment.rfc3339
  })
}
