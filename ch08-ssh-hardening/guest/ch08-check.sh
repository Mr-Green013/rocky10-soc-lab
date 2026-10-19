#!/usr/bin/env bash
# EN: Chapter 8 verification: SSH key authentication and session limits (sudo bash ch08-check.sh)
# บทที่ 8 วิธีตรวจสอบ: SSH key authentication และ session limit  (sudo bash ch08-check.sh)
set -uo pipefail
F=0
ok()  { printf '  [PASS] %s\n' "$*"; }
bad() { printf '  [FAIL] %s\n' "$*"; F=$((F+1)); }
warn(){ printf '  [WARN] %s\n' "$*"; }
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo"; exit 99; }

D=/etc/ssh/sshd_config.d
U=${SUDO_USER:-aod}
T=$(sshd -T 2>/dev/null)
val() { awk -v k="$1" '$1==k {sub($1" ",""); print; exit}' <<<"$T"; }
want() { local k=$1 v=$2 got; got=$(val "$k"); if [ "$got" = "$v" ]; then ok "$k = $v"; else bad "$k = ${got:-ไม่พบ} (ต้องเป็น $v)"; fi; }

echo "== การยืนยันตัวตน"
if sshd -t 2>/dev/null; then ok "sshd -t ผ่าน"; else bad "sshd -t ไม่ผ่าน"; fi
first=$(find "$D" -maxdepth 1 -name '*.conf' -printf '%f\n' 2>/dev/null | LC_ALL=C sort | head -1)
if [ -f "$D/00-lab-password.conf" ]; then
  warn "พบ 00-lab-password.conf (เปิด password ชั่วคราวของบทที่ 9) ลบเมื่อจบบทที่ 9"
elif [ "$first" = "01-soclab-auth.conf" ]; then ok "01-soclab-auth.conf เป็นไฟล์แรกใน sshd_config.d"
else bad "ไฟล์แรกใน sshd_config.d คือ ${first:-ไม่มี} (ต้องเป็น 01-soclab-auth.conf)"; fi
want pubkeyauthentication yes
if [ -f "$D/00-lab-password.conf" ]; then warn "passwordauthentication = $(val passwordauthentication) (บทที่ 9)"; else want passwordauthentication no; fi
want kbdinteractiveauthentication no
want permitrootlogin no

echo "== session limit"
want maxauthtries 3
want logingracetime 30
want maxstartups 10:30:60
want clientaliveinterval 300
want clientalivecountmax 2
if grep -q '^channeltimeout .*session:\*=' <<<"$T"; then ok "channeltimeout มี session:*"; else bad "channeltimeout ไม่มี session:* ($(val channeltimeout))"; fi
allowed=$(awk '$1=="allowgroups" {print $2}' <<<"$T" | tr '\n' ' ')
if [ -z "$allowed" ]; then
  bad "ไม่ได้ตั้ง AllowGroups"
else
  hit=""
  for g in $(id -nG "$U" 2>/dev/null); do case " $allowed" in *" $g "*) hit=$g ;; esac; done
  if [ -n "$hit" ]; then ok "$U อยู่ในกลุ่มที่ AllowGroups อนุญาต ($hit)"; else bad "$U ไม่อยู่ในกลุ่มใดของ AllowGroups: $allowed"; fi
fi
for f in "$D"/*.conf; do
  [ -e "$f" ] || continue
  p=$(stat -c '%a' "$f")
  case "$p" in 600|400) ;; *) warn "$(basename "$f") สิทธิ์ $p (แนะนำ 600)" ;; esac
done
if grep -q 'pam_limits' /etc/pam.d/password-auth 2>/dev/null && grep -hqsE '^[^#]*maxlogins' /etc/security/limits.conf /etc/security/limits.d/*.conf; then
  ok "pam_limits อยู่ใน password-auth และตั้ง maxlogins"
else bad "pam_limits หรือ maxlogins ยังไม่ครบ"; fi
if grep -qsE '^\s*TMOUT=900' /etc/profile.d/tmout.sh && grep -qs 'readonly TMOUT' /etc/profile.d/tmout.sh; then ok "TMOUT=900 แบบ readonly"; else bad "ไม่พบ TMOUT=900 แบบ readonly ใน /etc/profile.d/tmout.sh"; fi

echo "== key ของผู้รัน"
H=$(getent passwd "$U" | cut -d: -f6)
if [ -d "$H/.ssh" ] && [ -f "$H/.ssh/authorized_keys" ]; then
  ds=$(stat -c '%a' "$H/.ssh"); fs=$(stat -c '%a' "$H/.ssh/authorized_keys")
  if [ "$ds" = 700 ] && [ "$fs" = 600 ]; then ok "$H/.ssh = 700, authorized_keys = 600"; else bad "$H/.ssh = $ds, authorized_keys = $fs (ต้อง 700/600)"; fi
  if [[ $(stat -c %C "$H/.ssh/authorized_keys" 2>/dev/null) == *:ssh_home_t:* ]]; then ok "authorized_keys มี label ssh_home_t"; else bad "label ของ authorized_keys ไม่ใช่ ssh_home_t (restorecon -Rv $H/.ssh)"; fi
  n=$(grep -c '^ssh-ed25519 ' "$H/.ssh/authorized_keys")
  if [ "$n" -ge 2 ]; then ok "authorized_keys มี ed25519 $n key"; else warn "authorized_keys มี ed25519 $n key (Lab 12 เพิ่ม key ที่ 2)"; fi
else
  bad "ไม่พบ $H/.ssh/authorized_keys"
fi

echo; [ "$F" -eq 0 ] && echo "ผลรวม: ผ่านทุกข้อ" || echo "ผลรวม: FAIL $F ข้อ"
exit "$F"
