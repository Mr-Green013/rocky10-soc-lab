#!/usr/bin/env bash
# บทที่ 17 วิธีตรวจสอบ: auditd rule, การล็อก และการต่อเข้า Wazuh  (sudo bash ch17-check.sh)
set -uo pipefail
F=0
ok()  { printf '  [PASS] %s\n' "$*"; }
bad() { printf '  [FAIL] %s\n' "$*"; F=$((F+1)); }
warn(){ printf '  [WARN] %s\n' "$*"; }
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo"; exit 99; }

if [ "$(hostname -s)" = wazuh-01 ]; then
  echo "== manager"
  ids=$(grep -ho '<rule id="[0-9]*"' /var/ossec/etc/rules/*.xml 2>/dev/null | grep -o '[0-9]*')
  need=""; for i in 100310 100311 100320 100330 100340 100350 100360; do grep -qx "$i" <<<"$ids" || need="$need $i"; done
  if [ -z "$need" ]; then ok "มี rule ของ auditd (1003xx) ครบ"; else bad "ไม่พบ rule:$need"; fi
  if /var/ossec/bin/wazuh-analysisd -t >/dev/null 2>&1; then ok "wazuh-analysisd -t ผ่าน"; else bad "wazuh-analysisd -t ไม่ผ่าน"; fi
else
  echo "== auditd"
  if systemctl is-active --quiet auditd; then ok "auditd active"; else bad "auditd ไม่ active"; fi
  st=$(auditctl -s 2>/dev/null)
  en=$(awk '$1=="enabled" {print $2}' <<<"$st"); lost=$(awk '$1=="lost" {print $2}' <<<"$st")
  if [ "$en" = 2 ]; then ok "rule ถูกล็อก (enabled 2)"; else warn "enabled = ${en:-?} (เปิด -e 2 เมื่อทดสอบ rule ครบแล้ว)"; fi
  if [ "${lost:-1}" = 0 ]; then ok "lost = 0"; else warn "lost = ${lost:-?} (ตรวจ backlog และ 20-exclude.rules)"; fi
  rl=$(auditctl -l 2>/dev/null)
  miss=""; for k in identity_cmd modules perm_mod user_exec; do grep -q "key=$k\|-k $k" <<<"$rl" || miss="$miss $k"; done
  if [ -z "$miss" ]; then ok "มี key identity_cmd modules perm_mod user_exec"; else bad "ไม่พบ key:$miss"; fi
  if grep -q 'wazuh_fim' <<<"$rl"; then ok "มี rule wazuh_fim (whodata ใช้ได้หลัง -e 2)"; else bad "ไม่มี rule wazuh_fim"; fi
  left=""
  getent passwd ch17test >/dev/null && left="$left ch17test"
  lsmod 2>/dev/null | grep -qw '^dummy' && left="$left dummy"
  [ -s /etc/ld.so.preload ] && left="$left /etc/ld.so.preload"
  if [ -z "$left" ]; then ok "ไม่มีบัญชี ch17test หรือ module dummy ค้าง"; else bad "ของทดสอบค้าง:$left"; fi
fi

echo; [ "$F" -eq 0 ] && echo "ผลรวม: ผ่านทุกข้อ" || echo "ผลรวม: FAIL $F ข้อ"
exit "$F"
