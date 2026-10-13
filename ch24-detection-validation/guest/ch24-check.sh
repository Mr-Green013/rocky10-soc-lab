#!/usr/bin/env bash
# บทที่ 24 ตรวจความพร้อมของการตรวจจับ (detection readiness) ก่อนทำ detection validation
# สคริปต์นี้ "ไม่รันการโจมตีใด ๆ" แค่ตรวจว่าตัวตรวจจับทั้ง 3 ชั้นที่บทอ้างถึงทำงานอยู่
#   sudo bash ch24-check.sh
set -uo pipefail
F=0
ok()  { printf '  [PASS] %s\n' "$*"; }
bad() { printf '  [FAIL] %s\n' "$*"; F=$((F+1)); }
warn(){ printf '  [WARN] %s\n' "$*"; }
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo"; exit 99; }
H=$(hostname -s)

if [ "$H" = wazuh-01 ]; then
  echo "== manager: rule ของแต่ละ CVE พร้อมหรือไม่"
  R=/var/ossec/etc/rules
  ids=$(grep -ho '<rule id="[0-9]*"' "$R"/*.xml 2>/dev/null | grep -o '[0-9]*')
  need=""
  for i in 100802 100901 100903 100651 100402; do grep -qx "$i" <<<"$ids" || need="$need $i"; done
  if [ -z "$need" ]; then ok "rule หลักของ CVE ครบ (egress/web shell/brute/SUID)"; else bad "ไม่พบ rule:$need (ทำบทที่ 15–22 ให้ครบ)"; fi
  if ls "$R"/160-container*.xml >/dev/null 2>&1 && ls "$R"/170-web*.xml >/dev/null 2>&1; then ok "มีไฟล์ rule ของ container และ web"; else bad "ขาดไฟล์ 160-container หรือ 170-web"; fi
  if /var/ossec/bin/wazuh-analysisd -t >/dev/null 2>&1; then ok "wazuh-analysisd -t ผ่าน"; else bad "wazuh-analysisd -t ไม่ผ่าน"; fi

elif [ "$H" = node-01 ]; then
  echo "== node-01: ชั้น kernel และ host"
  if systemctl is-active --quiet falco-modern-bpf.service; then ok "Falco active (falco-modern-bpf)"; else bad "Falco ไม่ active"; fi
  list=$(tetra tracingpolicy list 2>/dev/null)
  miss=""; for p in egress-private-only guillotine suid-guard wp-no-shell; do grep -qw -- "$p" <<<"$list" || miss="$miss $p"; done
  if [ -z "$miss" ]; then ok "Tetragon policy พร้อม: egress-private-only guillotine suid-guard wp-no-shell"; else bad "Tetragon policy ที่ยังไม่โหลด:$miss"; fi
  if systemctl is-active --quiet auditd && auditctl -l 2>/dev/null | grep -q 'webshell_exec'; then ok "auditd active และมี key webshell_exec"; else bad "auditd ไม่ active หรือไม่มี key webshell_exec"; fi
  if docker inspect ebpf-01 >/dev/null 2>&1; then ok "container ทดสอบ ebpf-01 พร้อม"; else warn "ไม่มี container ebpf-01 (สร้างตามบทที่ 19 ก่อนจำลอง egress/guillotine)"; fi

elif [ "$H" = lab-linux-01 ]; then
  echo "== lab-linux-01: ชั้นเครือข่าย/log และ host"
  if systemctl is-active --quiet crowdsec && systemctl is-active --quiet crowdsec-firewall-bouncer; then ok "CrowdSec และ bouncer active"; else bad "CrowdSec หรือ bouncer ไม่ active"; fi
  if systemctl is-active --quiet auditd; then ok "auditd active"; else bad "auditd ไม่ active"; fi
  gt=$(sshd -T 2>/dev/null | awk '$1=="logingracetime"{print $2}')
  if [ -n "$gt" ] && [ "$gt" -le 30 ]; then ok "LoginGraceTime = ${gt}s (สั้นพอสำหรับลดความเสี่ยง regreSSHion)"; else warn "LoginGraceTime = ${gt:-?} (บทที่ 8 ตั้งไว้ที่ 30)"; fi

else
  echo "รันบน wazuh-01, node-01 หรือ lab-linux-01 (เครื่องนี้: $H)"
  exit 2
fi

echo
if [ "$F" -eq 0 ]; then echo "ผลรวม: พร้อมตรวจจับทุกชั้นบนเครื่องนี้"; else echo "ผลรวม: ยังไม่พร้อม $F ข้อ — แก้ก่อนทำ detection validation"; fi
exit "$F"
