# Creating the security groups

# Create Network Security Group and rule
resource "azurerm_network_security_group" "allow-global" {
    name                = "${var.name}-nsg-allow-global"
    location            = var.region
    resource_group_name = var.resource_group
    tags = {
        environment = "${var.name}"
    }
}

resource "azurerm_network_security_group" "allow-local" {
    name                = "${var.name}-nsg-allow-local"
    location            = var.region
    resource_group_name = var.resource_group
    tags = {
        environment = "${var.name}"
    }
}

### Security Group Rules for global traffic #####
resource "azurerm_network_security_rule" "public-icmp" {
    name                        = "${var.name}-public-ICMP"
    priority                    = 1001
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Icmp"
    source_port_range           = "*"
    destination_port_range      = "*"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = var.resource_group
    network_security_group_name = azurerm_network_security_group.allow-global.name
}
 resource "azurerm_network_security_rule" "public-ssh" {
    name                        = "${var.name}-public-SSH"
    priority                    = 1002
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = var.resource_group
    network_security_group_name = azurerm_network_security_group.allow-global.name
}

resource "azurerm_network_security_rule" "public-outgoing" {
    name                        = "${var.name}-public-outgoing"
    priority                    = 1003
    direction                   = "Outbound"
    access                      = "Allow"
    protocol                    = "*"
    source_port_range           = "*"
    destination_port_range      = "*"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = var.resource_group
    network_security_group_name = azurerm_network_security_group.allow-global.name
}

resource "azurerm_network_security_rule" "public-ports" {
    name                        = "${var.name}-public-ports"
    priority                    = 1004
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_ranges      = ["10000-19999", "21", "80", "443", "3000", "8443", "8001", "8070", "8071", "9081", "9090", "9443", "8080"]
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = var.resource_group
    network_security_group_name = azurerm_network_security_group.allow-global.name
}

### Security Group Rules for local traffic #####
resource "azurerm_network_security_rule" "private-incoming-tcp" {
    name                        = "${var.name}-private-incoming-TCP"
    priority                    = 1101
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "*"
    source_address_prefix       = var.vnet_cidr
    destination_address_prefix  = "*"
    resource_group_name         = var.resource_group
    network_security_group_name = azurerm_network_security_group.allow-local.name
}

resource "azurerm_network_security_rule" "private-incoming-udp" {
    name                        = "${var.name}-private-incoming-UDP"
    priority                    = 1102
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Udp"
    source_port_range           = "*"
    destination_port_range      = "*"
    source_address_prefix       = var.vnet_cidr
    destination_address_prefix  = "*"
    resource_group_name         = var.resource_group
    network_security_group_name = azurerm_network_security_group.allow-local.name
}

resource "azurerm_network_security_rule" "private-icmp" {
    name                        = "${var.name}-private-ICMP"
    priority                    = 1103
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Icmp"
    source_port_range           = "*"
    destination_port_range      = "*"
    source_address_prefix       = var.vnet_cidr
    destination_address_prefix  = "*"
    resource_group_name         = var.resource_group
    network_security_group_name = azurerm_network_security_group.allow-local.name
}

resource "azurerm_network_security_rule" "private-outgoing" {
    name                        = "${var.name}-private-outgoing"
    priority                    = 1104
    direction                   = "Outbound"
    access                      = "Allow"
    protocol                    = "*"
    source_port_range           = "*"
    destination_port_range      = "*"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = var.resource_group
    network_security_group_name = azurerm_network_security_group.allow-local.name
}
