#!/usr/bin/env bash
# บทที่ 15 วิธีตรวจสอบ: rule, tuning และ Active Response  (sudo bash ch15-check.sh บน wazuh-01)
set -uo pipefail
F=0
ok()  { printf '  [PASS] %s\n' "$*"; }
bad() { printf '  [FAIL] %s\n' "$*"; F=$((F+1)); }
warn(){ printf '  [WARN] %s\n' "$*"; }
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo"; exit 99; }
R=/var/ossec/etc/rules
C=/var/ossec/etc/ossec.conf

miss=""; badperm=""
for f in 100-tuning 110-ssh 120-identity 130-audit 140-fim 150-response 160-container 170-web; do
  p="$R/${f}_rules.xml"
  if [ -f "$p" ]; then [ "$(stat -c '%a %U' "$p")" = "660 wazuh" ] || badperm="$badperm $f"; else miss="$miss $f"; fi
done
if [ -z "$miss$badperm" ]; then ok "ไฟล์ rule ครบ 8 ไฟล์ เจ้าของ wazuh สิทธิ์ 660"; else bad "ไฟล์ขาด:${miss:- -} สิทธิ์ผิด:${badperm:- -}"; fi
if /var/ossec/bin/wazuh-analysisd -t >/dev/null 2>&1; then ok "wazuh-analysisd -t ผ่าน"; else bad "wazuh-analysisd -t ไม่ผ่าน"; fi
ids=$(grep -ho '<rule id="[0-9]*"' "$R"/*.xml 2>/dev/null | grep -o '[0-9]*')
need=""; for i in 100100 100101 100102 100651; do grep -qx "$i" <<<"$ids" || need="$need $i"; done
if [ -z "$need" ]; then ok "มี rule 100100 100101 100102 100651"; else bad "ไม่พบ rule:$need"; fi
dup=$(sort <<<"$ids" | uniq -d | tr '\n' ' ')
if [ -z "$dup" ]; then ok "ไม่มี rule ID ซ้ำใน $R"; else bad "rule ID ซ้ำ: $dup"; fi
ar=$(sed -n '/<active-response>/,/<\/active-response>/p' "$C")
if grep -q '<command>firewall-drop</command>' <<<"$ar" && grep -q '<timeout>[0-9]' <<<"$ar"; then ok "active-response ของ firewall-drop มี timeout"; else bad "ไม่พบ active-response firewall-drop ที่มี timeout"; fi
if grep -q '<white_list>192.168.10.100</white_list>' "$C"; then ok "white_list มี 192.168.10.100"; else bad "white_list ไม่มี 192.168.10.100"; fi
if rpm -V wazuh-manager 2>/dev/null | grep -q '/var/ossec/ruleset/rules/'; then bad "ไฟล์ใน /var/ossec/ruleset/rules ถูกแก้ (rpm -V wazuh-manager)"; else ok "ไม่มีการแก้ไฟล์ใน /var/ossec/ruleset/rules (ตรงกับ package)"; fi

echo; [ "$F" -eq 0 ] && echo "ผลรวม: ผ่านทุกข้อ" || echo "ผลรวม: FAIL $F ข้อ"
exit "$F"
