**English** · [ภาษาไทย](proposed-subtopics.th.md)

# Newly added subtopics (approved)

Designed to continue the existing content of the 8 section documents. Every topic focuses on configuration that **detects and prevents**. Tests use harmless events (normal system commands, or test files that are deleted immediately). For full attack simulation, use published test suites such as Atomic Red Team: read the steps in that tool's own documentation and run them in an isolated lab.

Status: **approved** (12 Oct 2026) — every topic as proposed, and Lab 32 uses option B

---

## Lab 10.10 (between 10.9 sudoers and 10.11 Create Group)

**10.10 Locking, unlocking and disabling user accounts (account lockout and offboarding)**
Objective: correctly disable an account that has left or been compromised, without deleting it (so file ownership and evidence are kept)
- The difference between 3 methods: `usermod -L` / `passwd -l` (lock the password), setting the shell to `/sbin/nologin`, and setting an account expiry date with `usermod -e`
- Why locking only the password is not enough when the account has an SSH key — you must also disable the shell or remove the key
- Link to Lab 22: the changes these commands make to `/etc/shadow` and `/etc/passwd` must show up in FIM
- Verify: `passwd -S <user>`, `chage -l <user>`, and a login test that must be refused

---

## Lab 16.16 (within 16.2–16.17 Cloudflare Tunnel and Nginx)

**16.16 Connecting cloudflared to Nginx over a Docker network, then reloading**
Objective: connect the `cloudflared` container to the reverse proxy built in 16.15 and apply the new config without taking the service down
- Add `cloudflared` to `docker-compose.yml` on the same network as nginx, with ingress pointing to `http://nginx:80`
- `docker compose up -d cloudflared`, then `docker compose exec nginx nginx -t && nginx -s reload`
- Check the tunnel with `docker compose logs cloudflared` (you must see `Registered tunnel connection`)
- Verify: open the public hostname and get the Graylog login page over HTTPS

---

## Lab 22.10–22.26: In-depth Syscheck (FIM) (continuing from 22.2 System Binary Integrity)

| Topic | Title | What it teaches |
| --- | --- | --- |
| 22.10 | syscheck modes: scheduled, realtime, whodata | Choosing a mode for each directory and the effect on system load |
| 22.11 | Tuning `frequency` and `scan_on_start` | Setting the scan interval and reducing load at boot |
| 22.12 | `report_changes`: see which lines of a file changed | Keeping diffs of important config files |
| 22.13 | `nodiff`: keep secret file content out of alerts | For `/etc/shadow`, keys and files that contain secrets |
| 22.14 | Watching `/etc/sudoers` and `/etc/sudoers.d` | Detecting privilege grants that bypass FreeIPA |
| 22.15 | Watching every user's `authorized_keys` | Catching planted SSH keys used for persistence |
| 22.16 | Watching cron and the systemd unit directories | Catching common persistence paths |
| 22.17 | Watching `/boot` and the kernel module directory | Catching changes to the boot chain |
| 22.18 | Making a SUID/SGID inventory as a baseline | Recording the setuid files while the system is clean |
| 22.19 | Alerting when a new SUID file appears | Comparing with the 22.18 baseline (pairs with Lab 23.18 and Lab 35) |
| 22.20 | Reducing noise: `ignore` and `restrict` | Safely excluding paths that change all the time |
| 22.21 | Labeled rules: tagging groups of files | Letting Wazuh rules set severity by tag |
| 22.22 | Watching writable directories in PATH | Catching fake binaries planted ahead of real commands |
| 22.23 | Checking and resyncing the FIM database | Fixing a baseline that drifted after a big update |
| 22.24 | Combining FIM with whodata (auditd) | Making alerts say "who" and "which process" changed the file |
| 22.25 | Severity by file group | Identity files = critical, ordinary files = low |
| 22.26 | Distributing FIM to every agent with an agent group | FIM config from one place (links to Lab 34) |

## Lab 23.10–23.29: Audit rule categories (continuing from 23.6 Drop Events)

Based on the standard Linux Audit categories (CIS Benchmark style). Every rule has its own key so Wazuh and `ausearch -k` can pull it out

| Topic | Title | key | What it catches |
| --- | --- | --- | --- |
| 23.10 | Changes to the system time | `time-change` | Changing the clock to cover up the timeline |
| 23.11 | Changes to the user/group database | `identity` | Editing passwd, shadow, group directly |
| 23.12 | Changes to network settings | `system-locale` | Editing hostname, hosts, NetworkManager |
| 23.13 | Changes to the MAC policy | `MAC-policy` | Changing SELinux settings (pairs with Lab 8) |
| 23.14 | Login/logout records | `logins` | Logins, logouts and faillog |
| 23.15 | Session records | `session` | utmp/wtmp/btmp |
| 23.16 | DAC permission changes | `perm_mod` | Extends the existing rule to cover attributes |
| 23.17 | Denied file access | `access` | EACCES/EPERM, a sign of reconnaissance |
| 23.18 | Use of privileged commands | `privileged` | Running SUID files (built from the 22.18 inventory) |
| 23.19 | Mounting media | `mounts` | Mounting devices or filesystems |
| 23.20 | File deletion by users | `delete` | Mass unlink/rename |
| 23.21 | Changes to sudoers scope | `scope` | Editing sudoers at the syscall level |
| 23.22 | Use of sudo | `actions` | Privilege elevation through sudo |
| 23.23 | Changes to auditd itself | — + immutable `-e 2` | Stops an attacker from turning audit off |
| 23.24 | Changes to kernel parameters | `sysctl` | Changing ip_forward, kptr_restrict |
| 23.25 | Setting up cron/at | `cron` | Scheduled persistence |
| 23.26 | Installing/removing software | `software_mgmt` | dnf/rpm adding or removing packages |
| 23.27 | Exporting data to media | `export` | Writing to USB or other media |
| 23.28 | Translating syscall numbers to names | — | Makes `ausearch -i` and Wazuh easier to read |
| 23.29 | Measuring and tuning auditd load | — | `auditctl -s`, lost events, backlog, rate limit |

---

## Lab 32: proposed new topic (the original outline jumps from 31 to 33)

Two options for you to choose from

**Option A — treat it as a skipped number:** no content for 32, keep the original lab order, and note in the book that number 32 is not used

**Option B — add a topic that links Lab 31 (WordPress/Redis) and Lab 33 (Tetragon):**
**Lab 32 Web Application Firewall in front of WordPress with ModSecurity + OWASP CRS**
Objective: place a WAF at the reverse proxy layer to "detect first, then block" requests that look like web attacks, and send its logs to Graylog
- Install ModSecurity + the OWASP Core Rule Set in the nginx container in front of WordPress
- Start in `DetectionOnly` mode, logging only, and look at the results in Graylog (the same gradual approach as blocking Tor in Lab 15)
- Reduce false positives (exempt rules that collide with WordPress admin), then switch to blocking mode
- Write Wazuh/Graylog rules that read the ModSecurity audit log (links to Lab 29–30)
- Extra layer of protection: the WAF catches at the HTTP layer, Tetragon (Lab 29/33) catches at the kernel layer — defense in depth

---

## Chapters where the full content is written

| Topic | Book chapter |
| --- | --- |
| 10.10 | 6 |
| 16.16 | 10 |
| 22.10–22.26 | 16 |
| 23.10–23.29 | 17 |
| Lab 32 | 22 |
