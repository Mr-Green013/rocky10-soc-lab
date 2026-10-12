# หัวข้อย่อยที่เติมใหม่ (อนุมัติแล้ว)

ออกแบบให้ต่อเนื่องกับเนื้อหาเดิมในเอกสาร 8 หมวด ทุกหัวข้อเน้นการตั้งค่าเพื่อ **ตรวจจับและป้องกัน** การทดสอบใช้เหตุการณ์ที่ไม่เป็นอันตราย (คำสั่งปกติของระบบ หรือไฟล์ทดสอบที่ลบทิ้งทันที) ส่วนการจำลองการโจมตีเต็มรูปแบบให้ใช้ชุดทดสอบที่เผยแพร่แล้ว เช่น Atomic Red Team โดยอ่านขั้นตอนจากเอกสารของเครื่องมือนั้น แล้วรันในห้องแลปที่แยกขาด

สถานะ: **อนุมัติแล้ว** (12 ต.ค. 2026) ทุกหัวข้อตามข้อเสนอ และ Lab 32 ใช้ทางเลือก B

---

## Lab 10.10 (อยู่ระหว่าง 10.9 sudoers และ 10.11 Create Group)

**10.10 ล็อก ปลดล็อก และปิดบัญชีผู้ใช้ (Account Lockout และ Offboarding)**
Objective: ปิดการใช้งานบัญชีที่ลาออกหรือถูกยึดอย่างถูกวิธี โดยไม่ลบบัญชีทิ้ง (เพื่อคงเจ้าของไฟล์และหลักฐานไว้)
- แยกความต่างของ 3 วิธี: `usermod -L` / `passwd -l` (ล็อก password), ตั้ง shell เป็น `/sbin/nologin`, และตั้งวันหมดอายุบัญชี `usermod -e`
- ทำไมการล็อกเฉพาะ password ไม่พอเมื่อบัญชีมี SSH key — ต้องปิด shell หรือถอด key ด้วย
- เชื่อมกับ Lab 22: การแก้ `/etc/shadow` และ `/etc/passwd` จากคำสั่งเหล่านี้ต้องปรากฏใน FIM
- Verify: `passwd -S <user>`, `chage -l <user>`, ทดสอบ login ต้องถูกปฏิเสธ

---

## Lab 16.16 (อยู่ในช่วง 16.2–16.17 Cloudflare Tunnel และ Nginx)

**16.16 เชื่อม cloudflared เข้ากับ Nginx ผ่าน Docker network แล้ว reload**
Objective: ต่อ container `cloudflared` เข้ากับ reverse proxy ที่สร้างใน 16.15 และใช้ config ใหม่โดยไม่ดับ service
- เพิ่ม `cloudflared` ใน `docker-compose.yml` ให้อยู่ network เดียวกับ nginx และชี้ ingress ไปที่ `http://nginx:80`
- `docker compose up -d cloudflared` แล้ว `docker compose exec nginx nginx -t && nginx -s reload`
- ตรวจ tunnel ด้วย `docker compose logs cloudflared` (ต้องเห็น `Registered tunnel connection`)
- Verify: เปิด public hostname แล้วได้หน้า login ของ Graylog ผ่าน HTTPS

---

## Lab 22.10–22.26: Syscheck (FIM) เชิงลึก (ต่อจาก 22.2 System Binary Integrity)

| หัวข้อ | ชื่อ | สิ่งที่สอน |
| --- | --- | --- |
| 22.10 | โหมดของ syscheck: scheduled, realtime, whodata | เลือกโหมดให้เหมาะกับแต่ละ directory และผลต่อภาระระบบ |
| 22.11 | ปรับ `frequency` และ `scan_on_start` | ตั้งรอบ scan และลดภาระตอนบูต |
| 22.12 | `report_changes`: ดูว่าเนื้อหาไฟล์เปลี่ยนบรรทัดไหน | เก็บ diff ของไฟล์ config สำคัญ |
| 22.13 | `nodiff`: กัน content ของไฟล์ลับรั่วใน alert | ใช้กับ `/etc/shadow`, key, ไฟล์ที่มี secret |
| 22.14 | เฝ้า `/etc/sudoers` และ `/etc/sudoers.d` | ตรวจการเพิ่มสิทธิ์ที่ไม่ผ่าน FreeIPA |
| 22.15 | เฝ้า `authorized_keys` ของทุกผู้ใช้ | จับการฝัง SSH key เพื่อคงอยู่ (persistence) |
| 22.16 | เฝ้า cron และ systemd unit directory | จับช่องทาง persistence ที่พบบ่อย |
| 22.17 | เฝ้า `/boot` และ directory ของ kernel module | จับการเปลี่ยน boot chain |
| 22.18 | ทำบัญชี SUID/SGID เป็น baseline | เก็บรายการไฟล์ setuid ตอนระบบสะอาด |
| 22.19 | แจ้งเตือนเมื่อมีไฟล์ SUID ใหม่ | เทียบกับ baseline 22.18 (คู่กับ Lab 23.18 และ Lab 35) |
| 22.20 | ลดสัญญาณรบกวน: `ignore` และ `restrict` | ตัด path ที่เปลี่ยนตลอดเวลาออกอย่างปลอดภัย |
| 22.21 | labeled rules: ติด tag ให้กลุ่มไฟล์ | ให้ rule ของ Wazuh แยก severity ตาม tag |
| 22.22 | เฝ้า directory ใน PATH ที่เขียนได้ | จับการวาง binary ปลอมแซงคำสั่งจริง |
| 22.23 | ตรวจและ resync ฐานข้อมูล FIM | แก้เมื่อ baseline เพี้ยนหลังอัปเดตใหญ่ |
| 22.24 | เชื่อม FIM กับ whodata (auditd) | ให้ alert บอก “ใคร” และ “process ใด” แก้ไฟล์ |
| 22.25 | แยก severity ตามกลุ่มไฟล์ | ไฟล์ identity = critical, ไฟล์ทั่วไป = ต่ำ |
| 22.26 | รวม FIM ของทุก agent ด้วย agent group | แจก config FIM จากที่เดียว (เชื่อม Lab 34) |

## Lab 23.10–23.29: หมวดหมู่ของ Audit Rule (ต่อจาก 23.6 Drop Events)

อิงหมวดหมู่มาตรฐานของ Linux Audit (แนว CIS Benchmark) ทุก rule มี key เฉพาะเพื่อให้ Wazuh และ `ausearch -k` ดึงได้

| หัวข้อ | ชื่อ | key | สิ่งที่จับ |
| --- | --- | --- | --- |
| 23.10 | การเปลี่ยนเวลาระบบ | `time-change` | แก้นาฬิกาเพื่อกลบ timeline |
| 23.11 | การแก้ฐานข้อมูลผู้ใช้/กลุ่ม | `identity` | แก้ passwd, shadow, group ตรง ๆ |
| 23.12 | การแก้ค่า network | `system-locale` | แก้ hostname, hosts, NetworkManager |
| 23.13 | การแก้ MAC policy | `MAC-policy` | แก้ค่า SELinux (คู่กับ Lab 8) |
| 23.14 | บันทึก login/logout | `logins` | การเข้าออกระบบและ faillog |
| 23.15 | session records | `session` | utmp/wtmp/btmp |
| 23.16 | การเปลี่ยนสิทธิ์ DAC | `perm_mod` | ต่อจาก rule เดิม ครอบคลุม attr |
| 23.17 | การเข้าถึงไฟล์ที่ถูกปฏิเสธ | `access` | EACCES/EPERM สัญญาณการสำรวจ |
| 23.18 | การใช้ privileged command | `privileged` | รันไฟล์ SUID (สร้างจากบัญชี 22.18) |
| 23.19 | การ mount สื่อ | `mounts` | mount อุปกรณ์หรือ filesystem |
| 23.20 | การลบไฟล์โดยผู้ใช้ | `delete` | unlink/rename จำนวนมาก |
| 23.21 | การแก้ขอบเขต sudoers | `scope` | แก้ sudoers ระดับ syscall |
| 23.22 | การใช้ sudo | `actions` | การยกสิทธิ์ผ่าน sudo |
| 23.23 | การแก้ค่าของ auditd เอง | — + immutable `-e 2` | ป้องกันผู้โจมตีปิด audit |
| 23.24 | การแก้ kernel parameter | `sysctl` | เปลี่ยน ip_forward, kptr_restrict |
| 23.25 | การตั้ง cron/at | `cron` | ช่องทาง persistence แบบตั้งเวลา |
| 23.26 | การติดตั้ง/ลบ software | `software_mgmt` | dnf/rpm เพิ่มหรือถอด package |
| 23.27 | การส่งข้อมูลออกสื่อ | `export` | เขียนลง USB หรือ media |
| 23.28 | แปลงเลข syscall เป็นชื่อ | — | ทำให้ `ausearch -i` และ Wazuh อ่านง่าย |
| 23.29 | วัดภาระ auditd และปรับ | — | `auditctl -s`, lost events, backlog, rate limit |

---

## Lab 32: ข้อเสนอหัวข้อใหม่ (สารบัญเดิมข้ามจาก 31 ไป 33)

สองทางเลือก ให้คุณเลือก

**ทางเลือก A — เป็นการข้ามเลข:** ไม่มีเนื้อหา 32 คงลำดับ Lab เดิมไว้ และหมายเหตุในเล่มว่าเลข 32 ไม่ใช้

**ทางเลือก B — เพิ่มหัวข้อที่เชื่อม Lab 31 (WordPress/Redis) กับ Lab 33 (Tetragon):**
**Lab 32 Web Application Firewall หน้า WordPress ด้วย ModSecurity + OWASP CRS**
Objective: วาง WAF ที่ชั้น reverse proxy เพื่อ “ตรวจจับก่อน แล้วค่อยบล็อก” คำขอที่เข้าข่ายโจมตีเว็บ และส่ง log เข้า Graylog
- ติดตั้ง ModSecurity + OWASP Core Rule Set ใน container nginx หน้า WordPress
- เริ่มที่โหมด `DetectionOnly` เก็บ log อย่างเดียว ดูผลใน Graylog (แนวเดียวกับ Lab 15 ที่บล็อก Tor แบบค่อยเป็นค่อยไป)
- ปรับลด false positive (ยกเว้น rule ที่ชนกับ WordPress admin) แล้วจึงเปลี่ยนเป็นโหมดบล็อก
- เขียน Wazuh/Graylog rule อ่าน ModSecurity audit log (เชื่อมกับ Lab 29–30)
- เสริมชั้นป้องกัน: WAF จับที่ชั้น HTTP, Tetragon (Lab 29/33) จับที่ชั้น kernel เป็น defense-in-depth

---

## บทที่จะเขียนเนื้อหาเต็ม

| หัวข้อ | บทในหนังสือ |
| --- | --- |
| 10.10 | 6 |
| 16.16 | 10 |
| 22.10–22.26 | 16 |
| 23.10–23.29 | 17 |
| Lab 32 | 22 |
