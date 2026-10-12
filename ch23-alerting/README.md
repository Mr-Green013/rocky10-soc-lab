# บทที่ 23 Alert ไป LINE, Telegram และ Gmail; ปรับ Port ของ Wazuh

Lab ในหลักสูตร: 38, 39, 40

integration ของ Wazuh ส่ง alert ไป LINE Messaging API (แทน LINE Notify ที่ปิดบริการ), Telegram bot และ Gmail ผ่าน SMTP relay และย้าย port ของ Wazuh dashboard พร้อม firewall rule

สิ่งที่ได้เมื่อจบบท:

- alert ระดับสำคัญถึงมือถือภายในไม่กี่วินาที

สถานะ: เนื้อหาบทเขียนเต็มแล้ว ไฟล์ Lab: `guest/ch23-check.sh` และ config ใน `files/` (ยังต้องยืนยันบนเครื่องจริง)

เริ่มบทนี้จาก snapshot ของบทก่อนหน้า ดู [โครงเล่ม](../docs/book-outline.md)
