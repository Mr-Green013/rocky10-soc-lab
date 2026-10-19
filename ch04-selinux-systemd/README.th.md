[English](README.md) · **ภาษาไทย**

# บทที่ 4 SELinux และ systemd

Lab ในหลักสูตร: 8

โหมดและ context ของ SELinux, boolean, semanage port, อ่าน AVC denial ด้วย ausearch และ audit2why จัดการ service ด้วย systemctl, unit drop-in และ target

สิ่งที่ได้เมื่อจบบท:

- แก้ปัญหา SELinux โดยไม่ปิด SELinux
- เขียน unit drop-in เพื่อปรับ service อย่างปลอดภัย

สถานะ: ต้นฉบับเขียนแล้ว รอทดสอบบนเครื่องจริง

เริ่มบทนี้จาก snapshot ของบทก่อนหน้า ดู [โครงเล่ม](../docs/book-outline.th.md)

## ไฟล์

| ไฟล์ | รันที่ | หน้าที่ |
| --- | --- | --- |
| `guest/ch04-check.sh` | ทุก VM | ตรวจ SELinux, systemd และ cleanup ของ mini-lab |

รัน script ฝั่ง guest กับทุกเครื่องจาก Windows:

```powershell
cd tools\windows
.\Invoke-SocLabScript.ps1 -Script ..\..\ch04-selinux-systemd\guest\ch04-check.sh
```
