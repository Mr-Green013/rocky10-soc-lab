# บทที่ 10 ติดตั้ง Graylog และเปิดใช้อย่างปลอดภัย

Lab ในหลักสูตร: 16

ติดตั้ง Graylog 7.1 ด้วย Docker Compose บน Rocky 10, Nginx reverse proxy พร้อม TLS และเปิดให้เข้าจากภายนอกผ่าน Cloudflare Tunnel โดยไม่เปิด port

สิ่งที่ได้เมื่อจบบท:

- Graylog ที่เข้าผ่าน HTTPS
- เข้าใจส่วนประกอบของ Graylog, MongoDB และ search backend

สถานะ: กำลังเขียน ไฟล์ Lab ของบทนี้จะเพิ่มเมื่อทดสอบบนเครื่องจริงแล้ว

เริ่มบทนี้จาก snapshot ของบทก่อนหน้า ดู [โครงเล่ม](../docs/book-outline.md)
