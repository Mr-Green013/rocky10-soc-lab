#!/usr/bin/env bash
# สร้าง / ดู / rollback snapshot ของทุกเครื่องใน lab พร้อมกัน
# รันบน pve-01 ในฐานะ root:
#   bash pve-snapshot.sh ch01-base            # snapshot ทุกเครื่อง
#   bash pve-snapshot.sh --list
#   bash pve-snapshot.sh --rollback ch01-base # กลับไปที่ snapshot (เครื่องจะถูก stop ก่อน)
set -euo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
HOSTS_CSV=${HOSTS_CSV:-$HERE/../../lab-hosts.csv}
mapfile -t VMIDS < <(tr -d '\r' < "$HOSTS_CSV" | awk -F, 'NR>1 && $1!="" {print $1}')

case "${1:-}" in
  ""|-h|--help)
    sed -n '2,6p' "$0"; exit 0 ;;
  --list)
    for id in "${VMIDS[@]}"; do
      qm status "$id" >/dev/null 2>&1 || continue
      echo "== $id $(qm config "$id" | awk '/^name:/{print $2}')"
      qm listsnapshot "$id"
    done ;;
  --rollback)
    snap=${2:?ระบุชื่อ snapshot}
    read -r -p "rollback ทุกเครื่องไปที่ '$snap'? การเปลี่ยนแปลงหลัง snapshot จะหายทั้งหมด [y/N] " ok
    [ "$ok" = y ] || exit 1
    for id in "${VMIDS[@]}"; do
      qm status "$id" >/dev/null 2>&1 || continue
      qm stop "$id" >/dev/null 2>&1 || true
      qm rollback "$id" "$snap" && echo "rolled back $id"
      qm start "$id"
    done ;;
  *)
    snap=$1
    [[ "$snap" =~ ^[A-Za-z][A-Za-z0-9_-]{1,39}$ ]] || { echo "ชื่อ snapshot ต้องขึ้นต้นด้วยตัวอักษร ใช้ a-z 0-9 - _ ได้" >&2; exit 1; }
    for id in "${VMIDS[@]}"; do
      qm status "$id" >/dev/null 2>&1 || { echo "skip $id (ไม่มี VM)"; continue; }
      qm snapshot "$id" "$snap" --description "$(date -Is) $(hostname)" && echo "snapshot $id $snap"
    done ;;
esac
