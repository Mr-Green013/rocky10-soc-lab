#!/usr/bin/env bash
# เปิด / ปิด / ดูสถานะเครื่องใน lab ตามลำดับที่ถูกต้อง (ipa-01 ขึ้นก่อน ลงทีหลัง)
# รันบน pve-01 ในฐานะ root:
#   bash pve-lab-power.sh status
#   bash pve-lab-power.sh start [ชื่อเครื่อง...]
#   bash pve-lab-power.sh stop  [ชื่อเครื่อง...]
set -euo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
HOSTS_CSV=${HOSTS_CSV:-$HERE/../../lab-hosts.csv}
ACTION=${1:-status}; shift || true
NAMES=("$@")

# vmid name order  เรียงตาม startup_order
mapfile -t rows < <(tr -d '\r' < "$HOSTS_CSV" | awk -F, 'NR>1 && $1!="" {print $7" "$1" "$2}' | sort -n)

# พิมพ์ "vmid name" ของเครื่องที่เลือก (ไม่ระบุชื่อ = ทุกเครื่อง) ตามลำดับ startup_order
select_rows() {
  local r id name n
  for r in "${rows[@]}"; do
    read -r _ id name <<< "$r"
    if [ "${#NAMES[@]}" -eq 0 ]; then echo "$id $name"; continue; fi
    for n in "${NAMES[@]}"; do [ "$n" = "$name" ] && echo "$id $name"; done
  done
}

case "$ACTION" in
  status)
    printf '%-6s %-14s %-9s %s\n' VMID NAME STATUS MEM_MB
    while read -r id name; do
      st=$(qm status "$id" 2>/dev/null | awk '{print $2}'); st=${st:-missing}
      mem=$(qm config "$id" 2>/dev/null | awk -F': ' '/^memory:/{print $2}')
      printf '%-6s %-14s %-9s %s\n' "$id" "$name" "$st" "${mem:--}"
    done < <(select_rows)
    free -h | sed -n '1,2p' ;;
  start)
    while read -r id name; do
      [ "$(qm status "$id" 2>/dev/null | awk '{print $2}')" = running ] && { echo "running  $name"; continue; }
      qm start "$id" && echo "started  $name"
      [ "$name" = ipa-01 ] && sleep 20      # ให้ DNS/LDAP ของ FreeIPA พร้อมก่อน (ตั้งแต่บทที่ 7)
    done < <(select_rows) ;;
  stop)
    # ปิดย้อนลำดับ: เครื่องอื่นก่อน ipa-01 ทีหลัง
    while read -r id name; do
      [ "$(qm status "$id" 2>/dev/null | awk '{print $2}')" = running ] || continue
      qm shutdown "$id" --timeout 120 && echo "stopped  $name"
    done < <(select_rows | tac) ;;
  *) sed -n '2,6p' "$0"; exit 1 ;;
esac
