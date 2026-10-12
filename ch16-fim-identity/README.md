# บทที่ 16 File Integrity และ Identity Monitoring

Lab ในหลักสูตร: 22

syscheck แบบ scheduled, realtime และ whodata ติดตามไฟล์สำคัญ เก็บ diff ของ config โดยไม่ให้ความลับรั่ว เฝ้า sudoers, authorized_keys, cron, /boot และ baseline ของไฟล์ SUID ตรวจการแก้กลุ่มและการสวมรอยด้วย usermod เฝ้า SMB share และแจ้งเตือนการลบไฟล์จำนวนมาก

สิ่งที่ได้เมื่อจบบท:

- รู้ว่าใครแก้ไฟล์ไหนเมื่อไร
- alert การลบไฟล์จำนวนมาก

สถานะ: กำลังเขียน ไฟล์ Lab ของบทนี้จะเพิ่มเมื่อทดสอบบนเครื่องจริงแล้ว

หัวข้อที่เติมใหม่ดู [docs/proposed-subtopics.md](../docs/proposed-subtopics.md)
