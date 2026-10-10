#!/usr/bin/env bash
# บทที่ 1 ขั้นที่ 10: clone เครื่องทั้ง 6 ของ lab จาก template rocky10-tpl ตาม lab-hosts.csv
# รันบน pve-01 ในฐานะ root:
#   bash pve-clone-lab.sh                 # ทุกเครื่องใน lab-hosts.csv
#   bash pve-clone-lab.sh ipa-01 node-01  # เฉพาะบางเครื่อง
#   DRY_RUN=1 bash pve-clone-lab.sh       # แสดงคำสั่งโดยไม่ทำจริง
# เครื่องที่มีอยู่แล้ว (VM ID ซ้ำ) จะถูกข้าม ไม่ถูกเขียนทับ
set -euo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
HOSTS_CSV=${HOSTS_CSV:-$HERE/../../lab-hosts.csv}
TEMPLATE=${TEMPLATE:-9000}
STORAGE=${STORAGE:-local-lvm}
SSH_KEY=${SSH_KEY:-/root/aod.pub}
CI_USER=${CI_USER:-aod}
GATEWAY=${GATEWAY:-192.168.10.1}
DNS=${DNS:-1.1.1.1}
DOMAIN=${DOMAIN:-lab.internal}
START=${START:-1}

run() { if [ "${DRY_RUN:-0}" = 1 ]; then echo "+ $*"; else "$@"; fi; }

[ -f "$HOSTS_CSV" ] || { echo "ไม่พบ $HOSTS_CSV (ตั้ง HOSTS_CSV=<path>)" >&2; exit 1; }
if [ "${DRY_RUN:-0}" != 1 ]; then
  [ -s "$SSH_KEY" ] || { echo "ไม่พบ SSH public key ที่ $SSH_KEY (คัดลอกจาก Windows ตามขั้นที่ 7)" >&2; exit 1; }
  grep -qE '^(ssh-ed25519|ssh-rsa|ecdsa-sha2-)' "$SSH_KEY" || { echo "$SSH_KEY ไม่ใช่ public key" >&2; exit 1; }
  qm config "$TEMPLATE" | grep -q '^template: 1' || { echo "VM $TEMPLATE ยังไม่เป็น template (รัน pve-make-template.sh)" >&2; exit 1; }
  # cloud-init ของ Rocky ล็อก password ของผู้ใช้หลักเสมอ ถ้าไม่ตั้งใหม่จะ login ที่ console ไม่ได้
  # ส่งให้ Proxmox เป็น hash (SHA-512) เท่านั้น ไม่มี password จริงอยู่ใน config หรือ process list
  if [ -z "${CI_PASSWORD_HASH:-}" ]; then
    read -r -s -p "ตั้ง password ของ $CI_USER สำหรับทุกเครื่อง (อย่างน้อย 12 ตัวอักษร): " p1; echo
    read -r -s -p "พิมพ์อีกครั้ง: " p2; echo
    [ "$p1" = "$p2" ] || { echo "password ไม่ตรงกัน" >&2; exit 1; }
    [ "${#p1}" -ge 12 ] || { echo "password สั้นเกินไป" >&2; exit 1; }
    CI_PASSWORD_HASH=$(printf '%s' "$p1" | openssl passwd -6 -stdin)
    unset p1 p2
  fi
else
  CI_PASSWORD_HASH='<sha512-hash>'
fi

want=" $* "
created=()
while IFS=, read -r vmid name ip cores mem disk order role; do
  [ "$vmid" = vmid ] && continue                     # header
  [ -z "$vmid" ] && continue
  [ $# -gt 0 ] && [[ "$want" != *" $name "* ]] && continue
  if [ "${DRY_RUN:-0}" != 1 ] && qm status "$vmid" >/dev/null 2>&1; then
    echo "skip  $vmid $name (มีอยู่แล้ว)"; continue
  fi
  echo "==> $vmid $name  $ip  ${cores}c/${mem}MB/${disk}GB  ($role)"
  run qm clone "$TEMPLATE" "$vmid" --name "$name" --full 1 --storage "$STORAGE"
  run qm set "$vmid" --cores "$cores" --memory "$mem" \
      --description "SOC lab: $role" --tags "soclab" \
      --onboot 1 --startup "order=$order" \
      --ciuser "$CI_USER" --cipassword "$CI_PASSWORD_HASH" \
      --sshkeys "$SSH_KEY" --ciupgrade 0 \
      --ipconfig0 "ip=$ip/24,gw=$GATEWAY" \
      --nameserver "$DNS" --searchdomain "$DOMAIN"
  run qm disk resize "$vmid" scsi0 "${disk}G"
  [ "$START" = 1 ] && run qm start "$vmid"
  created+=("$name")
done < <(tr -d '\r' < "$HOSTS_CSV")

echo
echo "สร้างแล้ว ${#created[@]} เครื่อง: ${created[*]:-ไม่มี}"
echo "cloud-init ใช้เวลาบูตครั้งแรก 1-3 นาที แล้วรัน windows\\Initialize-SocLab.ps1 บน Windows"
