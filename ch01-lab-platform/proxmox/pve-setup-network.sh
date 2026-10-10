#!/usr/bin/env bash
# บทที่ 1 ขั้นที่ 6: สร้าง bridge vmbr1 (192.168.10.1/24) สำหรับ lab และ NAT ออก internet ทาง vmbr0
# รันบน pve-01 ในฐานะ root:
#   bash pve-setup-network.sh               # หา NIC ตัวที่สองให้อัตโนมัติ
#   LAB_NIC=eth1 bash pve-setup-network.sh   # ระบุชื่อ NIC เอง
#   LAB_MAC=00:15:5d:xx:xx:xx bash pve-setup-network.sh   # ระบุด้วย MAC จาก output ของ Hyper-V script
set -euo pipefail

LAB_CIDR=${LAB_CIDR:-192.168.10.1/24}
LAB_NET=${LAB_NET:-192.168.10.0/24}
UPLINK=${UPLINK:-vmbr0}
IFACES=/etc/network/interfaces

[ "$(id -u)" -eq 0 ] || { echo "ต้องรันในฐานะ root" >&2; exit 1; }

# --- 1. หา NIC ที่ต่อกับ switch SOC-Lab ----------------------------------------
physical_nics() {   # NIC จริง (มี device ใน sysfs) ที่ไม่ใช่ bridge/bond/vlan
  for d in /sys/class/net/*; do
    [ -e "$d/device" ] && basename "$d"
  done
}
if [ -z "${LAB_NIC:-}" ] && [ -n "${LAB_MAC:-}" ]; then
  want=$(echo "$LAB_MAC" | tr 'A-F-' 'a-f:')
  for n in $(physical_nics); do
    [ "$(cat /sys/class/net/$n/address)" = "$want" ] && LAB_NIC=$n
  done
  [ -n "${LAB_NIC:-}" ] || { echo "ไม่พบ NIC ที่มี MAC $LAB_MAC" >&2; exit 1; }
fi
if [ -z "${LAB_NIC:-}" ]; then
  mapfile -t cands < <(for n in $(physical_nics); do
    [ -e "/sys/class/net/$UPLINK/brif/$n" ] || echo "$n"
  done)
  if [ "${#cands[@]}" -ne 1 ]; then
    echo "หา NIC ของ lab อัตโนมัติไม่ได้ (พบ ${#cands[@]} ตัว: ${cands[*]:-ไม่มี})" >&2
    echo "ดูรายการด้วย 'ip -br link' แล้วระบุ LAB_NIC=<ชื่อ> หรือ LAB_MAC=<mac>" >&2
    exit 1
  fi
  LAB_NIC=${cands[0]}
fi
echo "lab NIC = $LAB_NIC ($(cat /sys/class/net/$LAB_NIC/address)), uplink = $UPLINK"

# --- 2. เขียน /etc/network/interfaces --------------------------------------------
if grep -qE '^iface[[:space:]]+vmbr1[[:space:]]' "$IFACES"; then
  echo "มี vmbr1 ใน $IFACES อยู่แล้ว ไม่แก้ไฟล์ (ลบ stanza เดิมก่อนถ้าต้องการสร้างใหม่)"
else
  cp -a "$IFACES" "$IFACES.bak.$(date +%Y%m%d-%H%M%S)"
  grep -qE "^iface[[:space:]]+${LAB_NIC}[[:space:]]" "$IFACES" || printf '\niface %s inet manual\n' "$LAB_NIC" >> "$IFACES"
  cat >> "$IFACES" <<EOF

# SOC lab: 192.168.10.0/24 บน Hyper-V switch "SOC-Lab", pve-01 เป็น gateway (.1)
auto vmbr1
iface vmbr1 inet static
	address $LAB_CIDR
	bridge-ports $LAB_NIC
	bridge-stp off
	bridge-fd 0
	post-up   iptables -t nat -A POSTROUTING -s $LAB_NET -o $UPLINK -j MASQUERADE
	post-down iptables -t nat -D POSTROUTING -s $LAB_NET -o $UPLINK -j MASQUERADE
EOF
  echo "เพิ่ม vmbr1 ใน $IFACES แล้ว (สำรองไฟล์เดิมไว้ที่ $IFACES.bak.*)"
fi

# --- 3. IP forwarding (ถาวร) และ iptables ----------------------------------------
echo 'net.ipv4.ip_forward = 1' > /etc/sysctl.d/99-soclab-forward.conf
sysctl -q -p /etc/sysctl.d/99-soclab-forward.conf
command -v iptables >/dev/null || apt-get -y install iptables

# --- 4. ใช้ค่าใหม่ ----------------------------------------------------------------
ifreload -a

echo
ip -br addr show "$UPLINK"
ip -br addr show vmbr1
echo "ip_forward = $(cat /proc/sys/net/ipv4/ip_forward)"
iptables -t nat -S POSTROUTING | grep -F -- "-s $LAB_NET" || echo "!! ไม่พบ NAT rule ให้ตรวจด้วย: ifreload -a -d" >&2
