# บทที่ 3 Kernel, เวอร์ชันระบบ, Timezone และ NTP

Lab ในหลักสูตร: 4, 6, 7

ตรวจเวอร์ชันของ kernel และระบบด้วย uname, rpm, os-release ตั้ง timezone Asia/Bangkok และ chrony ให้ทุกเครื่องเวลาตรงกัน พร้อมเหตุผลว่าทำไมเวลาที่คลาดกันทำให้สืบสวนเหตุการณ์จาก log ไม่ได้

สิ่งที่ได้เมื่อจบบท:

- ทุกเครื่อง sync เวลาจากแหล่งเดียวกัน
- อ่าน chronyc sources และ tracking ได้

สถานะ: ต้นฉบับเขียนแล้ว รอทดสอบบนเครื่องจริง

เริ่มบทนี้จาก snapshot ของบทก่อนหน้า ดู [โครงเล่ม](../docs/book-outline.md)

## ไฟล์

| ไฟล์ | รันที่ | หน้าที่ |
| --- | --- | --- |
| `proxmox/pve-ntp-server.sh` | pve-01 | chrony ของ pve-01 แจกเวลาให้ lab |
| `guest/set-time.sh` | ทุก VM | timezone และ chrony ชี้ pve-01 |
| `guest/ch03-check.sh` | ทุก VM | ตรวจ kernel, BTF, OS, เวลา |

รัน script ฝั่ง guest กับทุกเครื่องจาก Windows:

```powershell
cd tools\windows
.\Invoke-SocLabScript.ps1 -Script ..\..\ch03-kernel-time-ntp\guest\ch03-check.sh
```
