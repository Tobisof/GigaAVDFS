locals {
  fslogix_share_unc = format("\\\\%s.file.core.windows.net\\\\%s", azurerm_storage_account.files.name, local.files_share_name)

  custom_script_content = templatefile("${path.module}/scripts/install-avd.ps1.tmpl", {
    fslogix_url        = var.fslogix_download_url
    avd_agent_url      = var.avd_agent_url
    avd_bootloader_url = var.avd_bootloader_url
    fslogix_share      = local.fslogix_share_unc
    registration_token = azurerm_virtual_desktop_host_pool_registration_info.registration.token
  })

  custom_script_wrapped = <<-SCRIPT
$script = @'
${local.custom_script_content}
'@
$newPath = "C:\\Temp\\avd-setup.ps1"
New-Item -ItemType Directory -Path (Split-Path $newPath) -Force | Out-Null
Set-Content -Path $newPath -Value $script -Encoding Unicode
powershell -ExecutionPolicy Bypass -File $newPath
SCRIPT

  custom_script_one_liner = replace(trimspace(local.custom_script_wrapped), "\n", " ; ")
  custom_script_command   = "powershell -ExecutionPolicy Bypass -Command \"${replace(local.custom_script_one_liner, "\"", "\\\"")}\""
}

resource "azurerm_windows_virtual_machine" "session_host" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.core.name
  location            = local.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.session_host.id
  ]
  provision_vm_agent       = true
  enable_automatic_updates = true
  timezone                 = "Central European Standard Time"
  computer_name            = local.vm_name
  license_type             = "Windows_Client"

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                 = "${local.vm_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = "latest"
  }

  tags = local.common_tags
}

resource "azurerm_virtual_machine_extension" "aad_login" {
  name                       = "${local.vm_name}-aadlogin"
  virtual_machine_id         = azurerm_windows_virtual_machine.session_host.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  tags                       = local.common_tags
}

resource "azurerm_virtual_machine_extension" "custom_script" {
  name                       = "${local.vm_name}-setup"
  virtual_machine_id         = azurerm_windows_virtual_machine.session_host.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    commandToExecute = local.custom_script_command
  })

  tags = local.common_tags
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "session_host" {
  virtual_machine_id = azurerm_windows_virtual_machine.session_host.id
  location           = local.location

  daily_recurrence_time = "2200"
  timezone              = "Central European Standard Time"
  notification_settings {
    enabled = false
  }

  enabled = true
  tags    = local.common_tags
}
