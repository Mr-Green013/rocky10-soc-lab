#!/usr/bin/env bash
# EN: Chapter 1 step 9: convert the prepared VM 9000 (golden-prep.sh) into the "rocky10-tpl" template
# บทที่ 1 ขั้นที่ 9: แปลง VM 9000 ที่เตรียมแล้ว (golden-prep.sh) เป็น template "rocky10-tpl"
# EN: Run on pve-01 as root: bash pve-make-template.sh
# รันบน pve-01 ในฐานะ root:  bash pve-make-template.sh
set -euo pipefail

VMID=${VMID:-9000}
STORAGE=${STORAGE:-local-lvm}

qm config "$VMID" >/dev/null || { echo "ไม่พบ VM $VMID" >&2; exit 1; }
if qm config "$VMID" | grep -q '^template: 1'; then echo "VM $VMID เป็น template อยู่แล้ว"; exit 0; fi
state=$(qm status "$VMID" | awk '{print $2}')
[ "$state" = stopped ] || { echo "VM $VMID ยัง $state อยู่ ให้ golden-prep.sh ปิดเครื่องให้เสร็จก่อน" >&2; exit 1; }

# EN: Remove the ISO and put the cloud-init drive on ide2 instead
# ถอด ISO ออก แล้วใส่ cloud-init drive ที่ ide2 แทน
qm set "$VMID" --delete ide2
qm set "$VMID" --ide2 "$STORAGE:cloudinit"
qm set "$VMID" --name rocky10-tpl --memory 2048 --boot order=scsi0
qm template "$VMID"

qm config "$VMID"
echo
echo "template พร้อมแล้ว: ขั้นต่อไป bash pve-clone-lab.sh"
