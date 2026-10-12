#!/usr/bin/env bash
# บทที่ 6 วิธีตรวจสอบ: นโยบายรหัสผ่าน, บัญชี, sudoers และ offboarding  (sudo bash ch06-check.sh)
set -uo pipefail
F=0
ok()  { printf '  [PASS] %s\n' "$*"; }
bad() { printf '  [FAIL] %s\n' "$*"; F=$((F+1)); }
warn(){ printf '  [WARN] %s\n' "$*"; }
t()   { local m=$1; shift; if "$@" >/dev/null 2>&1; then ok "$m"; else bad "$m"; fi; }
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo"; exit 99; }

echo "== นโยบายรหัสผ่าน"
feat=$(authselect current 2>/dev/null)
for f in with-pwhistory with-faillock; do
  if grep -q -- "$f" <<<"$feat"; then ok "authselect: $f"; else bad "authselect: $f"; fi
done
minlen=$(grep -hsE '^\s*minlen\s*=' /etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf | tail -1 | tr -dc '0-9')
if [ "${minlen:-0}" -ge 14 ]; then ok "pwquality minlen >= 14"; else bad "pwquality minlen = ${minlen:-ไม่ได้ตั้ง}"; fi
rem=$(grep -sE '^\s*remember\s*=' /etc/security/pwhistory.conf | tail -1 | tr -dc '0-9')
if [ "${rem:-0}" -ge 5 ]; then ok "pwhistory remember >= 5"; else bad "pwhistory remember = ${rem:-ไม่ได้ตั้ง}"; fi
t "login.defs PASS_MAX_DAYS 90" grep -Eq '^PASS_MAX_DAYS\s+90\b' /etc/login.defs
t "hash ของรหัสผ่านเป็น yescrypt" grep -Eq '^ENCRYPT_METHOD\s+YESCRYPT' /etc/login.defs

echo "== บัญชีและสิทธิ์"
u0=$(awk -F: '$3==0 {print $1}' /etc/passwd | tr '\n' ' ')
if [ "$u0" = "root " ]; then ok "UID 0 มีเฉพาะ root"; else bad "UID 0: $u0"; fi
miss=""
for u in anan busaba chai somchai; do getent passwd "$u" >/dev/null || miss="$miss $u"; done
if [ -z "$miss" ]; then ok "ผู้ใช้ anan busaba chai somchai มีอยู่"; else bad "ไม่พบผู้ใช้:$miss"; fi
t "visudo -c ผ่าน" visudo -c
badperm=$(find /etc/sudoers.d -type f ! -perm 0440 -printf '%f ' 2>/dev/null)
if [ -z "$badperm" ]; then ok "ไฟล์ใน sudoers.d เป็น 0440 ทั้งหมด"; else bad "สิทธิ์ไม่ใช่ 0440: $badperm"; fi
np=$(grep -lE '^[^#].*NOPASSWD:\s*ALL' /etc/sudoers /etc/sudoers.d/* 2>/dev/null | xargs -r -n1 basename | tr '\n' ' ')
if [ -n "$np" ]; then warn "พบ NOPASSWD: ALL ใน $np(ยอมรับได้ใน lab)"; else ok "ไม่มี NOPASSWD: ALL"; fi
if [ -d /srv/dev ] && [ "$(stat -c '%a %G' /srv/dev)" = "2770 developers" ]; then ok "/srv/dev เป็น 2770 กลุ่ม developers"; else bad "/srv/dev ไม่ใช่ 2770 กลุ่ม developers"; fi

echo "== offboarding"
if getent passwd exstaff >/dev/null; then
  st=$(passwd -S exstaff 2>/dev/null | awk '{print $2}')
  if [ "$st" = "LK" ] || [ "$st" = "L" ]; then ok "exstaff: password ถูกล็อก"; else bad "exstaff: password ไม่ได้ล็อก ($st)"; fi
  if [ "$(getent passwd exstaff | cut -d: -f7)" = "/sbin/nologin" ]; then ok "exstaff: shell เป็น nologin"; else bad "exstaff: shell ไม่ใช่ nologin"; fi
  exp=$(getent shadow exstaff | cut -d: -f8)
  today=$(( $(date +%s) / 86400 ))
  if [ -n "$exp" ] && [ "$exp" -le "$today" ]; then ok "exstaff: บัญชีหมดอายุแล้ว"; else bad "exstaff: บัญชียังไม่หมดอายุ"; fi
  if [ ! -s /home/exstaff/.ssh/authorized_keys ]; then ok "exstaff: ไม่มี authorized_keys"; else bad "exstaff: ยังมี authorized_keys"; fi
else
  bad "ไม่พบผู้ใช้ exstaff (ทำหัวข้อ 10.10)"
fi

echo; [ "$F" -eq 0 ] && echo "ผลรวม: ผ่านทุกข้อ" || echo "ผลรวม: FAIL $F ข้อ"
exit "$F"
