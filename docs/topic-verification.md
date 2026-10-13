# ตรวจความถูกต้องของหัวข้อ (12 ต.ค. 2026)

ตรวจ 2 เรื่อง: (1) หัวข้อในเล่มครบตามสารบัญหลักสูตร 40 Lab หรือไม่ (2) ชื่อหัวข้อ เวอร์ชัน และข้อเท็จจริงทางเทคนิคยังถูกต้อง ณ วันที่ตรวจหรือไม่

## 1. ความครบถ้วน

- หัวข้อในสารบัญ 40 Lab อยู่ในเล่มครบทุกหัวข้อ รายละเอียดอยู่ใน [curriculum-coverage.md](curriculum-coverage.md)
- เลข Lab 32 ไม่มีในสารบัญต้นฉบับ เล่มนี้เติมเป็น WAF (ModSecurity + OWASP CRS) ในบทที่ 22
- หัวข้อย่อยที่เลขขาด (10.10, 16.16, 22.10–22.26, 23.10–23.29) เติมแล้วตาม [proposed-subtopics.md](proposed-subtopics.md)
- ลำดับในเล่มต่างจากสารบัญ 2 จุด เพราะต้องมีพื้นฐานก่อน:
  - Lab 34 (Group Agent) อยู่บทที่ 14 ถัดจากติดตั้ง agent เพราะบทที่ 15–17 แจก config ผ่าน agent group
  - Lab 33, 35–37 (Tetragon) อยู่บทที่ 19 ถัดจาก Docker เพราะใช้ node-01 และพื้นฐาน eBPF จากบทที่ 18

## 2. ชื่อหัวข้อที่แก้

| Lab | ชื่อในสารบัญ | ชื่อที่ใช้ในเล่ม | เหตุผล |
| --- | --- | --- | --- |
| 1 | Install Rocky Linux 10.1 | ติดตั้ง Rocky Linux 10 (10.1 ขึ้นไป) | Rocky 10.2 ออกแล้ว (28 พ.ค. 2026) `dnf upgrade` จะพาเครื่องไปรุ่นล่าสุดอยู่ดี |
| 8 | Understanding SELinux and Systemctl | SELinux และ systemd | `systemctl` เป็นคำสั่งหนึ่งของ systemd บทนี้สอน unit, drop-in และ target ด้วย |
| 38 | สร้าง LINE Access Token | สร้าง Channel Access Token ของ LINE Messaging API | LINE Notify ปิดบริการแล้วเมื่อ 31 มี.ค. 2025 |
| 39 | Wazuh Integration แจ้งเตือนผ่าน Gmail | Gmail ผ่าน Postfix relay ด้วย App Password | Gmail ต้องเปิด 2-Step Verification และใช้ App Password ไม่รองรับ "less secure apps" แล้ว |

## 3. เวอร์ชันที่ตรวจแล้ว

| ซอฟต์แวร์ | ในเล่ม | ล่าสุด ณ วันที่ตรวจ | ผล |
| --- | --- | --- | --- |
| Rocky Linux | 10.x (เขียนบน 10.1) | 10.2 (28 พ.ค. 2026), kernel 6.12 | ถูกต้อง เพิ่มหมายเหตุ /boot ของ 10.2 = 2 GiB ในบทที่ 1 แล้ว |
| Proxmox VE | 9.2 | 9.2 | ถูกต้อง |
| Graylog | 7.1 | 7.1.x (ล่าสุด 7.1.9) | ถูกต้อง |
| Wazuh | 4.14 | 4.14.8; 5.0 ยังเป็น beta | ถูกต้อง เล่มใช้ 4.14 ต่อ Wazuh รองรับ RHEL 10 สำหรับ central components อย่างเป็นทางการ |
| Tetragon | 1.7.1 | 1.7.1 (ส.ค. 2026) | ถูกต้อง |
| Falco | 0.45 | 0.45.0 (21 ก.ย. 2026) | ถูกต้อง |

## 4. ข้อเท็จจริงที่ต้องเขียนให้ตรงในบทที่ยังไม่เขียน

| บท | ประเด็น | สิ่งที่ต้องเขียน |
| --- | --- | --- |
| 5 | Rocky 10.2: `vi` เปิด editor แบบ minimal เสมอ | เล่มใช้ `nano` เป็นหลักอยู่แล้ว บอกผู้อ่านว่าถ้าจะใช้ vim ให้ติดตั้ง `vim-enhanced` แล้วสั่ง `vim` |
| 6 | Rocky 10 เปลี่ยน hash ของรหัสผ่านเป็น yescrypt | ช่องรหัสผ่านใน `/etc/shadow` ขึ้นต้นด้วย `$y$` ไม่ใช่ `$6$` (SHA-512) |
| 6 | Rocky 10: บัญชี root ถูกล็อกโดยค่าเริ่มต้น | งาน admin ต้องผ่านผู้ใช้ที่มี sudo ซึ่งตรงกับ lab อยู่แล้ว |
| 6 | password history และ faillock | ใช้ `authselect enable-feature with-pwhistory` และ `with-faillock` แทนการแก้ไฟล์ PAM เอง |
| 7 | FreeIPA บน EL10 | ไม่มี module stream `idm` แล้ว ติดตั้งด้วย `dnf install ipa-server ipa-server-dns` ตรงๆ |
| 9 | CrowdSec บน EL10 | ติดตั้งจาก repo ทางการ (`install.crowdsec.net`) ส่วน blocklist ของ Tor/Proxy จาก Console ให้ subscribe ได้จำนวนจำกัดใน plan ฟรี ต้องตรวจจำนวนอีกครั้งตอนเขียนบท |
| 10, 18 | Docker CE บน Rocky 10 | dockerd อาจ start ไม่ขึ้นด้วย error `addrtype ... missing kernel module` วิธีแก้คือ `dnf install kernel-modules-extra` แล้ว reboot เข้า kernel ใหม่ ต้องใส่ไว้ใน "วิธีแก้ปัญหา" |
| 13 | GeoIP | ต้องใช้ฐานข้อมูล MaxMind GeoLite2 City ซึ่งต้องสมัครบัญชีฟรีและใช้ license key ห้าม commit key ลง repo |
| 18 | Container บน EL10 | cgroup v2 เป็นค่าเริ่มต้น และ Podman ใช้ `crun` อธิบายว่า Docker CE ใช้ cgroup v2 ได้ ต่างจากเอกสารเก่าที่ยังพูดถึง cgroup v1 |
| 20 | Graylog Open กับ LDAP | Graylog Open ใช้ LDAP authentication ได้ แต่การ sync group ไปเป็น role ต้องใช้ Enterprise บทนี้จึงกำหนด default role ให้ผู้ใช้ที่ login ผ่าน LDAP |
| 22 | ModSecurity | Trustwave เลิกดูแลตั้งแต่ 1 ก.ค. 2024 และส่งต่อให้ OWASP ดูแลต่อ ส่วน OWASP CRS รองรับทั้ง ModSecurity และ Coraza Lab 32 จะใช้ image ทางการ `owasp/modsecurity-crs:nginx` บน node-01 แทนการ build เอง และมีกล่องข้อความแนะนำ Coraza เป็นทางเลือก |
| 23 | LINE | ส่งข้อความผ่าน Messaging API (`/v2/bot/message/push`) ด้วย channel access token ที่อ่านจาก secret file ซึ่งมีสิทธิ์ 600 |

## การตรวจโค้ดและไฟล์ Lab (13 ต.ค. 2026)

ตรวจอัตโนมัติทุก code block ในหนังสือและทุกไฟล์ใน repo ผลยืนยันไวยากรณ์และการอ้างอิง ไม่ได้แทนการรันบนเครื่องจริง

| สิ่งที่ตรวจ | เครื่องมือ | ผล |
| --- | --- | --- |
| bash 336 block และ script 49 ไฟล์ | `bash -n`, `shellcheck -S warning` | ผ่าน (แก้ตัวแปรไม่ได้ใช้ใน `find-rocky-image.sh`, เปลี่ยนป้าย block ของ sudoers) |
| PowerShell 5 ไฟล์ | PowerShell 7 parser | ผ่าน |
| Wazuh custom rule 100 ตัว | ตรวจ `if_sid`, `if_group`, `if_matched_*`, `decoded_as` กับ ruleset ของ Wazuh v4.14.0 | ผ่าน ไม่มี ID ซ้ำ |
| Graylog pipeline rule 42 ตัว | โครง `rule/when/then/end`, วงเล็บ, ชื่อฟังก์ชัน | ผ่าน |
| TracingPolicy 12 ตัว | JSON schema จาก CRD ของ Tetragon v1.7.1 | ผ่าน |
| Docker Compose 2 ไฟล์ | Compose Specification schema | ผ่าน |
| nginx 2 ไฟล์ (รวม page cache ของ Lab 31) | `nginx -t` | ผ่าน (`http2 on` ต้องใช้ nginx 1.25.1 ขึ้นไป ซึ่ง `nginx:stable` รองรับ) |
| audit rule 169 บรรทัด | ชื่อ syscall ด้วย `ausyscall x86_64` | ผ่าน |
| XML, YAML, JSON, Python | parser มาตรฐาน, `py_compile`, `pyflakes` | ผ่าน |

ความสอดคล้องที่แก้ในรอบนี้: ชื่อ snapshot ของบทที่ 12, 19, 20, 21 ใน `book-outline.md`, rule 100811/100813 ของ `suid-guard`, แผนเรียนวันที่ 12, 16, 19, 24–26, 35–58 ให้ตรงกับชื่อผู้ใช้ กลุ่ม ไฟล์ และ rule ในบท

## แหล่งอ้างอิง

- [Rocky Linux 10.2 Available Now](https://rockylinux.org/news/rocky-linux-10-2-ga-release)
- [Rocky Linux 10.1 release notes](https://docs.rockylinux.org/releases/release_notes/10_1/)
- [Wazuh release notes](https://documentation.wazuh.com/current/release-notes/) · [Wazuh quickstart (supported OS)](https://documentation.wazuh.com/current/quickstart.html)
- [Announcing Graylog 7.1.9](https://graylog.org/?p=37761)
- [Tetragon releases](https://github.com/cilium/tetragon/releases)
- [Falco releases](https://falco.org/tags/release)
- [Docker installation failed on RHEL 10 (Rocky forum)](https://forums.rockylinux.org/t/docker-installation-failed-on-rhel-10/20024)
- [F5 NGINX ModSecurity WAF EoL / Trustwave handover](https://www.f5.com/company/blog/nginx/f5-nginx-modsecurity-waf-transitioning-to-eol)
- [CRS engine and integration options](https://coreruleset.org/docs/1-getting-started/1-4-engine_integration_options/)
- [LINE Developers: end-of-life notices](https://developers.line.biz/en/news/tags/end-of-life)
- [CrowdSec Console blocklists](https://docs.crowdsec.net/u/console/blocklists/overview)
