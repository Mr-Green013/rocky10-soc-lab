#!/usr/bin/env bash
# บทที่ 20 วิธีตรวจสอบ: Graylog + FreeIPA (LDAPS) และ Sudo Violation  (รันบน graylog-01)
# ใช้: read -rs GL_TOKEN && export GL_TOKEN && sudo --preserve-env=GL_TOKEN bash ch20-check.sh; unset GL_TOKEN
set -uo pipefail
F=0
ok()  { printf '  [PASS] %s\n' "$*"; }
bad() { printf '  [FAIL] %s\n' "$*"; F=$((F+1)); }
warn(){ printf '  [WARN] %s\n' "$*"; }
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo"; exit 99; }
D=/opt/graylog
cd "$D" 2>/dev/null || { echo "ไม่พบ $D"; exit 99; }

if docker compose exec -T graylog sh -c '"$JAVA_HOME/bin/keytool" -list -keystore /usr/share/graylog/cacerts.jks -storepass changeit -alias ipa-ca' >/dev/null 2>&1; then
  ok "$D/cacerts.jks มี alias ipa-ca"
else bad "truststore ใน container ไม่มี alias ipa-ca"; fi
if grep -q 'javax.net.ssl.trustStore=/usr/share/graylog/cacerts.jks' docker-compose.override.yml 2>/dev/null; then ok "docker-compose.override.yml ตั้ง javax.net.ssl.trustStore"; else bad "override ยังไม่ตั้ง trustStore"; fi
if docker compose exec -T graylog sh -c 'cat /proc/[0-9]*/cmdline 2>/dev/null | tr "\0" " "' | grep -q 'trustStore=/usr/share/graylog/cacerts.jks'; then ok "JVM ของ Graylog ใช้ truststore ที่ mount"; else bad "JVM ยังไม่ใช้ truststore (docker compose up -d graylog)"; fi
if echo | openssl s_client -connect ipa-01.lab.internal:636 -servername ipa-01.lab.internal -CAfile /etc/ipa/ca.crt -verify_return_error >/dev/null 2>&1; then ok "LDAPS ipa-01.lab.internal:636 ผ่านการตรวจ certificate"; else bad "LDAPS ไป ipa-01 ไม่ผ่าน"; fi

if [ -n "${GL_TOKEN:-}" ]; then
  api() { curl -s --max-time 10 --cacert /etc/ipa/ca.crt -u "$GL_TOKEN:token" -H 'Accept: application/json' -H 'X-Requested-By: ch20-check' "https://$(hostname -f)/api/$1"; }
  if api system/authentication/services/backends/active-backend | grep -q '"type_name":"ldap"\|"type":"ldap"'; then ok "มี authentication service ชนิด LDAP ที่ active"; else bad "ไม่พบ authentication service LDAP ที่ active"; fi
  if api 'dashboards?per_page=200' | grep -qF '"title":"Sudo Access Violation"'; then ok "dashboard Sudo Access Violation"; else bad "ไม่พบ dashboard Sudo Access Violation"; fi
  if api 'events/definitions?per_page=200' | grep -qF '"title":"Sudo violation: repeat offender"'; then ok "event definition Sudo violation: repeat offender"; else bad "ไม่พบ event definition"; fi
else
  warn "ไม่ได้ตั้ง GL_TOKEN จึงข้ามการตรวจผ่าน API"
fi

echo; [ "$F" -eq 0 ] && echo "ผลรวม: ผ่านทุกข้อ" || echo "ผลรวม: FAIL $F ข้อ"
exit "$F"
