#!/usr/bin/env bash
# บทที่ 4 วิธีตรวจสอบ: SELinux, systemd และการ cleanup ของ mini-lab  (sudo bash ch04-check.sh)
set -uo pipefail
F=0
ok()  { printf '  [PASS] %s\n' "$*"; }
bad() { printf '  [FAIL] %s\n' "$*"; F=$((F+1)); }
t()   { local m=$1; shift; if "$@" >/dev/null 2>&1; then ok "$m"; else bad "$m"; fi; }

echo "== SELinux"
t "getenforce = Enforcing"                          sh -c "[ \"\$(getenforce)\" = Enforcing ]"
t "ค่าใน config = enforcing (ถาวรหลัง reboot)"      grep -qx 'SELINUX=enforcing' /etc/selinux/config
t "policy = targeted"                               grep -qx 'SELINUXTYPE=targeted' /etc/selinux/config
t "มีคำสั่ง semanage (policycoreutils-python-utils)" command -v semanage
t "ssh_port_t มีเฉพาะ port 22 (cleanup แล้ว)"      sh -c "semanage port -l | awk '\$1==\"ssh_port_t\"{print \$3}' | grep -qx 22"
t "sshd ฟังเฉพาะ port 22"                          sh -c "! ss -tlnp | grep sshd | grep -vqE ':22\b'"
t "ไม่มีไฟล์ 10-port.conf ค้าง"                    test ! -e /etc/ssh/sshd_config.d/10-port.conf

echo "== systemd"
t "ไม่มี unit ที่ failed"                          sh -c "[ \"\$(systemctl --failed --no-legend | wc -l)\" -eq 0 ]"
t "default target = multi-user.target"              sh -c "[ \"\$(systemctl get-default)\" = multi-user.target ]"
t "heartbeat.service ถูกลบแล้ว (cleanup)"         sh -c "! systemctl cat heartbeat.service"
echo; [ "$F" -eq 0 ] && echo "ผลรวม: ผ่านทุกข้อ" || echo "ผลรวม: FAIL $F ข้อ"
exit "$F"
