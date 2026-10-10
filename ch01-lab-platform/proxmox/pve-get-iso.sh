#!/usr/bin/env bash
# บทที่ 1 ขั้นที่ 8: ดาวน์โหลด ISO ลง storage "local" ของ Proxmox พร้อมตรวจ SHA-256
# รันบน pve-01 ในฐานะ root:
#   bash pve-get-iso.sh https://download.rockylinux.org/pub/rocky/10/isos/x86_64/Rocky-10.2-x86_64-minimal.iso
# script ดาวน์โหลดไฟล์ CHECKSUM จาก directory เดียวกันมาเทียบ (รูปแบบของ Rocky Linux)
set -euo pipefail

URL=${1:?ใช้: $0 <url-ของ-iso>}
ISO_DIR=/var/lib/vz/template/iso
NAME=$(basename "$URL")
SUMS_URL="$(dirname "$URL")/CHECKSUM"

mkdir -p "$ISO_DIR"
cd "$ISO_DIR"
echo "ดาวน์โหลด $NAME -> $ISO_DIR"
curl -fL --retry 3 -C - -o "$NAME" "$URL"

echo "ตรวจ SHA-256 กับ $SUMS_URL"
expected=$(curl -fsSL "$SUMS_URL" | sed -n "s/^SHA256 ($NAME) = \([0-9a-f]\{64\}\)$/\1/p")
[ -n "$expected" ] || { echo "ไม่พบ hash ของ $NAME ใน CHECKSUM ตรวจเองด้วย sha256sum" >&2; exit 2; }
actual=$(sha256sum "$NAME" | awk '{print $1}')
if [ "$expected" = "$actual" ]; then
  echo "OK  $actual"
  echo "ใช้ใน Proxmox ได้ในชื่อ  local:iso/$NAME"
else
  echo "HASH ไม่ตรง: expected $expected actual $actual  ลบไฟล์แล้วดาวน์โหลดใหม่" >&2
  exit 1
fi
