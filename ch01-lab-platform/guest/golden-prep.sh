#!/usr/bin/env bash
# EN: Chapter 1 step 9: prepare VM 9000 as the golden image, then shut it down
# บทที่ 1 ขั้นที่ 9: เตรียม VM 9000 ให้เป็น golden image แล้วปิดเครื่อง
# EN: Run inside VM rocky10-golden (192.168.10.99) as root: sudo bash golden-prep.sh
# รันใน VM rocky10-golden (192.168.10.99) ในฐานะ root:  sudo bash golden-prep.sh
# EN: What it does: update packages, install cloud-init + qemu-guest-agent, remove everything that must be unique per machine
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
# EN: SOC lab: Proxmox passes settings through a NoCloud cloud-init drive
# SOC lab: Proxmox ส่งค่าผ่าน cloud-init drive แบบ NoCloud
datasource_list: [ NoCloud, None ]
CFG
systemctl enable qemu-guest-agent >/dev/null 2>&1 || true

echo "==> 3/5 ตรวจค่าความปลอดภัยพื้นฐานก่อนทำ template"
echo "    SELinux  : $(getenforce)"
echo "    firewalld: $(systemctl is-active firewalld)"
[ "$(getenforce)" = Enforcing ] || echo "    !! SELinux ไม่ใช่ Enforcing แก้ก่อนทำ template (ดูบทที่ 4)"

echo "==> 4/5 ล้างข้อมูลเฉพาะเครื่อง (ทุก clone ต้องได้ค่าใหม่ของตัวเอง)"
# EN: A duplicate machine-id stops journald, the DHCP client-id and SIEM agents from telling machines apart
# machine-id ซ้ำทำให้ journald, DHCP client-id และ agent ของ SIEM แยกเครื่องไม่ออก
cloud-init clean --logs --seed --machine-id
# EN: Duplicate SSH host keys mean every machine can impersonate every other; they are regenerated at first boot
# SSH host key ซ้ำ = ทุกเครื่องปลอมตัวเป็นกันและกันได้ จะถูกสร้างใหม่ตอนบูตครั้งแรก
rm -f /etc/ssh/ssh_host_*
# EN: The NetworkManager profile the installer created (IP .99); cloud-init recreates it with each machine's IP
# profile ของ NetworkManager ที่ตัวติดตั้งสร้าง (IP .99) ให้ cloud-init สร้างใหม่ตาม IP ของแต่ละเครื่อง
# EN: Safe to delete the file now; the current connection stays up until shutdown
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
