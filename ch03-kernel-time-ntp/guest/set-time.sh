#!/usr/bin/env bash
# EN: Chapter 3: timezone Asia/Bangkok, with chrony using pve-01 as the main time source
# บทที่ 3: timezone Asia/Bangkok และให้ chrony ใช้ pve-01 เป็นแหล่งเวลาหลัก
# EN: Run as root: sudo bash set-time.sh
# รันในฐานะ root: sudo bash set-time.sh
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo" >&2; exit 1; }
CONF=/etc/chrony.conf

timedatectl set-timezone Asia/Bangkok
rpm -q chrony >/dev/null || dnf -y install chrony
[ -f "$CONF.soclab.bak" ] || cp -a "$CONF" "$CONF.soclab.bak"

# EN: Remove the old lab block (if any), disable the distro pool/server, then add the new block; safe to rerun
# ลบบล็อกของ lab เดิม (ถ้ามี) ปิด pool/server ของ distro แล้วใส่บล็อกใหม่ ทำซ้ำได้
# EN: chrony does not accept end-of-line comments, so a separate marker line is used
# chrony ไม่รับ comment ท้ายบรรทัด จึงใช้บรรทัด marker แยก
sed -i '/^# SOCLAB-BEGIN/,/^# SOCLAB-END/d' "$CONF"
sed -i -E 's/^(pool|server)[[:space:]]/#&/' "$CONF"
cat >> "$CONF" <<'CONFEOF'
# SOCLAB-BEGIN  แหล่งเวลาของห้องแลป: pve-01 ก่อน, pool ของไทยเป็นสำรอง (EN: lab time sources: pve-01 first, the Thai pool as a backup)
server 192.168.10.1 iburst prefer
pool th.pool.ntp.org iburst
# SOCLAB-END
CONFEOF

systemctl enable --now chronyd >/dev/null
systemctl restart chronyd
timedatectl set-ntp true
chronyc waitsync 6 0.5 >/dev/null 2>&1 || true
timedatectl | grep -E 'Time zone|synchronized'
chronyc sources
