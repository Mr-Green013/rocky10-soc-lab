#!/usr/bin/env bash
# บทที่ 1 ขั้นที่ 8: สร้าง VM 9000 "rocky10-golden" สำหรับติดตั้ง Rocky Linux 10 จาก ISO
# รันบน pve-01 ในฐานะ root:
#   bash pve-create-golden.sh                         # ใช้ Rocky ISO ตัวเดียวที่มีใน local:iso
#   bash pve-create-golden.sh Rocky-10.2-x86_64-minimal.iso
set -euo pipefail

VMID=${VMID:-9000}
STORAGE=${STORAGE:-local-lvm}
BRIDGE=${BRIDGE:-vmbr1}
ISO_DIR=/var/lib/vz/template/iso

ISO=${1:-}
if [ -z "$ISO" ]; then
  mapfile -t isos < <(cd "$ISO_DIR" && ls -1 Rocky-10*.iso 2>/dev/null)
  [ "${#isos[@]}" -eq 1 ] || { echo "พบ Rocky ISO ${#isos[@]} ไฟล์ใน $ISO_DIR ให้ระบุชื่อไฟล์เป็น argument" >&2; exit 1; }
  ISO=${isos[0]}
fi
[ -f "$ISO_DIR/$ISO" ] || { echo "ไม่พบ $ISO_DIR/$ISO" >&2; exit 1; }
if qm status "$VMID" >/dev/null 2>&1; then echo "มี VM $VMID อยู่แล้ว" >&2; exit 1; fi

# cpu host: Rocky 10 ต้องการ x86-64-v3 ค่า default (x86-64-v2-AES) จะบูตไม่ขึ้น
qm create "$VMID" \
  --name rocky10-golden \
  --description "Golden image ของ SOC lab: Rocky Linux 10 minimal + cloud-init (บทที่ 1)" \
  --ostype l26 --machine q35 --cpu host \
  --cores 2 --memory 4096 --balloon 0 \
  --scsihw virtio-scsi-single \
  --scsi0 "$STORAGE:20,discard=on,ssd=1,iothread=1" \
  --net0 "virtio,bridge=$BRIDGE" \
  --cdrom "local:iso/$ISO" \
  --boot 'order=scsi0;ide2' \
  --agent enabled=1

qm config "$VMID"
echo
echo "สร้าง VM $VMID แล้ว: เปิด Web UI > $VMID (rocky10-golden) > Console แล้วกด Start"
