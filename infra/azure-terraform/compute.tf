resource "azurerm_network_interface" "vm" {
  for_each = local.vms

  name                = "nic-${each.key}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.lab.id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.ip
    public_ip_address_id          = each.value.public ? azurerm_public_ip.admin.id : null
  }

  tags = local.common_tags
}

# EN: Accept the marketplace image terms (once per subscription)
# ยอมรับ terms ของ marketplace image (ครั้งเดียวต่อ subscription)
resource "azurerm_marketplace_agreement" "rocky" {
  count = local.use_marketplace_image && var.image.plan_required && var.accept_marketplace_terms ? 1 : 0

  publisher = var.image.publisher
  offer     = var.image.offer
  plan      = var.image.sku
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = local.vms

  name                  = "vm-${each.key}"
  computer_name         = each.key
  location              = azurerm_resource_group.lab.location
  resource_group_name   = azurerm_resource_group.lab.name
  size                  = each.value.size
  network_interface_ids = [azurerm_network_interface.vm[each.key].id]

  admin_username                  = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = local.admin_ssh_public_key
  }

  os_disk {
    name                 = "osdisk-${each.key}"
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = each.value.disk_gb
  }

  source_image_id = local.use_marketplace_image ? null : var.image.image_id

  dynamic "source_image_reference" {
    for_each = local.use_marketplace_image ? [1] : []
    content {
      publisher = var.image.publisher
      offer     = var.image.offer
      sku       = var.image.sku
      version   = var.image.version
    }
  }

  dynamic "plan" {
    for_each = local.use_marketplace_image && var.image.plan_required ? [1] : []
    content {
      publisher = var.image.publisher
      product   = var.image.offer
      name      = var.image.sku
    }
  }

  # EN: cloud-init: hostname/FQDN, timezone, /etc/hosts, base packages, firewalld, SELinux enforcing
  # cloud-init: hostname/FQDN, timezone, /etc/hosts, package พื้นฐาน, firewalld, SELinux enforcing
  custom_data = base64encode("#cloud-config\n${yamlencode(local.cloud_init[each.key])}")

  # EN: managed storage: view the console log and use the Serial Console when SSH does not work
  # managed storage: ดู console log และใช้ Serial Console ตอน SSH เข้าไม่ได้
  boot_diagnostics {}

  tags = merge(local.common_tags, {
    role = each.value.role
  })

  depends_on = [
    azurerm_marketplace_agreement.rocky,
    azurerm_subnet_nat_gateway_association.lab,
    azurerm_subnet_network_security_group_association.lab,
  ]

  lifecycle {
    # EN: cloud-init is used only when the machine is created; changing locals later should not recreate the VM
    # cloud-init ใช้แค่ตอนสร้างเครื่อง แก้ locals ภายหลังไม่ควรทำให้ VM ถูกสร้างใหม่
    ignore_changes = [custom_data]
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm" {
  for_each = var.auto_shutdown.enabled ? local.vms : {}

  virtual_machine_id    = azurerm_linux_virtual_machine.vm[each.key].id
  location              = azurerm_resource_group.lab.location
  enabled               = true
  daily_recurrence_time = var.auto_shutdown.time
  timezone              = var.auto_shutdown.timezone

  notification_settings {
    enabled         = var.auto_shutdown.email != null
    email           = var.auto_shutdown.email
    time_in_minutes = 30
  }

  tags = local.common_tags
}
