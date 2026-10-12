#!/usr/bin/env bash
# บทที่ 19 วิธีตรวจสอบ: Tetragon, TracingPolicy 9 ตัว และ rule ฝั่ง Wazuh  (sudo bash ch19-check.sh)
set -uo pipefail
F=0
ok()  { printf '  [PASS] %s\n' "$*"; }
bad() { printf '  [FAIL] %s\n' "$*"; F=$((F+1)); }
warn(){ printf '  [WARN] %s\n' "$*"; }
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo"; exit 99; }
POL="block-tmp-exec guillotine protect-shadow keyguard egress-private-only connect-audit suid-guard sensitive-files account-tracker"

if [ "$(hostname -s)" = wazuh-01 ]; then
  echo "== manager"
  ids=$(grep -ho '<rule id="[0-9]*"' /var/ossec/etc/rules/*.xml 2>/dev/null | grep -o '[0-9]*')
  need=""; for i in 100800 100801 100802 100805 100810 100811 100812 100813 100820 100821 100830; do grep -qx "$i" <<<"$ids" || need="$need $i"; done
  if [ -z "$need" ]; then ok "มี rule ของ Tetragon (1008xx) ครบ"; else bad "ไม่พบ rule:$need"; fi
  if grep -A6 '<rule id="100802"' /var/ossec/etc/rules/160-container_rules.xml 2>/dev/null | grep -q 'tetragon_kill'; then
    ok "rule 100802 อยู่ในกลุ่ม tetragon_kill"
  else
    bad "rule 100802 ยังไม่มี <group>tetragon_kill,</group> (100805 จะไม่ดัง)"
  fi
  if grep -q '<rules_id>[0-9,]*100805' /var/ossec/etc/ossec.conf; then ok "active-response quarantine ผูก 100805"; else bad "ยังไม่ผูก 100805 กับ container-quarantine"; fi
  if /var/ossec/bin/wazuh-analysisd -t >/dev/null 2>&1; then ok "wazuh-analysisd -t ผ่าน"; else bad "wazuh-analysisd -t ไม่ผ่าน"; fi
else
  echo "== tetragon"
  if [ -r /sys/kernel/btf/vmlinux ]; then ok "kernel มี BTF"; else bad "ไม่มี /sys/kernel/btf/vmlinux"; fi
  if systemctl is-active --quiet tetragon; then ok "tetragon active"; else bad "tetragon ไม่ active"; fi
  if grep -q 'PROCESS_KPROBE' /etc/tetragon/tetragon.conf.d/export-allowlist 2>/dev/null; then ok "export-allowlist ส่งออกเฉพาะ PROCESS_KPROBE"; else bad "ไม่มี /etc/tetragon/tetragon.conf.d/export-allowlist"; fi
  list=$(tetra tracingpolicy list 2>/dev/null)
  miss=""; for p in $POL; do grep -qw -- "$p" <<<"$list" || miss="$miss $p"; done
  if [ -z "$miss" ]; then ok "โหลด policy ครบ 9 ตัว"; else bad "policy ที่ยังไม่โหลด:$miss"; fi
  grep -qw smoke-test <<<"$list" && warn "smoke-test ยังโหลดอยู่ (tetra tracingpolicy delete smoke-test)"
  nf=$(find /etc/tetragon/tetragon.tp.d -maxdepth 1 -name '*.yaml' 2>/dev/null | wc -l)
  if [ "$nf" -ge 9 ]; then ok "ติดตั้งถาวรใน tetragon.tp.d ($nf ไฟล์)"; else bad "tetragon.tp.d มี $nf ไฟล์ (ต้องมี 9)"; fi
  if grep -q 'action: Sigkill' /etc/tetragon/tetragon.tp.d/40-keyguard.yaml 2>/dev/null; then
    ok "keyguard อยู่ในระยะบังคับ (Sigkill)"
  else
    warn "keyguard ยังเป็นระยะสังเกต (Post)"
  fi
  L=/var/log/tetragon/tetragon.log
  if [ -s "$L" ]; then
    other=$(tail -n 200 "$L" | jq -r 'keys[]' 2>/dev/null | grep -vxE 'process_kprobe|node_name|time|aggregation_info' | sort -u | tr '\n' ' ')
    if [ -z "$other" ]; then ok "tetragon.log มีเฉพาะ process_kprobe"; else warn "tetragon.log มี event อื่น: $other"; fi
  else
    bad "ไม่มี $L"
  fi
  if grep -q '/var/log/tetragon/tetragon.log' /var/ossec/etc/ossec.conf; then ok "Wazuh agent อ่าน tetragon.log"; else bad "agent ยังไม่มี localfile ของ tetragon.log"; fi
  A=/usr/local/sbin/acct-activity.sh
  if [ -x "$A" ] && [ "$(stat -c '%a' "$A")" = 750 ]; then ok "acct-activity.sh สิทธิ์ 750"; else bad "ไม่มี $A หรือสิทธิ์ไม่ใช่ 750"; fi
  echo "== สิ่งที่ต้องไม่ค้าง"
  left=""
  docker exec ebpf-01 test -e /root/suid-test 2>/dev/null && left="$left ebpf-01:/root/suid-test"
  docker network inspect lab-internal >/dev/null 2>&1 && left="$left network:lab-internal"
  [ -e /root/suid-host ] && left="$left /root/suid-host"
  getent passwd tester1 >/dev/null && left="$left user:tester1"
  grep -qx '# lab-direct-write' /etc/group && left="$left /etc/group:lab-direct-write"
  if [ -z "$left" ]; then ok "ไม่มีไฟล์ บัญชี หรือ network ทดสอบค้าง"; else bad "ของทดสอบค้าง:$left"; fi
  if docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$k}} {{end}}' app-01 2>/dev/null | grep -qw lab-net; then
    ok "app-01 กลับมาอยู่ใน lab-net"
  else
    bad "app-01 ยังถูก quarantine (sudo docker network connect lab-net app-01)"
  fi
fi

echo; [ "$F" -eq 0 ] && echo "ผลรวม: ผ่านทุกข้อ" || echo "ผลรวม: FAIL $F ข้อ"
exit "$F"
