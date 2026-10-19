[English](README.md) · **ภาษาไทย**

# บทที่ 14 ติดตั้ง Wazuh, Agent และ Agent Group

Lab ในหลักสูตร: 21, 34

ติดตั้ง Wazuh manager, indexer และ dashboard ส่ง alert ด้วย Filebeat ติดตั้ง agent ทุกเครื่องและจัดกลุ่ม agent เพื่อแจก configuration ตามหน้าที่ของเครื่อง

สิ่งที่ได้เมื่อจบบท:

- ทุกเครื่องรายงานเข้า Wazuh
- agent group ที่แยก config ตามบทบาท

สถานะ: เนื้อหาบทเขียนเต็มแล้ว ไฟล์ Lab: `guest/ch14-check.sh` และ config ใน `files/` (ยังต้องยืนยันบนเครื่องจริง)

เริ่มบทนี้จาก snapshot ของบทก่อนหน้า ดู [โครงเล่ม](../docs/book-outline.th.md)
