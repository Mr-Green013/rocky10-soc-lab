# บทที่ 22 Application และ Web Logging: Nginx, WordPress, Redis และ WAF

Lab ในหลักสูตร: 28, 29, 30, 31, 32

ส่ง log ของ application เข้า Graylog, แยก log ของ Nginx กับ WordPress, เขียน rule ดักจับและบล็อก shell execution ใน WordPress, เร่งความเร็วด้วย Redis และวาง Web Application Firewall (ModSecurity + OWASP CRS) แบบตรวจจับก่อนแล้วจึงบล็อก

สิ่งที่ได้เมื่อจบบท:

- log ของ web stack แยกและค้นได้
- ตรวจจับ web shell ได้
- WAF ที่ tune แล้วส่ง log เข้า Graylog

สถานะ: กำลังเขียน ไฟล์ Lab ของบทนี้จะเพิ่มเมื่อทดสอบบนเครื่องจริงแล้ว

หัวข้อที่เติมใหม่ดู [docs/proposed-subtopics.md](../docs/proposed-subtopics.md)
