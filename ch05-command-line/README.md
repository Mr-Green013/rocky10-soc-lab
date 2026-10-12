# บทที่ 5 Command Line ที่ SOC ต้องใช้ทุกวัน

Lab ในหลักสูตร: 9.1–9.15

โครงสร้าง filesystem, การเดินทางใน directory, nano, การจัดการ output, sudo และ sudoers, journalctl แบบกรอง, rsync, shutdown และ I/O redirection โดยใช้ตัวอย่างจาก log จริงของ lab

สิ่งที่ได้เมื่อจบบท:

- ค้นและกรอง log ด้วย journalctl, grep, awk
- คัดลอกข้อมูลหลักฐานด้วย rsync โดยรักษา metadata

สถานะ: เนื้อหาบทเขียนเต็มแล้ว ไฟล์ Lab: `guest/ch05-check.sh` (ยังต้องยืนยันบนเครื่องจริง)

เริ่มบทนี้จาก snapshot ของบทก่อนหน้า ดู [โครงเล่ม](../docs/book-outline.md)
