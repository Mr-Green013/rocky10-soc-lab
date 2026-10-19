**English** · [ภาษาไทย](README.th.md)

# rocky10-soc-lab

Lab files for the book **SOC Lab on Rocky Linux 10: From Linux Administrator to Security Operations**

A 7-machine lab on Proxmox VE (nested on Windows Hyper-V) for hands-on practice with FreeIPA, CrowdSec, Graylog, Wazuh, auditd, Docker security and eBPF/Tetragon — from installing the systems all the way to detecting and responding to threats automatically. Everything is defensive: attacks are simulated only as harmless signals inside your own isolated lab.

```
Windows 11 Pro (192.168.10.100)
└─ Hyper-V
   └─ pve-01  Proxmox VE 9  (gateway 192.168.10.1)
      ├─ ipa-01        .10  FreeIPA
      ├─ graylog-01    .20  Graylog SIEM
      ├─ wazuh-01      .30  Wazuh
      ├─ lab-linux-01  .41  Linux server
      ├─ lab-linux-02  .42  attacker simulation
      └─ node-01       .50  Docker / Tetragon / WordPress
```

## Getting started

1. Read chapter 1 in the book, or [`ch01-lab-platform/README.md`](ch01-lab-platform/README.md) for the short command sequence
2. Clone this repo on Windows (`git clone` or Download ZIP), then copy it to pve-01 in step 5 of chapter 1
3. Work through the chapters in order. At the end of each chapter that has a snapshot, run `pve-snapshot.sh <name>` so you have a point to roll back to

No Windows machine powerful enough? Use [`infra/azure-terraform`](infra/azure-terraform/README.md) to build the same lab on Azure (Appendix A)

## Two languages

- Docs: `X.md` is English and `X.th.md` is Thai. Every page has a language switcher on its first line
- Comments in scripts and config files have an `EN:` line (English) above the Thai comment. The messages scripts print and rule descriptions stay in Thai so they match the book
- Thai diagrams (the set used in the book) are in `assets/diagrams/chNN/`; the English set is in `assets/diagrams/chNN/en/`
- The tools that keep both languages in sync are in [`tools/i18n/`](tools/i18n/README.md)

## Layout

| Path | Contents |
| --- | --- |
| `lab-hosts.csv` | IP, VM ID and size of every machine (every script reads this file) |
| `docs/` | Book outline ([book-outline.md](docs/book-outline.md)), 60-day study plan ([study-plan.md](docs/study-plan.md)), topic verification ([topic-verification.md](docs/topic-verification.md)) and the book's conventions ([chapter-template.md](docs/chapter-template.md)) |
| `chNN-*/` | Lab files for each chapter, split by where they run: `windows/`, `proxmox/`, `guest/`, plus config files in `files/` |
| `assets/diagrams/` | SVG and PNG sources of the book's diagrams (`en/` = English) |
| `tools/` | Windows scripts used across chapters (`tools/windows/`) and the bilingual tooling (`tools/i18n/`) |
| `infra/azure-terraform/` | Terraform that builds the lab on Azure |

## Contents

| Part | Ch. | Folder | Title | Course labs |
| --- | --- | --- | --- | --- |
| 0 Preparing the lab | 1 | [ch01-lab-platform](ch01-lab-platform/README.md) | Building the Lab: Proxmox VE on Hyper-V and Rocky Linux 10 | 1, 7 |
| 1 System and network basics | 2 | [ch02-network-ssh-hostname](ch02-network-ssh-hostname/README.md) | Network, SSH and Hostname | 2, 3, 5 |
| | 3 | [ch03-kernel-time-ntp](ch03-kernel-time-ntp/README.md) | Kernel, System Version, Timezone and NTP | 4, 6, 7 |
| | 4 | [ch04-selinux-systemd](ch04-selinux-systemd/README.md) | SELinux and systemd | 8 |
| 2 Commands and identity | 5 | [ch05-command-line](ch05-command-line/README.md) | The Command Line a SOC Uses Every Day | 9.1–9.15 |
| | 6 | [ch06-users-groups](ch06-users-groups/README.md) | Users, Groups and Password Policy | 10.1–10.13 |
| | 7 | [ch07-freeipa](ch07-freeipa/README.md) | Centralized Identity with FreeIPA | 11 |
| | 8 | [ch08-ssh-hardening](ch08-ssh-hardening/README.md) | SSH Hardening: Key Authentication and Session Limits | 12, 13 |
| 3 Basic threat defense | 9 | [ch09-crowdsec](ch09-crowdsec/README.md) | CrowdSec: Banning Brute-force and Blocking Tor/Proxies | 14, 15 |
| 4 SIEM with Graylog | 10 | [ch10-graylog-install](ch10-graylog-install/README.md) | Installing Graylog and Exposing It Safely | 16 |
| | 11 | [ch11-graylog-ingest](ch11-graylog-ingest/README.md) | Ingesting Logs: Inputs, rsyslog, Streams and Pipelines | 16 |
| | 12 | [ch12-graylog-search](ch12-graylog-search/README.md) | Searching and Investigating in Graylog | 17 |
| | 13 | [ch13-threat-intel](ch13-threat-intel/README.md) | Threat Intelligence: CrowdSec, GeoIP and a Global Dashboard | 18, 19, 20 |
| 5 Wazuh: detection and response | 14 | [ch14-wazuh-install](ch14-wazuh-install/README.md) | Installing Wazuh, Agents and Agent Groups | 21, 34 |
| | 15 | [ch15-wazuh-rules](ch15-wazuh-rules/README.md) | Rules, Tuning and Active Response | 21 |
| | 16 | [ch16-fim-identity](ch16-fim-identity/README.md) | File Integrity and Identity Monitoring | 22 |
| | 17 | [ch17-auditd](ch17-auditd/README.md) | Linux Audit (auditd) for Investigation | 23 |
| 6 Containers and eBPF | 18 | [ch18-docker-security](ch18-docker-security/README.md) | Docker Runtime Security | 24 |
| | 19 | [ch19-tetragon](ch19-tetragon/README.md) | Tetragon: Seeing and Stopping Threats at the Kernel Level | 33, 35, 36, 37 |
| 7 Advanced SOC operations | 20 | [ch20-soc-access](ch20-soc-access/README.md) | SOC Analyst Access and a Sudo Violation Dashboard | 25, 26 |
| | 21 | [ch21-git-tracking](ch21-git-tracking/README.md) | Tracking and Blocking Git Commands in Real Time | 27 |
| | 22 | [ch22-web-logging](ch22-web-logging/README.md) | Application and Web Logging: Nginx, WordPress, Redis and WAF | 28, 29, 30, 31, 32 |
| 8 Alerting and tuning | 23 | [ch23-alerting](ch23-alerting/README.md) | Alerts to LINE, Telegram and Gmail; Changing Wazuh Ports | 38, 39, 40 |
| 9 Detection readiness | 24 | [ch24-detection-validation](ch24-detection-validation/README.md) | Attack Simulation in the Lab to Study Defense (Detection Validation) | Wrap-up |

Details of each chapter, the machines it uses and its snapshot are in [docs/book-outline.md](docs/book-outline.md)

## Cautions

- This lab simulates attacks (brute-force, web shell, container escape) with harmless tools and data. Run them only inside the lab network
- There are no passwords or tokens in the repo. Scripts that need a secret ask for it at run time
- `*.sh` files must always use LF line endings (`.gitattributes` handles this when you clone with git). If you edit files on Windows, use an editor that can save LF, such as VS Code
