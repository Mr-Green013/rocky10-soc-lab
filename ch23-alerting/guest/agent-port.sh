#!/usr/bin/env bash
# บทที่ 23 Lab 40 ขั้น 2.2: ย้าย Wazuh agent ไปต่อ manager ที่ port ใหม่ แล้วคืนค่าเองถ้าต่อไม่ได้
# ใช้: sudo bash agent-port.sh [NEW_PORT] [OLD_PORT]   (ค่าเริ่มต้น 1614 1514)
set -uo pipefail
NEW=${1:-1614}; OLD=${2:-1514}
C=/var/ossec/etc/ossec.conf
LOG=/var/ossec/logs/ossec.log
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo"; exit 99; }
[ -f "$C" ] || { echo "ไม่พบ $C (เครื่องนี้ไม่มี wazuh-agent)"; exit 2; }

if sed -n '/<client>/,/<\/client>/p' "$C" | grep -q "<port>$NEW</port>"; then
  echo "agent ใช้ port $NEW อยู่แล้ว"; exit 0
fi
cp -p "$C" "$C.port$OLD"
sed -i "/<client>/,/<\/client>/ s|<port>$OLD</port>|<port>$NEW</port>|" "$C"
if ! sed -n '/<client>/,/<\/client>/p' "$C" | grep -q "<port>$NEW</port>"; then
  echo "ไม่พบ <port>$OLD</port> ในบล็อก <client> ไม่ได้แก้อะไร"; cp -p "$C.port$OLD" "$C"; exit 3
fi
mark=$(wc -l < "$LOG")
systemctl restart wazuh-agent
for _ in $(seq 1 12); do
  sleep 5
  if tail -n +"$((mark + 1))" "$LOG" | grep -q "Connected to the server .*:$NEW/tcp"; then
    tail -n +"$((mark + 1))" "$LOG" | grep "Connected to the server" | tail -1
    echo "สำเร็จ: $(hostname -s) ต่อที่ port $NEW"; exit 0
  fi
done
echo "ต่อ port $NEW ไม่สำเร็จภายใน 60 วินาที คืนค่า $C.port$OLD"
cp -p "$C.port$OLD" "$C" && systemctl restart wazuh-agent
exit 1
