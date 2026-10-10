# บทที่ 2 Network, SSH และ Hostname

Lab ในหลักสูตร: 2, 3, 5

ตั้ง IP, DNS และ search domain ด้วย nmcli อ่าน NetworkManager profile ตั้ง hostname แบบ FQDN และ /etc/hosts ให้ตรงกับที่ FreeIPA ต้องการ ติดตั้งและตรวจ sshd รวมถึงลำดับของไฟล์ใน sshd_config.d

สิ่งที่ได้เมื่อจบบท:

- ทุกเครื่องมี FQDN ที่ resolve เป็น IP จริง
- เข้าใจว่า sshd อ่านค่าจากไฟล์ใดก่อนหลัง (sshd -T)

สถานะ: กำลังเขียน ไฟล์ Lab ของบทนี้จะเพิ่มเมื่อทดสอบบนเครื่องจริงแล้ว

เริ่มบทนี้จาก snapshot ของบทก่อนหน้า ดู [โครงเล่ม](../docs/book-outline.md)
