#!/usr/bin/env bash
# EN: Chapter 13 verification: CrowdSec → Graylog, GeoIP and the dashboard (sudo bash ch13-check.sh)
# บทที่ 13 วิธีตรวจสอบ: CrowdSec → Graylog, GeoIP และ dashboard  (sudo bash ch13-check.sh)
# EN: The dashboard is checked through the API: read -rs GL_TOKEN && export GL_TOKEN && sudo --preserve-env=GL_TOKEN bash ch13-check.sh
# dashboard ตรวจผ่าน API: read -rs GL_TOKEN && export GL_TOKEN && sudo --preserve-env=GL_TOKEN bash ch13-check.sh
set -uo pipefail
F=0
ok()  { printf '  [PASS] %s\n' "$*"; }
bad() { printf '  [FAIL] %s\n' "$*"; F=$((F+1)); }
warn(){ printf '  [WARN] %s\n' "$*"; }
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo"; exit 99; }

case "$(hostname -s)" in
  graylog-01)
    echo "== บทบาท: Graylog server"
    for f in GeoLite2-City.mmdb GeoLite2-ASN.mmdb; do
      if (cd /opt/graylog && docker compose exec -T graylog test -r "/usr/share/graylog/geoip/$f") 2>/dev/null; then ok "$f อ่านได้ใน container"; else bad "$f ไม่พบหรืออ่านไม่ได้ใน container"; fi
    done
    if [ -n "${GL_TOKEN:-}" ]; then
      d=$(curl -s --max-time 10 --cacert /etc/ipa/ca.crt -u "$GL_TOKEN:token" -H 'Accept: application/json' "https://$(hostname -f)/api/dashboards?per_page=200")
      for t in "SOC - CrowdSec Remediation" "SOC - Global Threat Intelligence"; do
        if grep -qF "\"title\":\"$t\"" <<<"$d"; then ok "dashboard $t"; else bad "ไม่พบ dashboard $t"; fi
      done
    else
      warn "ไม่ได้ตั้ง GL_TOKEN จึงข้ามการตรวจ dashboard"
    fi
    ;;
  lab-linux-01)
    echo "== บทบาท: CrowdSec → Graylog"
    if [ -f /etc/crowdsec/notifications/http_graylog.yaml ]; then ok "มี notifications/http_graylog.yaml"; else bad "ไม่พบ /etc/crowdsec/notifications/http_graylog.yaml"; fi
    if grep -A3 -E '^notifications:' /etc/crowdsec/profiles.yaml 2>/dev/null | grep -q http_graylog; then ok "profiles.yaml ผูก http_graylog"; else bad "profiles.yaml ยังไม่ผูก http_graylog"; fi
    code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 -X POST "http://${GL_HOST:-192.168.10.20}:12201/gelf" -H 'Content-Type: application/json' -d '{"version":"1.1","host":"lab-linux-01","short_message":"ch13-check probe","_event_source":"ch13-check"}')
    if [ "$code" = 202 ]; then ok "GELF input ตอบ 202"; else bad "GELF input ตอบ ${code:-000}"; fi
    if [ -e /etc/ssh/sshd_config.d/00-lab-password.conf ]; then bad "ยังมี 00-lab-password.conf ค้าง"; else ok "ไม่มี 00-lab-password.conf ค้าง"; fi
    ;;
  *) warn "รันบน graylog-01 หรือ lab-linux-01 เท่านั้น" ;;
esac

echo; [ "$F" -eq 0 ] && echo "ผลรวม: ผ่านทุกข้อ" || echo "ผลรวม: FAIL $F ข้อ"
exit "$F"
