# บทที่ 4 SELinux และ systemd

Lab ในหลักสูตร: 8

โหมดและ context ของ SELinux, boolean, semanage port, อ่าน AVC denial ด้วย ausearch และ audit2why จัดการ service ด้วย systemctl, unit drop-in และ target

สิ่งที่ได้เมื่อจบบท:

- แก้ปัญหา SELinux โดยไม่ปิด SELinux
- เขียน unit drop-in เพื่อปรับ service อย่างปลอดภัย

สถานะ: กำลังเขียน ไฟล์ Lab ของบทนี้จะเพิ่มเมื่อทดสอบบนเครื่องจริงแล้ว

เริ่มบทนี้จาก snapshot ของบทก่อนหน้า ดู [โครงเล่ม](../docs/book-outline.md)
