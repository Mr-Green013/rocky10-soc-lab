# บทที่ 11 รับ Log: Inputs, rsyslog, Streams และ Pipeline

Lab ในหลักสูตร: 16

สร้าง input แบบ Syslog และ GELF ส่ง log จากทุกเครื่องด้วย rsyslog แยก stream ตามประเภท และเขียน pipeline rule แยก field ของ SSH สำหรับงาน SOC

สิ่งที่ได้เมื่อจบบท:

- log ของทุกเครื่องเข้า Graylog แบบ real-time
- field ของ event SSH พร้อมใช้ค้นหา

สถานะ: เนื้อหาบทเขียนเต็มแล้ว ไฟล์ Lab: `guest/ch11-check.sh` และ config ใน `files/` (ยังต้องยืนยันบนเครื่องจริง)

เริ่มบทนี้จาก snapshot ของบทก่อนหน้า ดู [โครงเล่ม](../docs/book-outline.md)
