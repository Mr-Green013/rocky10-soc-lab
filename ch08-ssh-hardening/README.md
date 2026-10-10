# บทที่ 8 SSH Hardening: Key Authentication และ Session Limit

Lab ในหลักสูตร: 12, 13

กลไกของ SSH key authentication, ปิด password authentication, จำกัด session และ connection ด้วย MaxSessions, MaxStartups, ClientAlive และ limit ของ PAM

สิ่งที่ได้เมื่อจบบท:

- SSH ที่ใช้ key อย่างเดียวและจำกัด session
- อ่าน log การ login ของ sshd ได้ถูกต้อง

สถานะ: กำลังเขียน ไฟล์ Lab ของบทนี้จะเพิ่มเมื่อทดสอบบนเครื่องจริงแล้ว

เริ่มบทนี้จาก snapshot ของบทก่อนหน้า ดู [โครงเล่ม](../docs/book-outline.md)
