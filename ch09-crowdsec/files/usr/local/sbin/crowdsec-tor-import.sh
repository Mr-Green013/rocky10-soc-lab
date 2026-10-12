#!/usr/bin/env bash
set -euo pipefail
URL="https://check.torproject.org/torbulkexitlist"
TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT
curl -fsS --max-time 30 "$URL" -o "$TMP"
grep -E '^[0-9]{1,3}(\.[0-9]{1,3}){3}$' "$TMP" | sort -u > "$TMP.clean"
n=$(wc -l < "$TMP.clean")
if (( n < 100 )); then
  echo "tor list too small ($n lines), keeping previous decisions" >&2
  rm -f "$TMP.clean"; exit 1
fi
cscli decisions import -i "$TMP.clean" --format values \
  --duration 13h --type ban --reason "tor-exit-node"
rm -f "$TMP.clean"
echo "imported $n tor exit nodes"
