#!/usr/bin/env bash
# บทที่ 14 วิธีตรวจสอบ: Wazuh all-in-one, agent, การส่ง alert ไป Graylog และ agent group  (sudo bash ch14-check.sh)
set -uo pipefail
F=0
ok()  { printf '  [PASS] %s\n' "$*"; }
bad() { printf '  [FAIL] %s\n' "$*"; F=$((F+1)); }
warn(){ printf '  [WARN] %s\n' "$*"; }
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo"; exit 99; }
HOSTS="lab-linux-01 lab-linux-02 ipa-01 graylog-01 node-01"

if [ "$(hostname -s)" = wazuh-01 ]; then
  echo "== central components"
  down=""; for s in wazuh-indexer wazuh-manager filebeat wazuh-dashboard; do systemctl is-active --quiet "$s" || down="$down $s"; done
  if [ -z "$down" ]; then ok "indexer, manager, filebeat, dashboard active"; else bad "service ไม่ active:$down"; fi
  if filebeat test output 2>/dev/null | grep -q 'talk to server... OK'; then ok "filebeat ส่งเข้า indexer ได้"; else bad "filebeat test output ไม่ผ่าน"; fi
  port=$(sed -n '/<remote>/,/<\/remote>/s/.*<port>\([0-9]*\)<\/port>.*/\1/p' /var/ossec/etc/ossec.conf | head -1)
  port=${port:-1514}
  miss=""; for p in "$port" 1515 55000; do ss -ltn | grep -q ":$p " || miss="$miss $p"; done
  if [ -z "$miss" ]; then ok "manager ฟัง $port, 1515, 55000"; else bad "ไม่ได้ฟัง port:$miss"; fi
  fw=$(firewall-cmd --list-all 2>/dev/null)
  if grep -q "$port/tcp" <<<"$fw" && grep -q '1515/tcp' <<<"$fw" && grep -Eq 'https|8443/tcp' <<<"$fw"; then ok "firewall เปิด $port, 1515 และ dashboard"; else bad "firewall ยังไม่เปิด port ของ Wazuh ครบ"; fi
  echo "== agents"
  list=$(/var/ossec/bin/agent_control -l 2>/dev/null)
  na=""; for h in $HOSTS; do grep -E "Name: $h," <<<"$list" | grep -q 'Active' || na="$na $h"; done
  if [ -z "$na" ]; then ok "agent ทั้ง 5 ตัว Active"; else bad "agent ไม่ Active:$na"; fi
  if /var/ossec/bin/wazuh-control status 2>/dev/null | grep -q 'wazuh-csyslogd is running' && grep -q '<server>192.168.10.20</server>' /var/ossec/etc/ossec.conf; then
    ok "csyslogd ส่ง alert ไป graylog-01"
  else
    bad "csyslogd ไม่ทำงานหรือไม่มี syslog_output ไป 192.168.10.20"
  fi
  echo "== agent groups"
  AG=/var/ossec/bin/agent_groups
  gl=$($AG -l 2>/dev/null)
  mg=""; for g in linux-base container-hosts file-servers; do grep -qw "$g" <<<"$gl" || mg="$mg $g"; done
  if [ -z "$mg" ]; then ok "มีกลุ่ม linux-base container-hosts file-servers"; else bad "ไม่พบกลุ่ม:$mg"; fi
  bc=$($AG -l -g linux-base 2>/dev/null | grep -c 'Name:\|ID:')
  if [ "$bc" -ge 5 ]; then ok "linux-base มีสมาชิกครบ"; else bad "linux-base มีสมาชิก $bc ตัว (ต้องมี 5)"; fi
  bf=""; for g in linux-base container-hosts file-servers; do
    /var/ossec/bin/verify-agent-conf -f "/var/ossec/etc/shared/$g/agent.conf" >/dev/null 2>&1 || bf="$bf $g"
  done
  if [ -z "$bf" ]; then ok "agent.conf ทุกกลุ่มผ่าน verify-agent-conf"; else bad "agent.conf ผิด:$bf"; fi
  tars=$(find /root /home -maxdepth 3 -name 'wazuh-install-files.tar' 2>/dev/null | tr '\n' ' ')
  if [ -z "$tars" ]; then ok "ไม่มี wazuh-install-files.tar ค้างบนเครื่อง"; else warn "ย้ายไปเก็บนอกเครื่อง: $tars"; fi
else
  echo "== agent"
  if systemctl is-active --quiet wazuh-agent; then ok "wazuh-agent active"; else bad "wazuh-agent ไม่ active"; fi
  last=$(grep -E 'Connected to the server|Lost connection|Unable to connect' /var/ossec/logs/ossec.log 2>/dev/null | tail -1)
  if grep -q 'Connected to the server' <<<"$last"; then ok "เชื่อมต่อ manager อยู่"; else bad "สถานะล่าสุด: ${last:-ไม่พบข้อความเชื่อมต่อ}"; fi
  if grep -q '^enabled=0' /etc/yum.repos.d/wazuh.repo 2>/dev/null; then ok "ปิด repo ของ Wazuh แล้ว (กัน upgrade เกิน manager)"; else warn "wazuh.repo ยังเปิดอยู่"; fi
  if grep -q 'linux-server' /var/ossec/etc/shared/agent.conf 2>/dev/null; then ok "ได้รับ config ของกลุ่ม linux-base"; else bad "ยังไม่ได้รับ agent.conf ของ linux-base"; fi
  left=$(find /etc/sudoers.d -maxdepth 1 -name '*ch14*' -printf '%f ' 2>/dev/null)
  if [ -z "$left" ]; then ok "ไม่มีไฟล์ทดสอบค้างใน sudoers.d"; else bad "ไฟล์ทดสอบค้าง: $left"; fi
fi

echo; [ "$F" -eq 0 ] && echo "ผลรวม: ผ่านทุกข้อ" || echo "ผลรวม: FAIL $F ข้อ"
exit "$F"
