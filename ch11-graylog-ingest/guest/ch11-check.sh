#!/usr/bin/env bash
# บทที่ 11 วิธีตรวจสอบ: การส่ง log เข้า Graylog  (sudo bash ch11-check.sh)
# บน graylog-01: ตรวจ DOCKER-USER (+ input/stream ผ่าน API ถ้าตั้ง GL_TOKEN)  บนเครื่องอื่น: ตรวจฝั่ง client
set -uo pipefail
F=0
ok()  { printf '  [PASS] %s\n' "$*"; }
bad() { printf '  [FAIL] %s\n' "$*"; F=$((F+1)); }
warn(){ printf '  [WARN] %s\n' "$*"; }
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo"; exit 99; }
GL=${GL_HOST:-192.168.10.20}

if [ "$(hostname -s)" = "graylog-01" ]; then
  echo "== บทบาท: Graylog server"
  if systemctl is-enabled --quiet docker-user-lab.service 2>/dev/null; then ok "docker-user-lab.service enabled"; else bad "docker-user-lab.service ไม่ได้ enable"; fi
  n=$(iptables -S DOCKER-USER 2>/dev/null | grep -cE -- '--dport (1514|12201) .*-j DROP')
  if [ "${n:-0}" -ge 4 ]; then ok "DOCKER-USER มีกฎ DROP ของ 1514/12201 ($n กฎ)"; else bad "DOCKER-USER มีกฎของ 1514/12201 เพียง ${n:-0} กฎ (ต้อง 4)"; fi
  if ss -Htln 'sport = :1514' | grep -q .; then ok "port 1514/tcp เปิด"; else bad "port 1514/tcp ไม่เปิด"; fi
  if [ -n "${GL_TOKEN:-}" ]; then
    api() { curl -s --max-time 10 --cacert /etc/ipa/ca.crt -u "$GL_TOKEN:token" -H 'Accept: application/json' "https://$(hostname -f)/api/$1"; }
    ins=$(api system/inputstates)
    for t in syslog-tcp-1514 gelf-http-12201; do
      if grep -q "\"title\":\"$t\"" <<<"$ins" && grep -q '"state":"RUNNING"' <<<"$ins"; then ok "input $t RUNNING"; else bad "ไม่พบ input $t ที่ RUNNING"; fi
    done
    st=$(api streams)
    for t in sudo-activity auth-logs suspicious-ip; do
      if grep -q "\"title\":\"$t\"" <<<"$st"; then ok "stream $t มีอยู่"; else bad "ไม่พบ stream $t"; fi
    done
  else
    warn "ไม่ได้ตั้ง GL_TOKEN จึงข้ามการตรวจ input และ stream ผ่าน API"
  fi
else
  echo "== บทบาท: client ที่ส่ง log"
  if [ -f /etc/rsyslog.d/90-graylog.conf ]; then ok "/etc/rsyslog.d/90-graylog.conf มีอยู่"; else bad "ไม่พบ /etc/rsyslog.d/90-graylog.conf"; fi
  if rsyslogd -N1 >/dev/null 2>&1; then ok "rsyslogd -N1 ผ่าน"; else bad "rsyslogd -N1 ไม่ผ่าน"; fi
  if semanage port -l 2>/dev/null | awk '$1=="syslogd_port_t" && $2=="tcp"' | grep -qw 1514; then ok "SELinux: tcp 1514 เป็น syslogd_port_t"; else bad "SELinux ยังไม่อนุญาต tcp 1514 ให้ rsyslog"; fi
  if ss -Htn state established "dst $GL:1514" | grep -q .; then ok "rsyslog ESTAB ไป $GL:1514"; else bad "ไม่มี connection ไป $GL:1514"; fi
  if grep -qE '^\s*active\s*=\s*yes' /etc/audit/plugins.d/syslog.conf 2>/dev/null; then ok "auditd syslog plugin active = yes"; else bad "auditd syslog plugin ยังไม่ active"; fi
  if ausearch -m AVC -ts recent -c rsyslogd >/dev/null 2>&1; then warn "พบ AVC ของ rsyslogd ล่าสุด (ausearch -m AVC -ts recent -c rsyslogd)"; else ok "ไม่มี AVC ของ rsyslog ใน 10 นาทีล่าสุด"; fi
  if [ -e /etc/ssh/sshd_config.d/00-lab-password.conf ]; then bad "ยังมี 00-lab-password.conf ค้าง"; else ok "ไม่มี 00-lab-password.conf ค้าง"; fi
fi

echo; [ "$F" -eq 0 ] && echo "ผลรวม: ผ่านทุกข้อ" || echo "ผลรวม: FAIL $F ข้อ"
exit "$F"
