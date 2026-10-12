#!/usr/bin/env bash
# บทที่ 3: ให้ chrony บน pve-01 เป็น NTP server ของ lab (192.168.10.0/24)
# รันบน pve-01 ในฐานะ root:  bash pve-ntp-server.sh
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันในฐานะ root" >&2; exit 1; }
command -v chronyd >/dev/null || apt-get -y install chrony
grep -q '^confdir /etc/chrony/conf.d' /etc/chrony/chrony.conf || echo 'confdir /etc/chrony/conf.d' >> /etc/chrony/chrony.conf
mkdir -p /etc/chrony/conf.d
cat > /etc/chrony/conf.d/soclab.conf <<'CONF'
# SOC lab: ให้เครื่องใน 192.168.10.0/24 sync เวลาจาก pve-01
allow 192.168.10.0/24
# ถ้า internet ขาด ยังแจกเวลาของตัวเองต่อ (stratum 10 = ต่ำกว่าแหล่งจริงเสมอ)
local stratum 10
CONF
systemctl restart chrony
sleep 3
chronyc tracking | sed -n '1,4p'
echo
echo "ฟัง NTP ที่:"; ss -ulnp | grep -E ':123\b' || echo "  !! chrony ไม่ได้ฟัง UDP 123"
