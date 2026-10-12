#!/usr/bin/env bash
# บทที่ 22 วิธีตรวจสอบ: app log, WordPress stack, Redis และ WAF  (sudo bash ch22-check.sh บน lab-linux-01 หรือ node-01)
set -uo pipefail
F=0
ok()  { printf '  [PASS] %s\n' "$*"; }
bad() { printf '  [FAIL] %s\n' "$*"; F=$((F+1)); }
warn(){ printf '  [WARN] %s\n' "$*"; }
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo"; exit 99; }

case "$(hostname -s)" in
  lab-linux-01)
    echo "== บทบาท: application host (lab-linux-01)"
    if systemctl is-active --quiet orders-api; then ok "orders-api active"; else bad "orders-api ไม่ active"; fi
    code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 http://127.0.0.1:8090/orders)
    if [ "$code" = 200 ]; then ok "orders-api ตอบ 200"; else bad "orders-api ตอบ ${code:-000}"; fi
    if [ -f /etc/rsyslog.d/91-legacy-app.conf ] && rsyslogd -N1 >/dev/null 2>&1; then ok "rsyslog imfile ของ legacy-app ผ่านการตรวจ"; else bad "91-legacy-app.conf ไม่มีหรือ rsyslogd -N1 ไม่ผ่าน"; fi
    ;;
  node-01)
    echo "== บทบาท: web host (node-01)"
    D=/opt/wordpress
    cd "$D" 2>/dev/null || { bad "ไม่พบ $D"; echo "ผลรวม: FAIL $F ข้อ"; exit "$F"; }
    st=$(docker compose ps --format '{{.Service}} {{.State}}' 2>/dev/null)
    miss=""; for s in db redis wordpress nginx; do grep -q "^$s running" <<<"$st" || miss="$miss $s"; done
    if [ -z "$miss" ]; then ok "container db, redis, wordpress, nginx running"; else bad "container ไม่ทำงาน:$miss"; fi
    if [ "$(stat -c %a .env 2>/dev/null)" = 600 ]; then ok "$D/.env สิทธิ์ 600"; else bad "$D/.env ไม่มีหรือสิทธิ์ไม่ใช่ 600"; fi
    pub=$(docker compose ps --format '{{.Service}} {{.Ports}}' 2>/dev/null | awk '($1=="db"||$1=="redis") && /->/')
    if [ -z "$pub" ]; then ok "db และ redis ไม่ publish port"; else bad "มี port publish: $pub"; fi
    code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 http://127.0.0.1:8081/)
    if [ "$code" = 200 ]; then ok "WordPress ตอบ 200 ที่ 8081"; else bad "WordPress ตอบ ${code:-000} ที่ 8081"; fi
    # shellcheck disable=SC1091
    stats=$( . ./.env && docker compose exec -T -e REDISCLI_AUTH="$REDIS_PASSWORD" redis redis-cli info stats 2>/dev/null)
    h=$(awk -F: '/^keyspace_hits/ {print $2+0}' <<<"$stats"); m=$(awk -F: '/^keyspace_misses/ {print $2+0}' <<<"$stats")
    if [ -n "$h" ] && [ "${h:-0}" -gt "${m:-0}" ]; then ok "Redis keyspace_hits มากกว่า misses ($h > $m)"; else warn "Redis hits=${h:-?} misses=${m:-?} (ยังไม่เปิด cache หรือยังไม่มี traffic)"; fi
    if docker compose exec -T wordpress test -e /var/www/html/wp-content/uploads/lab-shelltest.php 2>/dev/null; then bad "ไฟล์ทดสอบของ Lab 29 ยังค้างใน uploads"; else ok "ไม่พบไฟล์ทดสอบของ Lab 29 ค้างใน webroot"; fi
    w=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 'http://127.0.0.1:8080/?file=../../etc/passwd')
    case "$w" in 403) ok "WAF ตอบ 403 กับคำขอทดสอบ" ;; 200) warn "WAF ตอบ 200 (ยังอยู่ในโหมด DetectionOnly)" ;; *) bad "WAF ตอบ ${w:-000}" ;; esac
    ;;
  *) warn "รันบน lab-linux-01 หรือ node-01 เท่านั้น" ;;
esac

echo; [ "$F" -eq 0 ] && echo "ผลรวม: ผ่านทุกข้อ" || echo "ผลรวม: FAIL $F ข้อ"
exit "$F"
