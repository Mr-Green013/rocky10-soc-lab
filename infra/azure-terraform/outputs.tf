output "admin_public_ip" {
  description = "Public IP ของ admin-01 (jump host)"
  value       = azurerm_public_ip.admin.ip_address
}

output "nat_public_ip" {
  description = "IP ที่ lab ใช้ออก internet (ใส่ใน allowlist ของบริการภายนอกได้)"
  value       = azurerm_public_ip.nat.ip_address
}

output "private_ips" {
  description = "IP ภายในของแต่ละเครื่อง"
  value       = { for name, h in local.vms : name => h.ip }
}

output "vm_sizes" {
  description = "ขนาด VM ที่ใช้จริง"
  value       = { for name, h in local.vms : name => h.size }
}

output "ssh_config" {
  description = "นำไปต่อท้าย ~/.ssh/config เพื่อ SSH ผ่าน admin-01 ด้วยชื่อเครื่อง"
  value = join("\n", concat(
    [
      "Host ${var.prefix}-admin admin-01",
      "  HostName ${azurerm_public_ip.admin.ip_address}",
      "  User ${var.admin_username}",
      "",
    ],
    flatten([
      for name, h in local.vms : [
        "Host ${name}",
        "  HostName ${h.ip}",
        "  User ${var.admin_username}",
        "  ProxyJump ${var.prefix}-admin",
        "",
      ] if !h.public
    ])
  ))
}

output "web_ui_tunnels" {
  description = "เปิด Web UI ผ่าน SSH tunnel (Graylog, Wazuh dashboard, WordPress)"
  value       = "ssh -N -L 9000:${local.hosts["graylog-01"].ip}:9000 -L 8443:${local.hosts["wazuh-01"].ip}:443 -L 8081:${local.hosts["node-01"].ip}:8081 ${var.prefix}-admin"
}

output "dns_mode" {
  description = "DNS ที่ VNet แจกให้เครื่องใน lab"
  value       = var.use_ipa_dns ? "FreeIPA (${local.ipa_ip})" : "Azure-provided DNS"
}
