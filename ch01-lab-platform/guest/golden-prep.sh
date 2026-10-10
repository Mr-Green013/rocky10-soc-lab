#!/usr/bin/env bash
# บทที่ 1 ขั้นที่ 9: เตรียม VM 9000 ให้เป็น golden image แล้วปิดเครื่อง
# รันใน VM rocky10-golden (192.168.10.99) ในฐานะ root:  sudo bash golden-prep.sh
# สิ่งที่ทำ: อัปเดตแพ็กเกจ, ติดตั้ง cloud-init + qemu-guest-agent, ลบทุกอย่างที่ต้องไม่ซ้ำกันระหว่างเครื่อง
set -euo pipefail

[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo" >&2; exit 1; }
. /etc/os-release
[ "${ID:-}" = rocky ] && [ "${VERSION_ID%%.*}" = 10 ] || { echo "script นี้สำหรับ Rocky Linux 10 (พบ $PRETTY_NAME)" >&2; exit 1; }

echo "==> 1/5 อัปเดตแพ็กเกจและติดตั้งเครื่องมือ"
dnf -y upgrade
dnf -y install cloud-init cloud-utils-growpart qemu-guest-agent

echo "==> 2/5 ตั้งค่า cloud-init ให้หา datasource ของ Proxmox (NoCloud) อย่างเดียว"
cat > /etc/cloud/cloud.cfg.d/90-soclab.cfg <<'CFG'
# SOC lab: Proxmox ส่งค่าผ่าน cloud-init drive แบบ NoCloud
datasource_list: [ NoCloud, None ]
CFG
systemctl enable qemu-guest-agent >/dev/null 2>&1 || true

echo "==> 3/5 ตรวจค่าความปลอดภัยพื้นฐานก่อนทำ template"
echo "    SELinux  : $(getenforce)"
echo "    firewalld: $(systemctl is-active firewalld)"
[ "$(getenforce)" = Enforcing ] || echo "    !! SELinux ไม่ใช่ Enforcing แก้ก่อนทำ template (ดูบทที่ 4)"

echo "==> 4/5 ล้างข้อมูลเฉพาะเครื่อง (ทุก clone ต้องได้ค่าใหม่ของตัวเอง)"
# machine-id ซ้ำทำให้ journald, DHCP client-id และ agent ของ SIEM แยกเครื่องไม่ออก
cloud-init clean --logs --seed --machine-id
# SSH host key ซ้ำ = ทุกเครื่องปลอมตัวเป็นกันและกันได้ จะถูกสร้างใหม่ตอนบูตครั้งแรก
rm -f /etc/ssh/ssh_host_*
# profile ของ NetworkManager ที่ตัวติดตั้งสร้าง (IP .99) ให้ cloud-init สร้างใหม่ตาม IP ของแต่ละเครื่อง
# ลบไฟล์ได้เลย การเชื่อมต่อปัจจุบันยังอยู่จนกว่าจะปิดเครื่อง
rm -f /etc/NetworkManager/system-connections/*.nmconnection
hostnamectl set-hostname localhost.localdomain
rm -f /root/.bash_history /home/*/.bash_history
dnf clean all >/dev/null
journalctl --rotate >/dev/null 2>&1 || true
journalctl --vacuum-time=1s >/dev/null 2>&1 || true

echo "==> 5/5 ปิดเครื่อง: ต่อไปรัน pve-make-template.sh บน pve-01"
sync
systemctl poweroff
