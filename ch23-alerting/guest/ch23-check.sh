#!/usr/bin/env bash
# EN: Chapter 23 verification: alert integrations, the Postfix relay and Wazuh ports (sudo bash ch23-check.sh on wazuh-01)
# บทที่ 23 วิธีตรวจสอบ: integration แจ้งเตือน, Postfix relay และ port ของ Wazuh  (sudo bash ch23-check.sh บน wazuh-01)
set -uo pipefail
F=0
ok()  { printf '  [PASS] %s\n' "$*"; }
bad() { printf '  [FAIL] %s\n' "$*"; F=$((F+1)); }
warn(){ printf '  [WARN] %s\n' "$*"; }
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo"; exit 99; }
C=/var/ossec/etc/ossec.conf

echo "== การแจ้งเตือน"
for n in custom-line custom-telegram; do
  if grep -q "<name>$n</name>" "$C"; then ok "ossec.conf มี integration $n"; else bad "ossec.conf ไม่มี integration $n"; fi
  if [ -x "/var/ossec/integrations/$n" ] && [ -f "/var/ossec/integrations/$n.py" ]; then ok "มี wrapper และ $n.py"; else bad "ไม่พบ /var/ossec/integrations/$n(.py)"; fi
done
if grep -qiE 'token|bot[0-9]+:' "$C"; then bad "พบ token ใน ossec.conf"; else ok "ไม่มี token ใน ossec.conf"; fi
E=/var/ossec/etc/notify.env
if [ -f "$E" ] && [ "$(stat -c '%a %U %G' "$E")" = "640 root wazuh" ]; then ok "notify.env สิทธิ์ 640 root:wazuh"; else bad "notify.env ไม่มีหรือสิทธิ์ไม่ใช่ 640 root:wazuh"; fi
if /var/ossec/bin/wazuh-control status 2>/dev/null | grep -q 'wazuh-integratord is running'; then ok "wazuh-integratord running"; else bad "wazuh-integratord ไม่ทำงาน"; fi

echo "== อีเมล"
if systemctl is-active --quiet postfix; then ok "postfix active"; else bad "postfix ไม่ active"; fi
if [ "$(postconf -h inet_interfaces 2>/dev/null)" = "loopback-only" ]; then ok "postfix ฟังเฉพาะ loopback"; else bad "postfix inet_interfaces ไม่ใช่ loopback-only"; fi
if [ "$(stat -c %a /etc/postfix/sasl_passwd 2>/dev/null)" = 600 ]; then ok "sasl_passwd สิทธิ์ 600"; else bad "sasl_passwd ไม่มีหรือสิทธิ์ไม่ใช่ 600"; fi
q=$(mailq 2>/dev/null | tail -1)
case "$q" in *"empty"*) ok "mail queue ว่าง" ;; *) warn "mail queue: $q" ;; esac

echo "== port"
listen() { ss -Htln "sport = :$1" | grep -q .; }
if listen 8443; then ok "dashboard ฟัง 8443"; else bad "dashboard ไม่ได้ฟัง 8443"; fi
if listen 443; then bad "ยังมีบริการฟัง 443"; else ok "443 ปิดแล้ว"; fi
if listen 1614; then ok "manager ฟัง 1614"; else bad "manager ไม่ได้ฟัง 1614"; fi
if listen 1514; then warn "manager ยังฟัง 1514 (ปิดหลังย้าย agent ครบ ขั้น 2.3)"; else ok "1514 ปิดแล้ว"; fi
na=$(/var/ossec/bin/agent_control -l 2>/dev/null | grep -c 'Active$')
nd=$(/var/ossec/bin/agent_control -l 2>/dev/null | grep -c 'Disconnected\|Never connected')
if [ "${nd:-0}" -eq 0 ] && [ "${na:-0}" -ge 5 ]; then ok "agent Active $na ตัว ไม่มีตัวที่หลุด"; else bad "agent Active ${na:-0} ตัว, หลุด ${nd:-0} ตัว"; fi
if firewall-cmd --list-rich-rules 2>/dev/null | grep -q 'port="8443"'; then ok "มี rich rule จำกัดต้นทางของ 8443"; else bad "ไม่มี rich rule ของ 8443"; fi

echo; [ "$F" -eq 0 ] && echo "ผลรวม: ผ่านทุกข้อ" || echo "ผลรวม: FAIL $F ข้อ"
exit "$F"
