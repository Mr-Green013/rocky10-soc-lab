[English](README.md) · **ภาษาไทย**

# บทที่ 2 Network, SSH และ Hostname

Lab ในหลักสูตร: 2, 3, 5

ตั้ง IP, DNS และ search domain ด้วย nmcli อ่าน NetworkManager profile ตั้ง hostname แบบ FQDN และ /etc/hosts ให้ตรงกับที่ FreeIPA ต้องการ ติดตั้งและตรวจ sshd รวมถึงลำดับของไฟล์ใน sshd_config.d

สิ่งที่ได้เมื่อจบบท:

- ทุกเครื่องมี FQDN ที่ resolve เป็น IP จริง
- เข้าใจว่า sshd อ่านค่าจากไฟล์ใดก่อนหลัง (sshd -T)

สถานะ: ต้นฉบับเขียนแล้ว รอทดสอบบนเครื่องจริง

เริ่มบทนี้จาก snapshot ของบทก่อนหน้า ดู [โครงเล่ม](../docs/book-outline.th.md)

## ไฟล์

| ไฟล์ | รันที่ | หน้าที่ |
| --- | --- | --- |
| `guest/set-identity.sh` | ทุก VM | ตั้ง FQDN, /etc/hosts ของ lab, profile ชื่อ lab |
| `guest/ch02-check.sh` | ทุก VM | ตรวจ network, hostname, SSH |
| `../tools/windows/Set-SocLabHosts.ps1` | Windows (Admin) | hosts file และ ~/.ssh/config ของ Windows |

รัน script ฝั่ง guest กับทุกเครื่องจาก Windows:

```powershell
cd tools\windows
.\Invoke-SocLabScript.ps1 -Script ..\..\ch02-network-ssh-hostname\guest\set-identity.sh -Files ..\..\lab-hosts.csv
```

ส่วน `Set-SocLabHosts.ps1` รันบน Windows โดยตรงใน PowerShell แบบ Admin:

```powershell
cd tools\windows
.\Set-SocLabHosts.ps1
```
