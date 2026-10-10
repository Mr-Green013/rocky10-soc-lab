# บทที่ 17 Linux Audit (auditd) สำหรับการสืบสวน

Lab ในหลักสูตร: 23

เขียน audit rule, ใช้ ausearch และ aureport, จำลอง web shell, ดักจับ privilege dropping, การโหลด kernel module แบบ rootkit และการเรียกใช้ eBPF API

สิ่งที่ได้เมื่อจบบท:

- audit rule ที่ใช้ตรวจเทคนิคการโจมตีระดับ syscall

สถานะ: กำลังเขียน ไฟล์ Lab ของบทนี้จะเพิ่มเมื่อทดสอบบนเครื่องจริงแล้ว

เริ่มบทนี้จาก snapshot ของบทก่อนหน้า ดู [โครงเล่ม](../docs/book-outline.md)
