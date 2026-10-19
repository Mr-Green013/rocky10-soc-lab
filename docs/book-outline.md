**English** · [ภาษาไทย](book-outline.th.md)

# Book outline: SOC Lab on Rocky Linux 10

From Linux administrator to Security Operations with FreeIPA, CrowdSec, Graylog, Wazuh and eBPF

## Who it is for

- **Beginners**: little or no Linux experience. Read every chapter in order
- **System admins moving into security**: already comfortable with Linux. Do chapter 1, then skim Parts 1–2 (do only the "Verification" sections and the "Security view" boxes), and start in earnest from Part 3

## The lab

| Machine | IP | VM ID | vCPU / RAM / Disk | Role |
| --- | --- | --- | --- | --- |
| Windows (host) | 192.168.10.100 | – | – | admin workstation, Hyper-V |
| pve-01 | 192.168.10.1 (lab), 172.31.255.2 (uplink) | – | 20 / 56 GB / 600 GB | Proxmox VE, lab gateway |
| ipa-01 | 192.168.10.10 | 110 | 2 / 4 GB / 40 GB | FreeIPA (IdM, DNS, CA) |
| graylog-01 | 192.168.10.20 | 120 | 4 / 10 GB / 100 GB | Graylog 7.1 (SIEM) |
| wazuh-01 | 192.168.10.30 | 130 | 4 / 8 GB / 100 GB | Wazuh 4.14 (XDR/SOAR) |
| lab-linux-01 | 192.168.10.41 | 141 | 2 / 2 GB / 32 GB | Linux server, git server |
| lab-linux-02 | 192.168.10.42 | 142 | 2 / 2 GB / 32 GB | attack simulation machine, Samba |
| node-01 | 192.168.10.50 | 150 | 4 / 6 GB / 64 GB | Docker, Tetragon, WordPress |

Domain `lab.internal`, admin user `aod`, template `rocky10-tpl` (VM ID 9000)

## Contents

| Part | Ch. | Title | Course labs | Machines used | Snapshot at the end |
| --- | --- | --- | --- | --- | --- |
| 0 Preparing the lab | 1 | Building the Lab: Proxmox VE on Hyper-V and Rocky Linux 10 | 1, 7 | Windows, pve-01, every VM | `ch01-base` |
| 1 System and network basics | 2 | Network, SSH and Hostname | 2, 3, 5 | every VM | `ch02-network` |
| | 3 | Kernel, System Version, Timezone and NTP | 4, 6, 7 | every VM | `ch03-time` |
| | 4 | SELinux and systemd | 8 | lab-linux-01 | – |
| 2 Commands and identity | 5 | The Command Line a SOC Uses Every Day | 9.1–9.15 | lab-linux-01 | – |
| | 6 | Users, Groups and Password Policy | 10.1–10.13 | lab-linux-01 | `ch06-users` |
| | 7 | Centralized Identity with FreeIPA | 11 | ipa-01 + every VM | `ch07-ipa` |
| | 8 | SSH Hardening: Key Authentication and Session Limits | 12, 13 | lab-linux-01/02 | `ch08-ssh` |
| 3 Basic threat defense | 9 | CrowdSec: Banning Brute-force and Blocking Tor/Proxies | 14, 15 | lab-linux-01/02 | `ch09-crowdsec` |
| 4 SIEM with Graylog | 10 | Installing Graylog and Exposing It Safely | 16 (install, Cloudflare Tunnel, Nginx, SSL) | graylog-01 | `ch10-graylog` |
| | 11 | Ingesting Logs: Inputs, rsyslog, Streams and Pipelines | 16 (Inputs, rsyslog, Streams, Pipeline Rules) | graylog-01 + every VM | `ch11-ingest` |
| | 12 | Searching and Investigating in Graylog | 17 | graylog-01 | `ch12-search` |
| | 13 | Threat Intelligence: CrowdSec, GeoIP and a Global Dashboard | 18, 19, 20 | graylog-01 | `ch13-ti` |
| 5 Wazuh: detection and response | 14 | Installing Wazuh, Agents and Agent Groups | 21 (native deploy, Filebeat, Agent), 34 | wazuh-01 + every VM | `ch14-wazuh` |
| | 15 | Rules, Tuning and Active Response | 21 (Syscheck rule, Tuning, Brute-force, Auto-defense, Dashboard) | wazuh-01 | `ch15-rules` |
| | 16 | File Integrity and Identity Monitoring | 22 | wazuh-01, lab-linux-01/02 | – |
| | 17 | Linux Audit (auditd) for Investigation | 23 | lab-linux-01, node-01 | `ch17-auditd` |
| 6 Containers and eBPF | 18 | Docker Runtime Security | 24 | node-01 | `ch18-docker` |
| | 19 | Tetragon: Seeing and Stopping Threats at the Kernel Level | 33, 35, 36, 37 | node-01 | `ch19-ebpf` |
| 7 Advanced SOC operations | 20 | SOC Analyst Access and a Sudo Violation Dashboard | 25, 26 | ipa-01, graylog-01 | `ch20-soc` |
| | 21 | Tracking and Blocking Git Commands in Real Time | 27 | lab-linux-01 | `ch21-git` |
| | 22 | Application and Web Logging: Nginx, WordPress, Redis and WAF | 28, 29, 30, 31, 32 | node-01, graylog-01 | `ch22-web` |
| 8 Alerting and tuning | 23 | Alerts to LINE, Telegram and Gmail; Changing Wazuh Ports | 38, 39, 40 | wazuh-01 | `ch23-final` |
| 9 Detection readiness | 24 | Attack Simulation in the Lab to Study Defense (Detection Validation) | Wrap-up (uses the detectors from chapters 8, 9, 15–19, 22) | wazuh-01, graylog-01, node-01, lab-linux-01/02 | – |
| Appendices | A | Building the Lab on Azure with Terraform | – | – | – |
| | B | Ports, Services and Firewall Rules of Every Machine | – | – | – |
| | C | Map of Wazuh Rule IDs and Graylog Streams | – | – | – |
| | D | Index of Problems and Fixes (collected from every chapter) | – | – | – |
| | E | Thai–English Glossary | – | – | – |

Note: the original course outline skips Lab number 32. This book adds Lab 32 Web Application Firewall (ModSecurity + OWASP CRS) in chapter 22 and fills in the missing subtopics (10.10, 16.16, 22.10–22.26, 23.10–23.29) according to the approved `docs/proposed-subtopics.md`

## Chapter summaries

**Chapter 1 Building the Lab: Proxmox VE on Hyper-V and Rocky Linux 10** (Lab 1, 7)  
Enable nested virtualization on Hyper-V, install Proxmox VE 9, create a lab network separate from the home LAN, install Rocky Linux 10 from the ISO, build a golden image and clone it into 6 machines with cloud-init  
You get: a 7-machine lab that can be checked automatically; the rocky10-tpl template for new machines; snapshots and backups of the whole lab

**Chapter 2 Network, SSH and Hostname** (Lab 2, 3, 5)  
Set the IP, DNS and search domain with nmcli, read NetworkManager profiles, set an FQDN hostname and /etc/hosts the way FreeIPA expects, then install and check sshd, including the order in which files in sshd_config.d are read  
You get: every machine has an FQDN that resolves to its real IP; you understand which file sshd reads a value from first (sshd -T)

**Chapter 3 Kernel, System Version, Timezone and NTP** (Lab 4, 6, 7)  
Check the kernel and system version with uname, rpm and os-release, set the Asia/Bangkok timezone and chrony so every machine agrees on the time, and see why clocks that drift apart make it impossible to investigate an incident from logs  
You get: every machine syncs its time from the same source; you can read chronyc sources and tracking

**Chapter 4 SELinux and systemd** (Lab 8)  
SELinux modes and contexts, booleans, semanage port, reading AVC denials with ausearch and audit2why, and managing services with systemctl, unit drop-ins and targets  
You get: you fix SELinux problems without disabling SELinux; you write unit drop-ins to adjust services safely

**Chapter 5 The Command Line a SOC Uses Every Day** (Lab 9.1–9.15)  
Filesystem layout, moving around directories, nano, handling output, sudo and sudoers, filtered journalctl, rsync, shutdown and I/O redirection, using real logs from the lab as examples  
You get: you search and filter logs with journalctl, grep and awk; you copy evidence with rsync while preserving metadata

**Chapter 6 Users, Groups and Password Policy** (Lab 10.1–10.13)  
The structure of /etc/passwd and /etc/shadow, a script that creates many users, password history and aging, super user rights, locking and disabling accounts (offboarding) and managing groups, including checking the NOPASSWD rights that cloud-init granted in chapter 1  
You get: a password policy that is really enforced through PAM; you know where attackers escalate privileges through accounts and groups

**Chapter 7 Centralized Identity with FreeIPA** (Lab 11)  
Install FreeIPA with DNS and a CA, join every machine to the domain, set the password policy, HBAC rules, sudo rules and centralized SSH keys, and query data over LDAP  
You get: one account logs in to every machine; ipa-01 is the DNS server for the whole lab

**Chapter 8 SSH Hardening: Key Authentication and Session Limits** (Lab 12, 13)  
How SSH key authentication works, turning off password authentication, and limiting sessions and connections with MaxSessions, MaxStartups, ClientAlive and PAM limits  
You get: SSH that accepts keys only and limits sessions; you read sshd login logs correctly

**Chapter 9 CrowdSec: Banning Brute-force and Blocking Tor/Proxies** (Lab 14, 15)  
Install CrowdSec, the sshd acquisition and scenario and the firewall bouncer, test a simulated brute-force from lab-linux-02, and block Tor exit nodes and anonymous proxies with a blocklist  
You get: IPs that brute-force are banned automatically; you can manage decisions and the allowlist

**Chapter 10 Installing Graylog and Exposing It Safely** (Lab 16)  
Install Graylog 7.1 with Docker Compose on Rocky 10, put an Nginx reverse proxy with TLS in front of it, and make it reachable from outside through Cloudflare Tunnel without opening a port  
You get: Graylog reachable over HTTPS; you understand the parts of Graylog, MongoDB and the search backend

**Chapter 11 Ingesting Logs: Inputs, rsyslog, Streams and Pipelines** (Lab 16)  
Create Syslog and GELF inputs, send logs from every machine with rsyslog, split them into streams by type, and write pipeline rules that extract SSH fields for SOC work  
You get: logs from every machine reach Graylog in real time; SSH event fields ready for searching

**Chapter 12 Searching and Investigating in Graylog** (Lab 17)  
The Graylog search language, filtering authentication events, USER_START, and multi-level conditions for tracking admin accounts, with saved searches  
You get: you answer the investigation questions who, what, where and when from logs

**Chapter 13 Threat Intelligence: CrowdSec, GeoIP and a Global Dashboard** (Lab 18, 19, 20)  
Bring CrowdSec decisions into Graylog, add GeoIP to IP addresses, test SSH from foreign IPs with simulated events, and build a threat map dashboard  
You get: a threat dashboard with geographic locations

**Chapter 14 Installing Wazuh, Agents and Agent Groups** (Lab 21, 34)  
Install the Wazuh manager, indexer and dashboard, ship alerts with Filebeat, install an agent on every machine, and group agents so configuration is distributed by the machine's role  
You get: every machine reports to Wazuh; agent groups that split config by role

**Chapter 15 Rules, Tuning and Active Response** (Lab 21)  
Custom decoders and rules (ID range 100000–100999), reducing false positives, detecting brute-force, active response that blocks IPs automatically, and a dashboard of blocked IPs  
You get: tuned rules tested with wazuh-logtest; automatic responses that can be undone

**Chapter 16 File Integrity and Identity Monitoring** (Lab 22)  
Scheduled, realtime and whodata syscheck to watch important files; keeping diffs of config files without leaking secrets; watching sudoers, authorized_keys, cron, /boot and a baseline of SUID files; detecting group changes and impersonation with usermod; watching an SMB share and alerting on mass file deletion  
You get: you know who changed which file and when; alerts on mass file deletion

**Chapter 17 Linux Audit (auditd) for Investigation** (Lab 23)  
Write audit rules by standard category (time-change, identity, logins, privileged, mounts, delete, sudoers, software, export and more), use ausearch and aureport, measure and tune the load of auditd, and write rules that detect techniques at the syscall level  
You get: audit rules that detect attack techniques at the syscall level

**Chapter 18 Docker Runtime Security** (Lab 24)  
Simulate container attacks — terminal hijacking, DoS, data exfiltration — detect them with Falco and eBPF, and prevent them with runtime settings  
You get: detection of abnormal behavior inside containers in real time

**Chapter 19 Tetragon: Seeing and Stopping Threats at the Kernel Level** (Lab 33, 35, 36, 37)  
Install Tetragon on node-01 and write TracingPolicies that kill commands creating SUID/SGID files, watch access to sensitive files, and track user account activity  
You get: you stop a dangerous process instantly at the kernel level

**Chapter 20 SOC Analyst Access and a Sudo Violation Dashboard** (Lab 25, 26)  
Let analysts log in to Graylog with their FreeIPA account over LDAP, assign roles, and build a dashboard of sudo use that breaks policy  
You get: SOC team permissions managed from one place

**Chapter 21 Tracking and Blocking Git Commands in Real Time** (Lab 27)  
Track git commands with audit and logs, send the events to the SIEM, and block pushes that break policy with a hook  
You get: visibility and control over source code changes

**Chapter 22 Application and Web Logging: Nginx, WordPress, Redis and WAF** (Lab 28, 29, 30, 31, 32)  
Send application logs to Graylog, separate the Nginx and WordPress logs, write rules that detect and block shell execution in WordPress, speed things up with Redis, and put a Web Application Firewall (ModSecurity + OWASP CRS) in front — detecting first, then blocking  
You get: web stack logs that are separated and searchable; web shell detection; a tuned WAF that sends its logs to Graylog

**Chapter 23 Alerts to LINE, Telegram and Gmail; Changing Wazuh Ports** (Lab 38, 39, 40)  
Wazuh integrations that send alerts to the LINE Messaging API (replacing LINE Notify, which has shut down), a Telegram bot and Gmail through an SMTP relay, plus moving the Wazuh dashboard port with matching firewall rules  
You get: important alerts reach your phone within seconds

**Chapter 24 Attack Simulation in the Lab to Study Defense (Detection Validation)** (wrap-up)  
Map 6 real CVEs (Log4Shell, Struts2, Shellshock, regreSSHion, PwnKit, xz/liblzma) and the OWASP Top 10 onto the book's 3 detection layers, explain the red team attack lifecycle from the defender's point of view, then simulate **only the signal** each detector looks for with harmless steps (brute-force against a user that does not exist, a test web shell that only runs `id`, and sending marker data out of a container to a documentation IP) to measure detection coverage  
You get: a detection coverage table with the gaps that still need closing; `ch24-check.sh` checks that every detection layer is ready

## Reading paths

- **The whole book (beginners)**: chapters 1 → 24 in order
- **Fast track (admins)**: chapters 1 → 7 → 8 → 9 → 10–13 → 14–17 → pick from 18–23 as your work needs → 24
- **SIEM only**: chapters 1, 2, 7, 10–13
- **Detection & Response only**: chapters 1, 2, 7, 14–17, 19, 23, 24

A chapter with a snapshot at the end is a point you can roll back to and restart the next chapter from
