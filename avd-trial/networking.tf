resource "azurerm_resource_group" "core" {
  name     = local.resource_group_name
  location = local.location
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "core" {
  name                = local.vnet_name
  address_space       = local.vnet_address_space
  location            = local.location
  resource_group_name = azurerm_resource_group.core.name
  tags                = local.common_tags
}

resource "azurerm_subnet" "avd" {
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.core.name
  virtual_network_name = azurerm_virtual_network.core.name
  address_prefixes     = [local.subnet_address_space]
}

resource "azurerm_network_security_group" "avd" {
  name                = local.nsg_name
  location            = local.location
  resource_group_name = azurerm_resource_group.core.name
  tags                = local.common_tags
}

resource "azurerm_network_security_rule" "rdp" {
  count                       = length(var.allowed_rdp_source_cidrs)
  name                        = "allow-rdp-${count.index + 1}"
  priority                    = 100 + count.index
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = element(var.allowed_rdp_source_cidrs, count.index)
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.core.name
  network_security_group_name = azurerm_network_security_group.avd.name
  description                 = "Allow RDP only from approved IP(s); extend rules for AVD troubleshooting as needed."
}

resource "azurerm_subnet_network_security_group_association" "avd" {
  subnet_id                 = azurerm_subnet.avd.id
  network_security_group_id = azurerm_network_security_group.avd.id
}

resource "azurerm_public_ip" "session_host" {
  name                = local.public_ip_name
  location            = local.location
  resource_group_name = azurerm_resource_group.core.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_network_interface" "session_host" {
  name                = local.nic_name
  location            = local.location
  resource_group_name = azurerm_resource_group.core.name

  ip_configuration {
    name                          = "ipconfig-sessionhost"
    subnet_id                     = azurerm_subnet.avd.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.session_host.id
  }

  tags = local.common_tags
}
