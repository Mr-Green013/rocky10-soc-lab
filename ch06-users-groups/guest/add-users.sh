#!/usr/bin/env bash
# EN: Chapter 6 topic 10.3: create users from a CSV (username,full name,group) with a random password each, forced to change at first login
# บทที่ 6 หัวข้อ 10.3: สร้างผู้ใช้จาก CSV (username,ชื่อเต็ม,group) รหัสสุ่มต่อคน บังคับเปลี่ยนตอน login แรก
#   sudo bash add-users.sh users.csv
# EN: Safe to rerun: existing users are skipped. The initial-password file has mode 600; hand it to the users, then delete it with shred -u
# รันซ้ำได้: ผู้ใช้ที่มีอยู่แล้วจะถูกข้าม  ไฟล์รหัสเริ่มต้นมีสิทธิ์ 600 ส่งให้ผู้ใช้แล้วลบด้วย shred -u
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo" >&2; exit 1; }
FILE="${1:?usage: $0 users.csv}"
OUT="created-$(date +%F-%H%M).txt"
umask 077
while IFS=, read -r user fullname group; do
  [[ -z "$user" || "$user" == \#* ]] && continue
  if id "$user" &>/dev/null; then echo "skip: $user exists"; continue; fi
  getent group "$group" >/dev/null || groupadd "$group"
  pw=$(openssl rand -base64 12)
  useradd -m -c "$fullname" -G "$group" -s /bin/bash "$user"
  echo "$user:$pw" | chpasswd
  chage -d 0 "$user"
  echo "$user,$pw" >> "$OUT"
  echo "created: $user ($group)"
done < "$FILE"
[ -s "$OUT" ] && echo "รหัสผ่านเริ่มต้นอยู่ใน $OUT ส่งให้ผู้ใช้แล้วลบไฟล์ทิ้ง" || true
