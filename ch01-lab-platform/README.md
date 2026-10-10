# บทที่ 1 สร้างห้องแลป: Proxmox VE บน Hyper-V และ Rocky Linux 10

ไฟล์ Lab ของบทที่ 1 อ่านคำอธิบายเต็มในหนังสือ ส่วนนี้คือลำดับคำสั่งแบบย่อสำหรับทำซ้ำ

## ไฟล์

| ไฟล์ | รันที่ | ขั้นที่ |
| --- | --- | --- |
| `windows/New-ProxmoxLabHost.ps1` | Windows · PowerShell (Admin) | 3 |
| `proxmox/pve-repos.sh` | pve-01 · root | 5 |
| `proxmox/pve-setup-network.sh` | pve-01 · root | 6 |
| `proxmox/pve-get-iso.sh` | pve-01 · root | 8 |
| `proxmox/pve-create-golden.sh` | pve-01 · root | 8 |
| `guest/golden-prep.sh` | VM 9000 · root | 9 |
| `proxmox/pve-make-template.sh` | pve-01 · root | 9 |
| `proxmox/pve-clone-lab.sh` | pve-01 · root | 10 |
| `windows/Initialize-SocLab.ps1` (เรียก `guest/post-clone.sh`) | Windows · PowerShell | 11 |
| `proxmox/pve-snapshot.sh` | pve-01 · root | 12 |
| `proxmox/pve-lab-power.sh` | pve-01 · root | ใช้งานประจำวัน |
| `proxmox/pve-add-backup-storage.sh`, `proxmox/pve-backup.sh` | pve-01 · root | ขั้นเสริม B |
| `proxmox/pve-check.sh`, `windows/Test-SocLab.ps1`, `guest/soclab-check.sh` | ตามชื่อ | วิธีตรวจสอบ |

ขนาดเครื่องและ IP ทั้งหมดอยู่ใน `../lab-hosts.csv` แก้ที่ไฟล์นี้ไฟล์เดียว

## ลำดับย่อ

```powershell
# [Windows · PowerShell (Admin)]
Set-ExecutionPolicy -Scope Process Bypass
.\windows\New-ProxmoxLabHost.ps1 -IsoPath D:\ISO\proxmox-ve_9.2-1.iso -VMPath D:\Hyper-V
Start-VM pve-01; vmconnect localhost pve-01
# ติดตั้ง Proxmox: hostname pve-01.lab.internal, IP 172.31.255.2/24, GW 172.31.255.1, DNS 1.1.1.1
scp -r ..\rocky10-soc-lab root@172.31.255.2:/root/
```

```bash
# [pve-01 · root]
cd /root/rocky10-soc-lab/ch01-lab-platform/proxmox
bash pve-repos.sh && reboot
bash pve-setup-network.sh
bash pve-get-iso.sh <url-ของ-Rocky-10-minimal-iso>
bash pve-create-golden.sh
# ติดตั้ง Rocky ใน VM 9000: IP 192.168.10.99/24, GW .1, DNS 1.1.1.1, ผู้ใช้ aod (administrator)
```

```powershell
# [Windows · PowerShell]
scp .\guest\golden-prep.sh aod@192.168.10.99:/tmp/
ssh -t aod@192.168.10.99 sudo bash /tmp/golden-prep.sh   # -t ให้ sudo ถาม password ได้
scp $env:USERPROFILE\.ssh\id_ed25519.pub root@192.168.10.1:/root/aod.pub
```

```bash
# [pve-01 · root]
bash pve-make-template.sh
bash pve-clone-lab.sh
```

```powershell
# [Windows · PowerShell]
.\windows\Initialize-SocLab.ps1
.\windows\Test-SocLab.ps1
```

```bash
# [pve-01 · root]
bash pve-check.sh
bash pve-snapshot.sh ch01-base
```

## ใช้งานประจำวัน

```powershell
# [Windows · PowerShell (Admin)]
Start-VM pve-01        # VM ทุกเครื่องที่ตั้ง onboot จะเปิดตามลำดับ ipa-01 ก่อน
Stop-VM pve-01         # Proxmox ปิด VM ทุกเครื่องอย่างนุ่มนวลก่อนปิดตัวเอง
```

```bash
# [pve-01 · root]
bash pve-lab-power.sh status
bash pve-lab-power.sh start ipa-01 graylog-01   # เปิดเฉพาะเครื่องที่บทนั้นใช้
bash pve-lab-power.sh stop
```

## ขั้นเสริม B: backup ไป NVMe ลูกที่สอง

```powershell
# [Windows · PowerShell (Admin)]  E: = NVMe ลูกที่สอง
New-VHD -Path E:\Hyper-V\pve-01-backup.vhdx -SizeBytes 500GB -Dynamic
Add-VMHardDiskDrive -VMName pve-01 -ControllerType SCSI -Path E:\Hyper-V\pve-01-backup.vhdx
Add-MpPreference -ExclusionPath E:\Hyper-V
```

```bash
# [pve-01 · root]
lsblk                                   # หา disk ใหม่ เช่น /dev/sdb
bash pve-add-backup-storage.sh /dev/sdb
bash pve-backup.sh
```
