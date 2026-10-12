#!/usr/bin/env bash
# บทที่ 10 วิธีตรวจสอบ: Graylog บน Docker, Nginx + TLS จาก IPA และการปิด port 9000  (sudo bash ch10-check.sh)
set -uo pipefail
F=0
ok()  { printf '  [PASS] %s\n' "$*"; }
bad() { printf '  [FAIL] %s\n' "$*"; F=$((F+1)); }
warn(){ printf '  [WARN] %s\n' "$*"; }
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo"; exit 99; }
D=/opt/graylog
FQDN=$(hostname -f)

echo "== host"
mmc=$(sysctl -n vm.max_map_count 2>/dev/null)
if [ "${mmc:-0}" -ge 262144 ]; then ok "vm.max_map_count = $mmc"; else bad "vm.max_map_count = ${mmc:-?} (ต้อง >= 262144)"; fi
if systemctl is-active --quiet docker; then ok "docker active"; else bad "docker ไม่ active"; fi
members=$(getent group docker | cut -d: -f4)
if [ -z "$members" ]; then ok "ไม่มีผู้ใช้ในกลุ่ม docker (ใช้ผ่าน sudo เท่านั้น)"; else warn "กลุ่ม docker มีสมาชิก: $members"; fi
if [ -f "$D/.env" ]; then
  p=$(stat -c '%a' "$D/.env")
  if [ "$p" = 600 ]; then ok ".env สิทธิ์ 600"; else bad ".env สิทธิ์ $p (ต้อง 600)"; fi
else bad "ไม่พบ $D/.env"; fi

echo "== container"
if [ -f "$D/docker-compose.yml" ]; then
  running=$(cd "$D" && docker compose ps --format '{{.Service}} {{.State}}' 2>/dev/null)
  for s in mongodb datanode graylog nginx; do
    if grep -q "^$s running" <<<"$running"; then ok "$s running"; else bad "$s ไม่ running"; fi
  done
  if grep -q '^cloudflared running' <<<"$running"; then
    if (cd "$D" && docker compose logs --tail 200 cloudflared 2>/dev/null | grep -qi 'registered tunnel connection'); then ok "cloudflared เชื่อม tunnel แล้ว"; else bad "cloudflared ยังไม่มี Registered tunnel connection"; fi
  fi
else bad "ไม่พบ $D/docker-compose.yml"; fi
lb=$(curl -s --max-time 5 http://127.0.0.1:9000/api/system/lbstatus)
if [ "$lb" = "ALIVE" ]; then ok "Graylog lbstatus = ALIVE"; else bad "Graylog lbstatus = ${lb:-ไม่ตอบ}"; fi

echo "== การเข้าถึง"
l9000=$(ss -Htln 'sport = :9000' | awk '{print $4}' | sort -u | tr '\n' ' ')
case "$l9000" in
  "127.0.0.1:9000 ") ok "port 9000 ฟังเฉพาะ 127.0.0.1" ;;
  "") bad "ไม่มีอะไรฟัง port 9000" ;;
  *) bad "port 9000 เปิดที่ $l9000(ทำขั้น 16.10)" ;;
esac
if ss -Htln 'sport = :443' | grep -q .; then ok "port 443 เปิด (nginx)"; else bad "port 443 ไม่เปิด"; fi
st=$(getcert list -f /etc/pki/tls/certs/graylog-01.crt 2>/dev/null | awk -F': ' '/status:/ {print $2; exit}')
if [ "$st" = "MONITORING" ]; then ok "certmonger ติดตาม certificate (MONITORING)"; else bad "certificate ของ IPA status = ${st:-ไม่พบ}"; fi
if [ -f "$D/nginx/tls/graylog.crt" ] && cmp -s /etc/pki/tls/certs/graylog-01.crt "$D/nginx/tls/graylog.crt"; then ok "certificate ของ nginx ตรงกับฉบับล่าสุดของ certmonger"; else warn "certificate ใน nginx/tls ไม่ตรงกับ /etc/pki (คัดลอกใหม่หลังต่ออายุ)"; fi
code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 --cacert /etc/ipa/ca.crt "https://$FQDN/")
if [ "$code" = 200 ]; then ok "https://$FQDN/ ตอบ 200 และ certificate ผ่านการตรวจด้วย CA ของ IPA"; else bad "https://$FQDN/ ตอบ ${code:-000}"; fi

echo; [ "$F" -eq 0 ] && echo "ผลรวม: ผ่านทุกข้อ" || echo "ผลรวม: FAIL $F ข้อ"
exit "$F"
