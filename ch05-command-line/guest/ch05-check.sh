#!/usr/bin/env bash
# EN: Chapter 5 verification: tools, logs, the chapter's work and cleanup (sudo bash ch05-check.sh)
# บทที่ 5 วิธีตรวจสอบ: เครื่องมือ, log, ผลงานของบท และ cleanup  (sudo bash ch05-check.sh)
set -uo pipefail
F=0
ok()  { printf '  [PASS] %s\n' "$*"; }
bad() { printf '  [FAIL] %s\n' "$*"; F=$((F+1)); }
warn(){ printf '  [WARN] %s\n' "$*"; }
t()   { local m=$1; shift; if "$@" >/dev/null 2>&1; then ok "$m"; else bad "$m"; fi; }

U=${SUDO_USER:-$USER}
H=$(getent passwd "$U" | cut -d: -f6)

echo "== เครื่องมือ"
t "nano rsync tree man-pages bash-completion ติดตั้งแล้ว" rpm -q nano rsync tree man-pages bash-completion
if grep -qs '^export EDITOR=nano' "$H/.bashrc"; then ok "EDITOR=nano ใน ~/.bashrc"; else warn "ยังไม่ได้ตั้ง EDITOR=nano ใน ~/.bashrc"; fi

echo "== log"
t "rsyslog active"                 systemctl is-active --quiet rsyslog
t "/var/log/secure มีข้อมูล"      test -s /var/log/secure
if [ -d /var/log/journal ]; then ok "journal เก็บถาวรที่ /var/log/journal"; else warn "journal ยังไม่เก็บถาวร (ไม่มี /var/log/journal)"; fi

echo "== ผลงานของบท"
n=0
for d in rules decoders reports/daily reports/weekly reports; do [ -d "$H/soc/$d" ] && n=$((n+1)); done
if [ "$n" -eq 5 ]; then ok "โครงสร้าง ~/soc ครบ 5 directory"; else bad "โครงสร้าง ~/soc มี $n จาก 5 directory"; fi
B="$H/soc/reports/suid-baseline.txt"
if [ -s "$B" ]; then ok "มี ~/soc/reports/suid-baseline.txt ($(wc -l < "$B") ไฟล์)"; else bad "ไม่มี ~/soc/reports/suid-baseline.txt"; fi

echo "== cleanup"
t "ไม่มี /etc/lab.conf ค้าง"       test ! -e /etc/lab.conf
t "ผู้ใช้ tester ถูกลบแล้ว"        sh -c "! getent passwd tester"

echo; [ "$F" -eq 0 ] && echo "ผลรวม: ผ่านทุกข้อ" || echo "ผลรวม: FAIL $F ข้อ"
exit "$F"
