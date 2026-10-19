**English** · [ภาษาไทย](README.th.md)

# Chapter 1 Building the Lab: Proxmox VE on Hyper-V and Rocky Linux 10

Lab files for chapter 1. The full explanation is in the book; this page is the short command sequence for repeating the build.

## Files

| File | Runs on | Step |
| --- | --- | --- |
| `windows/New-ProxmoxLabHost.ps1` | Windows · PowerShell (Admin) | 3 |
| `proxmox/pve-repos.sh` | pve-01 · root | 5 |
| `proxmox/pve-setup-network.sh` | pve-01 · root | 6 |
| `proxmox/pve-get-iso.sh` | pve-01 · root | 8 |
| `proxmox/pve-create-golden.sh` | pve-01 · root | 8 |
| `guest/golden-prep.sh` | VM 9000 · root | 9 |
| `proxmox/pve-make-template.sh` | pve-01 · root | 9 |
| `proxmox/pve-clone-lab.sh` | pve-01 · root | 10 |
| `windows/Initialize-SocLab.ps1` (calls `guest/post-clone.sh`) | Windows · PowerShell | 11 |
| `proxmox/pve-snapshot.sh` | pve-01 · root | 12 |
| `proxmox/pve-lab-power.sh` | pve-01 · root | day-to-day use |
| `proxmox/pve-add-backup-storage.sh`, `proxmox/pve-backup.sh` | pve-01 · root | optional step B |
| `proxmox/pve-check.sh`, `windows/Test-SocLab.ps1`, `guest/soclab-check.sh` | as named | verification |

Machine sizes and IPs are all in `../lab-hosts.csv`. Change them in that one file only.

## Short sequence

```powershell
# [Windows · PowerShell (Admin)]
Set-ExecutionPolicy -Scope Process Bypass
.\windows\New-ProxmoxLabHost.ps1 -IsoPath D:\ISO\proxmox-ve_9.2-1.iso -VMPath D:\Hyper-V
Start-VM pve-01; vmconnect localhost pve-01
# Install Proxmox: hostname pve-01.lab.internal, IP 172.31.255.2/24, GW 172.31.255.1, DNS 1.1.1.1
scp -r ..\rocky10-soc-lab root@172.31.255.2:/root/
```

```bash
# [pve-01 · root]
cd /root/rocky10-soc-lab/ch01-lab-platform/proxmox
bash pve-repos.sh && reboot
bash pve-setup-network.sh
bash pve-get-iso.sh <rocky-10-minimal-iso-url>
bash pve-create-golden.sh
# Install Rocky in VM 9000: IP 192.168.10.99/24, GW .1, DNS 1.1.1.1, user aod (administrator)
```

```powershell
# [Windows · PowerShell]
scp .\guest\golden-prep.sh aod@192.168.10.99:/tmp/
ssh -t aod@192.168.10.99 sudo bash /tmp/golden-prep.sh   # -t lets sudo ask for the password
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

## Day-to-day use

```powershell
# [Windows · PowerShell (Admin)]
Start-VM pve-01        # every VM set to onboot starts in order, ipa-01 first
Stop-VM pve-01         # Proxmox shuts every VM down gracefully before shutting itself down
```

```bash
# [pve-01 · root]
bash pve-lab-power.sh status
bash pve-lab-power.sh start ipa-01 graylog-01   # start only the machines the chapter needs
bash pve-lab-power.sh stop
```

## Optional step B: backup to a second NVMe drive

```powershell
# [Windows · PowerShell (Admin)]  E: = the second NVMe drive
New-VHD -Path E:\Hyper-V\pve-01-backup.vhdx -SizeBytes 500GB -Dynamic
Add-VMHardDiskDrive -VMName pve-01 -ControllerType SCSI -Path E:\Hyper-V\pve-01-backup.vhdx
Add-MpPreference -ExclusionPath E:\Hyper-V
```

```bash
# [pve-01 · root]
lsblk                                   # find the new disk, e.g. /dev/sdb
bash pve-add-backup-storage.sh /dev/sdb
bash pve-backup.sh
```
