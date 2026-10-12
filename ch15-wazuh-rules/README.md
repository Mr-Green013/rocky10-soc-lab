# บทที่ 15 Rule, Tuning และ Active Response

Lab ในหลักสูตร: 21

decoder และ rule แบบ custom (ช่วง ID 100000–100999), ลด false positive, ตรวจจับ brute-force, active response บล็อก IP อัตโนมัติ และ dashboard ของ IP ที่ถูกบล็อก

สิ่งที่ได้เมื่อจบบท:

- rule ที่ tune แล้วพร้อม test ด้วย wazuh-logtest
- ตอบสนองอัตโนมัติที่ย้อนกลับได้

สถานะ: เนื้อหาบทเขียนเต็มแล้ว ไฟล์ Lab: `guest/ch15-check.sh` และ config ใน `files/` (ยังต้องยืนยันบนเครื่องจริง)

เริ่มบทนี้จาก snapshot ของบทก่อนหน้า ดู [โครงเล่ม](../docs/book-outline.md)
