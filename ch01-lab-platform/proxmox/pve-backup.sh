#!/usr/bin/env bash
# EN: Chapter 1 optional step B: back up the lab VMs and the template to the "backup" storage with vzdump
# บทที่ 1 ขั้นเสริม B: backup VM ของ lab และ template ไปที่ storage "backup" ด้วย vzdump
# EN: Run on pve-01 as root:
# รันบน pve-01 ในฐานะ root:
#   bash pve-backup.sh                 # ทุกเครื่องใน lab-hosts.csv + template 9000 (EN: every machine in lab-hosts.csv + template 9000)
#   bash pve-backup.sh ipa-01 node-01  # เฉพาะบางเครื่อง (EN: only some machines)
# EN: mode snapshot: back up while the VM is running, without stopping it
# mode snapshot: backup ได้ขณะ VM รันอยู่ โดย VM ไม่ต้องหยุด
set -euo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
HOSTS_CSV=${HOSTS_CSV:-$HERE/../../lab-hosts.csv}
STORE=${STORE:-backup}
TEMPLATE=${TEMPLATE:-9000}
NOTE=${NOTE:-manual}

pvesm status 2>/dev/null | awk -v s="$STORE" '$1==s && $3=="active"{f=1} END{exit !f}' \
  || { echo "ไม่พบ storage $STORE ที่ active (รัน pve-add-backup-storage.sh ก่อน)" >&2; exit 1; }

want=" $* "
ids=()
while IFS=, read -r vmid name _; do
  [ "$vmid" = vmid ] || [ -z "$vmid" ] && continue
  [ $# -gt 0 ] && [[ "$want" != *" $name "* ]] && continue
  qm status "$vmid" >/dev/null 2>&1 && ids+=("$vmid")
done < <(tr -d '\r' < "$HOSTS_CSV")
[ $# -eq 0 ] && qm status "$TEMPLATE" >/dev/null 2>&1 && ids+=("$TEMPLATE")
[ "${#ids[@]}" -gt 0 ] || { echo "ไม่มี VM ให้ backup" >&2; exit 1; }

echo "backup: ${ids[*]} -> $STORE"
vzdump "${ids[@]}" --storage "$STORE" --mode snapshot --compress zstd \
  --notes-template "{{guestname}} $NOTE $(date +%F)"
echo
pvesm list "$STORE"
