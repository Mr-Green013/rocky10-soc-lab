#!/usr/bin/env bash
# EN: Checks the basic state of a lab machine and prints KEY=VALUE (read by Test-SocLab.ps1)
# ตรวจสถานะพื้นฐานของเครื่องใน lab พิมพ์เป็น KEY=VALUE (Test-SocLab.ps1 อ่านค่านี้)
# EN: Run: sudo soclab-check
# รัน: sudo soclab-check
set -u
v3=yes
for f in avx avx2 bmi1 bmi2 f16c fma abm movbe xsave; do grep -qw "$f" /proc/cpuinfo || v3=no; done
. /etc/os-release
ok() { "$@" >/dev/null 2>&1 && echo ok || echo fail; }

echo "HOST=$(hostname)"
echo "FQDN=$(hostname -f 2>/dev/null || echo -)"
echo "IP=$(ip -4 -o addr show scope global | awk '{print $4}' | head -1)"
echo "OS=$NAME $VERSION_ID"
echo "KERNEL=$(uname -r)"
echo "X86_64_V3=$v3"
echo "SELINUX=$(getenforce 2>/dev/null || echo -)"
echo "FIREWALLD=$(systemctl is-active firewalld 2>/dev/null)"
echo "CLOUDINIT=$( [ -f /etc/cloud/cloud-init.disabled ] && echo disabled || echo enabled)"
echo "ROOT_SIZE=$(df -h --output=size / | tail -1 | tr -d ' ')"
echo "GATEWAY=$(ok ping -c1 -W2 192.168.10.1)"
echo "DNS=$(ok getent hosts rockylinux.org)"
echo "INTERNET=$(ok curl -fsS -o /dev/null --max-time 8 https://rockylinux.org)"
echo "MACHINE_ID=$(cut -c1-8 /etc/machine-id)"
