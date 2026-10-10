#!/usr/bin/env bash
# บทที่ 1 ขั้นเสริม B: ทำ disk ที่เพิ่มจาก Hyper-V (VHDX บน NVMe ลูกที่สอง) เป็น storage "backup" ของ Proxmox
# รันบน pve-01 ในฐานะ root:  bash pve-add-backup-storage.sh /dev/sdb
# คำเตือน: ข้อมูลทั้งหมดบน disk ที่ระบุจะถูกลบ script จะถามยืนยันด้วยการพิมพ์ชื่อ disk ซ้ำ
set -euo pipefail

DEV=${1:?ใช้: $0 /dev/sdX   (ดูด้วย lsblk ก่อน)}
MNT=${MNT:-/mnt/pve-backup}
STORE=${STORE:-backup}
KEEP=${KEEP:-3}

[ "$(id -u)" -eq 0 ] || { echo "ต้องรันในฐานะ root" >&2; exit 1; }
[ -b "$DEV" ] || { echo "$DEV ไม่ใช่ block device" >&2; exit 1; }
[ "$(lsblk -dno TYPE "$DEV")" = disk ] || { echo "$DEV ไม่ใช่ทั้ง disk (ระบุแบบ /dev/sdb ไม่ใช่ /dev/sdb1)" >&2; exit 1; }

# ป้องกันการลบ disk ระบบ: disk ที่มี / หรือ LVM ของ Proxmox อยู่
root_disk=$(lsblk -no PKNAME "$(pvs --noheadings -o pv_name 2>/dev/null | awk 'NR==1{print $1}')" 2>/dev/null || true)
if [ "/dev/${root_disk}" = "$DEV" ]; then echo "$DEV คือ disk ระบบของ Proxmox ห้ามใช้" >&2; exit 1; fi
if [ "$(lsblk -nro NAME "$DEV" | wc -l)" -gt 1 ]; then
  echo "$DEV มี partition อยู่แล้ว:" >&2; lsblk "$DEV" >&2
  echo "ถ้าแน่ใจว่าไม่ใช้แล้ว ลบด้วย: wipefs -a $DEV  แล้วรันใหม่" >&2; exit 1
fi
if pvesm status 2>/dev/null | awk -v s="$STORE" '$1==s{f=1} END{exit !f}'; then
  echo "มี storage ชื่อ $STORE อยู่แล้ว" >&2; exit 1
fi

lsblk -o NAME,SIZE,MODEL "$DEV"
read -r -p "ลบข้อมูลทั้งหมดบน $DEV แล้วทำเป็น backup storage? พิมพ์ $DEV เพื่อยืนยัน: " ans
[ "$ans" = "$DEV" ] || { echo "ยกเลิก"; exit 1; }

sgdisk --zap-all "$DEV" >/dev/null
sgdisk -n 1:0:0 -t 1:8300 -c 1:pve-backup "$DEV" >/dev/null
partprobe "$DEV"; udevadm settle
PART=$(lsblk -nrpo NAME "$DEV" | sed -n 2p)
mkfs.ext4 -q -L pve-backup "$PART"
UUID=$(blkid -s UUID -o value "$PART")

mkdir -p "$MNT"
grep -q "$UUID" /etc/fstab || echo "UUID=$UUID $MNT ext4 defaults,nofail 0 2" >> /etc/fstab
systemctl daemon-reload
mount "$MNT"

# is_mountpoint: ถ้า disk ไม่ถูก mount Proxmox จะไม่เขียน backup ลง root filesystem แทน
pvesm add dir "$STORE" --path "$MNT" --content backup --is_mountpoint yes --prune-backups "keep-last=$KEEP"
pvesm status | awk -v s="$STORE" 'NR==1 || $1==s'
echo "พร้อมแล้ว: bash pve-backup.sh"
