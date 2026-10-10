# บทที่ 11 รับ Log: Inputs, rsyslog, Streams และ Pipeline

Lab ในหลักสูตร: 16

สร้าง input แบบ Syslog และ GELF ส่ง log จากทุกเครื่องด้วย rsyslog แยก stream ตามประเภท และเขียน pipeline rule แยก field ของ SSH สำหรับงาน SOC

สิ่งที่ได้เมื่อจบบท:

- log ของทุกเครื่องเข้า Graylog แบบ real-time
- field ของ event SSH พร้อมใช้ค้นหา

สถานะ: กำลังเขียน ไฟล์ Lab ของบทนี้จะเพิ่มเมื่อทดสอบบนเครื่องจริงแล้ว

เริ่มบทนี้จาก snapshot ของบทก่อนหน้า ดู [โครงเล่ม](../docs/book-outline.md)
