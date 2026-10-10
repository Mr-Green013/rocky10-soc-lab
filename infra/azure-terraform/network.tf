resource "azurerm_resource_group" "lab" {
  name     = "rg-${var.prefix}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "lab" {
  name                = "vnet-${var.prefix}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = [var.vnet_cidr]

  # [] = Azure-provided DNS; หลัง Lab 11 ตั้ง use_ipa_dns = true แล้ว reboot หรือ renew DHCP ทุกเครื่อง
  dns_servers = var.use_ipa_dns ? [local.ipa_ip] : []

  tags = local.common_tags
}

resource "azurerm_subnet" "lab" {
  name                 = "snet-lab"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = [var.lab_subnet_cidr]

  # ออก internet ผ่าน NAT Gateway เท่านั้น (ไม่พึ่ง default outbound access ที่ Azure กำลังเลิกใช้)
  default_outbound_access_enabled = false
}

#
# NSG: เข้าจาก internet ได้ทางเดียวคือ SSH เข้า admin-01 จาก IP ที่ระบุ
# ภายใน VNet คุยกันได้ทั้งหมดผ่าน default rule AllowVnetInBound (firewalld ในเครื่องเป็นตัวคุมต่อ)
#
resource "azurerm_network_security_group" "lab" {
  name                = "nsg-${var.prefix}-lab"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  security_rule {
    name                       = "allow-ssh-admin-to-jump"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.admin_source_cidrs
    destination_address_prefix = local.hosts["admin-01"].ip
  }

  tags = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "lab" {
  subnet_id                 = azurerm_subnet.lab.id
  network_security_group_id = azurerm_network_security_group.lab.id
}

#
# NAT Gateway สำหรับ outbound (dnf, docker pull, Cloudflare Tunnel, LINE/Telegram API, Gmail 587)
#
resource "azurerm_public_ip" "nat" {
  name                = "pip-${var.prefix}-nat"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_nat_gateway" "lab" {
  name                    = "ng-${var.prefix}"
  location                = azurerm_resource_group.lab.location
  resource_group_name     = azurerm_resource_group.lab.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  tags                    = local.common_tags
}

resource "azurerm_nat_gateway_public_ip_association" "lab" {
  nat_gateway_id       = azurerm_nat_gateway.lab.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "lab" {
  subnet_id      = azurerm_subnet.lab.id
  nat_gateway_id = azurerm_nat_gateway.lab.id
}

resource "azurerm_public_ip" "admin" {
  name                = "pip-${var.prefix}-admin"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}
