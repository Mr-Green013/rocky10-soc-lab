# บทที่ 7 Centralized Identity ด้วย FreeIPA

Lab ในหลักสูตร: 11

ติดตั้ง FreeIPA พร้อม DNS และ CA ให้ทุกเครื่อง join domain ตั้ง password policy, HBAC rule, sudo rule และ SSH key แบบรวมศูนย์ และค้นข้อมูลผ่าน LDAP

สิ่งที่ได้เมื่อจบบท:

- login ทุกเครื่องด้วยบัญชีเดียว
- ipa-01 เป็น DNS ของทั้ง lab

สถานะ: กำลังเขียน ไฟล์ Lab ของบทนี้จะเพิ่มเมื่อทดสอบบนเครื่องจริงแล้ว

เริ่มบทนี้จาก snapshot ของบทก่อนหน้า ดู [โครงเล่ม](../docs/book-outline.md)
