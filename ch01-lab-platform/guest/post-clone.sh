#!/usr/bin/env bash
# บทที่ 1 ขั้นที่ 11: งานหลัง clone ครั้งแรกของแต่ละเครื่อง (Initialize-SocLab.ps1 เรียกให้)
#   1) รอ cloud-init ทำงานเสร็จ
#   2) ขยาย root filesystem ให้เต็ม disk ที่ resize ไว้ (LVM: partition -> PV -> LV -> XFS)
#   3) ปิด cloud-init เพื่อให้การตั้งค่าในบทต่อไป (nmcli, hostnamectl) ไม่ถูกเขียนทับ
#   4) ติดตั้ง soclab-check ไว้ที่ /usr/local/sbin
# รันในฐานะ root: sudo bash post-clone.sh
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo" >&2; exit 1; }
HERE=$(cd "$(dirname "$0")" && pwd)

echo "==> รอ cloud-init"
rc=0; cloud-init status --wait >/dev/null || rc=$?
# 0 = done, 2 = done แต่มี warning (เช่น deprecated key) ถือว่าผ่าน
case $rc in 0|2) echo "    cloud-init: $(cloud-init status | awk '/status:/{print $2}')";; *) echo "    cloud-init ผิดพลาด (rc=$rc) ดู /var/log/cloud-init.log" >&2; exit 1;; esac

echo "==> ขยาย root filesystem"
root_src=$(findmnt -no SOURCE /)
if lvs "$root_src" >/dev/null 2>&1; then
  vg=$(lvs --noheadings -o vg_name "$root_src" | tr -d ' ')
  pv=$(pvs --noheadings -o pv_name -S "vg_name=$vg" | head -1 | tr -d ' ')
  part=$(basename "$(readlink -f "$pv")")
  disk=/dev/$(lsblk -no PKNAME "/dev/$part" | head -1)
  num=$(cat "/sys/class/block/$part/partition")
  growpart "$disk" "$num" || true          # exit 1 = NOCHANGE (โตเต็มแล้ว)
  pvresize "$pv" >/dev/null
  free=$(vgs --noheadings --units b --nosuffix -o vg_free "$vg" | tr -d ' ')
  if [ "${free:-0}" -gt 0 ]; then
    lvextend -r -l +100%FREE "$root_src"
  fi
fi
df -h / | sed 's/^/    /'

echo "==> ปิด cloud-init หลังบูตครั้งแรก"
touch /etc/cloud/cloud-init.disabled

if [ -f "$HERE/soclab-check.sh" ]; then
  sed 's/\r$//' "$HERE/soclab-check.sh" > /usr/local/sbin/soclab-check
  chmod 0755 /usr/local/sbin/soclab-check
  echo "==> ติดตั้ง /usr/local/sbin/soclab-check"
fi
echo "==> เสร็จ: $(hostname)"
