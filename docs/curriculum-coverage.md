**English** · [ภาษาไทย](curriculum-coverage.th.md)

# Course outline vs. available content

Each topic in the 40-lab course outline checked against the 8 section documents and the book chapters (checked 11 Oct 2026)

Status: **Complete** = every subtopic has content · **Partly missing** = some subtopics have no content yet · **To confirm** = the topic title must be checked against the original outline

| Lab | Topic in the outline | Section doc | Book chapter | Status | Notes |
| --- | --- | --- | --- | --- | --- |
| 1 | Install Rocky Linux 10.1 | 1 | 1 | Complete | Chapter 1 written |
| 2 | Config Network | 1 | 2 | Complete | Must be adapted to a lab where cloud-init has already set the IP (NIC `eth0`, the cloud-init connection) |
| 3 | Install SSH | 1 | 2 | Complete | Must explain the `50-cloud-init.conf` drop-in that cloud-init creates |
| 4 | Checking the Linux Kernel Version | 1 | 3 | Complete | |
| 5 | Config Hostname | 1 | 2 | Complete | Must fix the `/etc/hosts` entry where cloud-init maps the FQDN to 127.0.0.1 |
| 6 | Timezone and NTP | 1 | 3 | Complete | Added: pve-01 is the lab's NTP server |
| 7 | Check Rocky Linux Version | 1 | 1, 3 | Complete | |
| 8 | Understanding SELinux and Systemctl | 1 | 4 | Complete | |
| 9 | Command Line Fundamentals 9.1–9.15 | 2 | 5 | Complete | All 15 topics present |
| 10 | Manage local users and groups 10.1–10.13 | 2 | 6 | Filled in | 10.10 Locking, unlocking and disabling user accounts (new topic) |
| 11 | LAB IPA | 2 | 7 | Complete | Install, join, password policy, HBAC, sudo, SSH keys, LDAP |
| 12 | SSH Key Authentication | 2 | 8 | Complete | |
| 13 | Limit session SSH | 2 | 8 | Complete | |
| 14 | CrowdSec Ban IP ssh Brute-force | 3 | 9 | Complete | |
| 15 | Block Anonymous Proxies / Tor | 3 | 9 | Complete | |
| 16 | Project-Graylog 16.1–16.25 | 4 | 10, 11 | Filled in | 16.16 Connecting cloudflared to Nginx (new topic) |
| 17 | Searching | 4 | 12 | Complete | |
| 18 | CrowdSec on Graylog | 4 | 13 | Complete | |
| 19 | SSH GeoIP from foreign IPs | 4 | 13 | Complete | |
| 20 | Global Threat Intelligence Dashboard | 4 | 13 | Complete | |
| 21 | Project Wazuh 21.1–21.26 | 5 | 14, 15 | Complete | Split into parts A–E, all 26 topics |
| 22 | Syscheck (FIM) & Identity Monitoring | 5 | 16 | Filled in | 22.10–22.26 in-depth FIM, 17 topics (new topics) |
| 23 | Auditd File 23.1–23.35 | 5 | 17 | Filled in | 23.10–23.29 audit rule categories, 20 topics (new topics) |
| 24 | Docker Lab 24.1–24.49 | 6 | 18 | Complete | Split into parts A–F, all 49 topics |
| 25 | SOC Analyst Mode through FreeIPA | 7 | 20 | Complete | |
| 26 | Dashboard Sudo Access Violation | 7 | 20 | Complete | |
| 27 | Git Command Tracking and Blocking | 7 | 21 | Complete | |
| 28 | Config App log to Graylog | 7 | 22 | Complete | |
| 29 | Block Shell Execution in WordPress | 7 | 22 | Complete | |
| 30 | Centralized Web Logging | 7 | 22 | Complete | |
| 31 | WordPress + Redis Cache | 7 | 22 | Complete | |
| 32 | Web Application Firewall in front of WordPress (ModSecurity + OWASP CRS) | – | 22 | Filled in | New topic, option B |
| 33 | Install Tetragon | 6 | 19 | Complete | |
| 34 | Group Agent on Wazuh | 8 | 14 | Complete | |
| 35 | Kill SUID/SGID creation commands | 6 | 19 | Complete | |
| 36 | Monitor sensitive file access | 6 | 19 | Complete | |
| 37 | Account Activity Tracker | 6 | 19 | Complete | |
| 38 | Wazuh Alert to LINE / Telegram | 8 | 23 | Complete | Uses the LINE Messaging API instead of LINE Notify, which has shut down |
| 39 | Wazuh notifications through Gmail | 8 | 23 | Complete | |
| 40 | Change port wazuh | 8 | 23 | Complete | |

## Summary

Every topic in the outline has content or an approved topic title. Details of the newly added topics are in [proposed-subtopics.md](proposed-subtopics.md)
