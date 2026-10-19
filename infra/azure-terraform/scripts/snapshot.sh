#!/usr/bin/env bash
# EN: Incremental snapshot of every machine's OS disk, in place of the snapshots in the course documents
# snapshot แบบ incremental ของ OS disk ทุกเครื่อง ใช้แทน snapshot ในเอกสารหลักสูตร
# EN: Usage: ./scripts/snapshot.sh m05-done (default RG = rg-soclab)
# ใช้: ./scripts/snapshot.sh m05-done        (ค่า RG default = rg-soclab)
set -euo pipefail
LABEL="${1:?ระบุชื่อ snapshot เช่น m05-done}"
RG="${RG:-rg-soclab}"

for d in $(az disk list -g "$RG" --query "[?starts_with(name, 'osdisk-')].name" -o tsv); do
  host="${d#osdisk-}"
  az snapshot create -g "$RG" -n "snap-${LABEL}-${host}" --source "$d" \
    --incremental true --tags label="$LABEL" host="$host" -o none
  echo "snap-${LABEL}-${host}"
done
