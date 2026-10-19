#!/usr/bin/env bash
# EN: Chapter 2: set an FQDN hostname, the lab-wide /etc/hosts and a NetworkManager profile named "lab"
# บทที่ 2: ตั้ง hostname แบบ FQDN, /etc/hosts ของทั้ง lab และ NetworkManager profile ชื่อ "lab"
# EN: Run as root on a lab machine: sudo bash set-identity.sh [/path/lab-hosts.csv]
# รันในฐานะ root บนเครื่องใน lab: sudo bash set-identity.sh [/path/lab-hosts.csv]
# EN: Invoke-SocLabScript.ps1 copies lab-hosts.csv next to the script automatically
# Invoke-SocLabScript.ps1 คัดลอก lab-hosts.csv ไปไว้ข้าง script ให้อัตโนมัติ
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
CSV=${1:-$HERE/lab-hosts.csv}
DOMAIN=${DOMAIN:-lab.internal}
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo" >&2; exit 1; }
[ -f "$CSV" ] || { echo "ไม่พบ $CSV" >&2; exit 1; }

# EN: --- 1. Work out which machine this is from its IP ---
# --- 1. หาว่าเครื่องนี้คือเครื่องไหนจาก IP ---------------------------------------
dev=$(ip -4 route show default | awk '{print $5; exit}')
my_ip=$(ip -4 -o addr show dev "$dev" scope global | awk '{print $4}' | cut -d/ -f1 | head -1)
name=$(tr -d '\r' < "$CSV" | awk -F, -v ip="$my_ip" 'NR>1 && $3==ip {print $2}')
[ -n "$name" ] || { echo "IP $my_ip ไม่อยู่ใน $CSV" >&2; exit 1; }
fqdn="$name.$DOMAIN"
echo "==> เครื่องนี้คือ $fqdn ($my_ip บน $dev)"

# --- 2. hostname -----------------------------------------------------------------
hostnamectl set-hostname "$fqdn"

# EN: --- 3. /etc/hosts: the FQDN must resolve to the real IP, not 127.0.0.1 ---
# --- 3. /etc/hosts: FQDN ต้อง resolve เป็น IP จริง ไม่ใช่ 127.0.0.1 ------------------
[ -f /etc/hosts.soclab.bak ] || cp -a /etc/hosts /etc/hosts.soclab.bak
{
  echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4"
  echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6"
  echo ""
  echo "# SOC lab (สร้างโดย ch02 set-identity.sh)"
  echo "192.168.10.1    pve-01.$DOMAIN pve-01"
  echo "192.168.10.100  admin-ws.$DOMAIN admin-ws"
  tr -d '\r' < "$CSV" | awk -F, -v d="$DOMAIN" 'NR>1 && $1!="" {printf "%-15s %s.%s %s\n", $3, $2, d, $2}'
} > /etc/hosts.new
mv /etc/hosts.new /etc/hosts
restorecon /etc/hosts 2>/dev/null || true

# EN: --- 4. NetworkManager: rename the profile cloud-init created to "lab" ---
# --- 4. NetworkManager: เปลี่ยนชื่อ profile ที่ cloud-init สร้างเป็น "lab" ----------
con=$(nmcli -g GENERAL.CONNECTION device show "$dev")
if [ "$con" != "lab" ]; then
  nmcli connection modify "$con" connection.id lab
  echo "    เปลี่ยนชื่อ connection '$con' เป็น 'lab'"
fi
nmcli connection modify lab ipv4.dns-search "$DOMAIN" connection.autoconnect yes
# EN: reapply uses the new settings without dropping the connection (the current SSH session stays up)
# reapply ใช้ค่าใหม่โดยไม่ตัด connection (SSH ที่ใช้อยู่ไม่หลุด)
nmcli device reapply "$dev"

echo "==> hostname -f = $(hostname -f), hostname -i = $(hostname -i)"
