#!/usr/bin/env bash
# EN: Chapter 12 verification: Saved Searches and log completeness
# บทที่ 12 วิธีตรวจสอบ: Saved Search และความครบของ log
# EN: Usage: read -rs GL_TOKEN && export GL_TOKEN && sudo --preserve-env=GL_TOKEN bash ch12-check.sh; unset GL_TOKEN
# ใช้: read -rs GL_TOKEN && export GL_TOKEN && sudo --preserve-env=GL_TOKEN bash ch12-check.sh; unset GL_TOKEN
set -uo pipefail
F=0
ok()  { printf '  [PASS] %s\n' "$*"; }
bad() { printf '  [FAIL] %s\n' "$*"; F=$((F+1)); }
warn(){ printf '  [WARN] %s\n' "$*"; }
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo"; exit 99; }
GLH=${GL_HOST:-graylog-01.lab.internal}
CA=/etc/ipa/ca.crt

echo "== Graylog API"
if [ -z "${GL_TOKEN:-}" ]; then
  bad "ไม่ได้ตั้ง GL_TOKEN (ดูวิธีใช้ในหัวไฟล์)"
else
  api() { curl -s --max-time 10 --cacert "$CA" -u "$GL_TOKEN:token" -H 'Accept: application/json' "https://$GLH/api/$1"; }
  if [ "$(api system/lbstatus)" = "ALIVE" ] || api system | grep -q '"version"'; then ok "API ตอบที่ https://$GLH (certificate ผ่านการตรวจ)"; else bad "เรียก API ที่ https://$GLH ไม่ได้"; fi
  if api streams | grep -q '"title":"auth-logs"'; then ok "stream auth-logs มีอยู่"; else bad "ไม่พบ stream auth-logs"; fi
  echo "== Saved Search"
  saved=$(api 'search/saved?per_page=200')
  grep -q '"title"' <<<"$saved" || saved=$(api 'views?per_page=200')
  for t in "SSH - Successful logins" "SSH - Password logins" "SSH - Failed by user" "SSH - Invalid users" "SSH - Root attempts" "SSH - External success" "SSH - Success after failures"; do
    if grep -qF "\"title\":\"$t\"" <<<"$saved"; then ok "$t"; else bad "ไม่พบ Saved Search: $t"; fi
  done
fi

echo "== ข้อมูลบนเครื่อง"
if [ -r /var/log/secure ]; then
  today=$(LC_ALL=C date +'%b %e')
  n=$(grep "^$today" /var/log/secure | grep -c 'Accepted publickey')
  ok "วันนี้มี Accepted publickey $n ครั้งใน /var/log/secure (เทียบกับ Graylog ด้วยตนเอง)"
else
  warn "อ่าน /var/log/secure ไม่ได้บนเครื่องนี้"
fi

echo; [ "$F" -eq 0 ] && echo "ผลรวม: ผ่านทุกข้อ" || echo "ผลรวม: FAIL $F ข้อ"
exit "$F"
