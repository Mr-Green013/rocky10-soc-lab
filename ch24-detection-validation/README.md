# บทที่ 24 ทดสอบการโจมตีในห้องแลปเพื่อศึกษาการป้องกัน (detection validation)

Lab ในหลักสูตร: บทสรุป (ใช้ตัวตรวจจับจากบทที่ 8, 9, 15–19, 22)

แมป CVE จริง 6 ตัว (Log4Shell, Struts2, Shellshock, regreSSHion, PwnKit, xz/liblzma) เข้ากับตัวตรวจจับ 3 ชั้นของเล่ม แล้วจำลอง "เฉพาะสัญญาณ" ที่ตัวตรวจจับมองหา ด้วยขั้นตอน benign ที่อ้างอิง lab เดิม เพื่อวัด detection coverage

สิ่งที่ได้เมื่อจบบท:

- จำลองสัญญาณของ CVE ทั้ง 6 ตัวโดยไม่ใช้ exploit จริง และเกิด alert
- ตาราง detection coverage พร้อมช่องว่างที่ต้องปิด

ไฟล์ในบท:

- `guest/ch24-check.sh` — ตรวจความพร้อมของตัวตรวจจับ 3 ชั้น (ไม่รันการโจมตี) รันบน wazuh-01, node-01, lab-linux-01
- `coverage-template.md` — แม่แบบตาราง detection coverage

แนวทางด้านความปลอดภัย: ทำในห้องแลปที่แยกขาดเท่านั้น ใช้บัญชี/container ทดสอบและ cleanup ทุกครั้ง ไม่มี exploit หรือ payload จริง ใช้ IP สำหรับเอกสาร (RFC 5737) เมื่ออ้างปลายทางภายนอก

สถานะ: เนื้อหาบทเขียนเต็มแล้ว ไฟล์ Lab: `guest/ch24-check.sh` และ `coverage-template.md` (ยังต้องยืนยันบนเครื่องจริง)

เริ่มบทนี้จาก snapshot `ch23-final` ดู [โครงเล่ม](../docs/book-outline.md)
