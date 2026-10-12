#!/usr/bin/env bash
# บทที่ 16 วิธีตรวจสอบ: FIM whodata, identity rules และ SMB monitoring  (sudo bash ch16-check.sh)
set -uo pipefail
F=0
ok()  { printf '  [PASS] %s\n' "$*"; }
bad() { printf '  [FAIL] %s\n' "$*"; F=$((F+1)); }
warn(){ printf '  [WARN] %s\n' "$*"; }
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo"; exit 99; }
h=$(hostname -s)

if [ "$h" = wazuh-01 ]; then
  echo "== manager"
  R=/var/ossec/etc/rules
  ids=$(grep -ho '<rule id="[0-9]*"' "$R"/*.xml 2>/dev/null | grep -o '[0-9]*')
  need=""; for i in 100210 100211 100212 100220 100300 100301 100400 100401 100403 100423 100424; do grep -qx "$i" <<<"$ids" || need="$need $i"; done
  if [ -z "$need" ]; then ok "มี rule ของ FIM, identity และ SMB ครบ"; else bad "ไม่พบ rule:$need"; fi
  if /var/ossec/bin/wazuh-analysisd -t >/dev/null 2>&1; then ok "wazuh-analysisd -t ผ่าน"; else bad "wazuh-analysisd -t ไม่ผ่าน"; fi
  if grep -q 'whodata="yes"' /var/ossec/etc/shared/linux-base/agent.conf 2>/dev/null; then ok "กลุ่ม linux-base แจก FIM แบบ whodata"; else bad "linux-base/agent.conf ไม่มี whodata"; fi
else
  echo "== agent"
  if systemctl is-active --quiet auditd && auditctl -l 2>/dev/null | grep -q wazuh_fim; then ok "auditd active และมี rule wazuh_fim"; else bad "auditd ไม่ทำงานหรือไม่มี rule wazuh_fim"; fi
  if grep -q 'whodata="yes"' /var/ossec/etc/shared/agent.conf 2>/dev/null; then ok "agent อยู่ในกลุ่ม linux-base (shared/agent.conf มี whodata)"; else bad "agent ยังไม่ได้รับ config whodata จากกลุ่ม"; fi
  left=$(find /etc/sudoers.d /etc/cron.d -maxdepth 1 -type f \( -iname '*test*' -o -iname '*ch16*' \) -printf '%f ' 2>/dev/null)
  if [ -z "$left" ]; then ok "ไม่มีไฟล์ทดสอบค้างใน sudoers.d และ cron.d"; else bad "ไฟล์ทดสอบค้าง: $left"; fi
  if [ "$h" = lab-linux-02 ]; then
    echo "== file server"
    if systemctl is-active --quiet smb && testparm -s 2>/dev/null | grep -q 'full_audit'; then ok "smb active และ share มี vfs full_audit"; else bad "smb ไม่ทำงานหรือไม่มี full_audit"; fi
    if [ -s /var/log/smbd_audit.log ]; then ok "/var/log/smbd_audit.log มีข้อมูล"; else bad "/var/log/smbd_audit.log ว่างหรือไม่มี"; fi
    if iptables -S INPUT 2>/dev/null | grep -q '192.168.10.41.*DROP'; then bad "ยังมีกฎ DROP ของ 192.168.10.41"; else ok "ไม่มีกฎ DROP ของ 192.168.10.41 ค้าง"; fi
  fi
fi

echo; [ "$F" -eq 0 ] && echo "ผลรวม: ผ่านทุกข้อ" || echo "ผลรวม: FAIL $F ข้อ"
exit "$F"
