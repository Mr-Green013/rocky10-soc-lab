#!/usr/bin/env bash
# EN: Chapter 18 verification: Docker runtime security on node-01 and the rules on wazuh-01 (sudo bash ch18-check.sh)
# บทที่ 18 วิธีตรวจสอบ: Docker runtime security บน node-01 และ rule บน wazuh-01  (sudo bash ch18-check.sh)
set -uo pipefail
F=0
ok()  { printf '  [PASS] %s\n' "$*"; }
bad() { printf '  [FAIL] %s\n' "$*"; F=$((F+1)); }
warn(){ printf '  [WARN] %s\n' "$*"; }
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo"; exit 99; }

if [ "$(hostname -s)" = wazuh-01 ]; then
  echo "== manager"
  if ls /var/ossec/etc/rules/160-container*.xml >/dev/null 2>&1; then ok "มีไฟล์ rule 160-container"; else bad "ไม่พบ 160-container_rules.xml"; fi
  if /var/ossec/bin/wazuh-analysisd -t >/dev/null 2>&1; then ok "wazuh-analysisd -t ผ่าน"; else bad "wazuh-analysisd -t ไม่ผ่าน"; fi
  if grep -q 'container-response' /var/ossec/etc/ossec.conf 2>/dev/null; then ok "ossec.conf มี active-response container-response"; else bad "ossec.conf ยังไม่มี container-response"; fi
else
  echo "== docker host"
  if systemctl is-active --quiet docker && docker info --format '{{.SecurityOptions}}' 2>/dev/null | grep -q selinux; then
    ok "docker active และใช้ SELinux"
  else
    bad "docker ไม่ active หรือไม่ได้เปิด selinux-enabled"
  fi
  mem=$(getent group docker | cut -d: -f4)
  if [ -z "$mem" ]; then ok "กลุ่ม docker ไม่มีสมาชิก"; else bad "กลุ่ม docker มีสมาชิก: $mem (ใช้ sudo docker แทน)"; fi
  miss=""; for c in web-01 app-01 tools-01; do docker inspect "$c" >/dev/null 2>&1 || miss="$miss $c"; done
  if [ -z "$miss" ]; then ok "container web-01 app-01 tools-01 มีอยู่"; else bad "ไม่พบ container:$miss"; fi
  st=$(docker inspect -f '{{.State.Status}}' app-01 2>/dev/null)
  [ "$st" = paused ] && warn "app-01 อยู่ในสถานะ paused (docker unpause app-01 หลังเก็บหลักฐาน)"
  lb=$(docker inspect -f '{{index .Config.Labels "soc.autoresponse"}}' tools-01 2>/dev/null)
  if [ "$lb" = off ]; then ok "tools-01 มี label soc.autoresponse=off"; else bad "tools-01 ไม่มี label soc.autoresponse=off"; fi
  rl=$(auditctl -l 2>/dev/null)
  am=""; for k in docker_cmd docker_config; do grep -q "key=$k\|-k $k" <<<"$rl" || am="$am $k"; done
  if [ -z "$am" ]; then ok "audit rule ของ docker runtime โหลดแล้ว"; else bad "ไม่พบ audit key:$am"; fi
  if systemctl is-active --quiet falco-modern-bpf.service; then ok "Falco active"; else bad "falco-modern-bpf.service ไม่ active"; fi
  S=/var/ossec/active-response/bin/container-response.sh
  if [ -f "$S" ] && [ "$(stat -c '%U:%G %a' "$S")" = "root:wazuh 750" ]; then
    ok "container-response.sh เป็น root:wazuh 750"
  else
    bad "container-response.sh ไม่มีหรือสิทธิ์ไม่ใช่ root:wazuh 750"
  fi
  risky=""
  for id in $(docker ps -aq 2>/dev/null); do
    n=$(docker inspect -f '{{.Name}}' "$id" | tr -d /)
    p=$(docker inspect -f '{{.HostConfig.Privileged}}' "$id")
    m=$(docker inspect -f '{{range .Mounts}}{{.Source}} {{end}}' "$id")
    if [ "$p" = true ] || grep -q 'docker.sock' <<<"$m"; then risky="$risky $n"; fi
  done
  if [ -z "$risky" ]; then ok "ไม่มี container privileged หรือ mount docker.sock ค้าง"; else bad "container เสี่ยงค้าง:$risky"; fi
fi

echo; [ "$F" -eq 0 ] && echo "ผลรวม: ผ่านทุกข้อ" || echo "ผลรวม: FAIL $F ข้อ"
exit "$F"
