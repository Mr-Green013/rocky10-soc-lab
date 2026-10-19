**English** · [ภาษาไทย](topic-verification.th.md)

# Topic verification (12 Oct 2026)

Two checks: (1) whether the book covers every topic in the 40-lab course outline, and (2) whether the topic titles, versions and technical facts are still correct as of the check date

## 1. Completeness

- Every topic in the 40-lab outline is in the book. Details are in [curriculum-coverage.md](curriculum-coverage.md)
- Lab number 32 is not in the original outline. This book fills it with a WAF (ModSecurity + OWASP CRS) in chapter 22
- The subtopics with missing numbers (10.10, 16.16, 22.10–22.26, 23.10–23.29) have been filled in according to [proposed-subtopics.md](proposed-subtopics.md)
- The order in the book differs from the outline in 2 places, because the groundwork has to come first:
  - Lab 34 (Group Agent) is in chapter 14, right after installing the agents, because chapters 15–17 distribute config through agent groups
  - Lab 33, 35–37 (Tetragon) are in chapter 19, right after Docker, because they use node-01 and the eBPF basics from chapter 18

## 2. Topic titles that were changed

| Lab | Title in the outline | Title used in the book | Reason |
| --- | --- | --- | --- |
| 1 | Install Rocky Linux 10.1 | Install Rocky Linux 10 (10.1 or later) | Rocky 10.2 is out (28 May 2026); `dnf upgrade` takes the machine to the latest release anyway |
| 8 | Understanding SELinux and Systemctl | SELinux and systemd | `systemctl` is one command of systemd; the chapter also teaches units, drop-ins and targets |
| 38 | Create a LINE Access Token | Create a Channel Access Token for the LINE Messaging API | LINE Notify shut down on 31 Mar 2025 |
| 39 | Wazuh Integration notifications through Gmail | Gmail through a Postfix relay with an App Password | Gmail requires 2-Step Verification and an App Password; "less secure apps" are no longer supported |

## 3. Versions checked

| Software | In the book | Latest at the check date | Result |
| --- | --- | --- | --- |
| Rocky Linux | 10.x (written on 10.1) | 10.2 (28 May 2026), kernel 6.12 | Correct. Added a note to chapter 1 that /boot on 10.2 = 2 GiB |
| Proxmox VE | 9.2 | 9.2 | Correct |
| Graylog | 7.1 | 7.1.x (latest 7.1.9) | Correct |
| Wazuh | 4.14 | 4.14.8; 5.0 is still beta | Correct. The book stays on 4.14. Wazuh officially supports RHEL 10 for the central components |
| Tetragon | 1.7.1 | 1.7.1 (Aug 2026) | Correct |
| Falco | 0.45 | 0.45.0 (21 Sep 2026) | Correct |

## 4. Facts the chapters not yet written had to get right

| Ch. | Issue | What to write |
| --- | --- | --- |
| 5 | Rocky 10.2: `vi` always opens a minimal editor | The book uses `nano` anyway; tell readers that to use vim they should install `vim-enhanced` and run `vim` |
| 6 | Rocky 10 changed the password hash to yescrypt | The password field in `/etc/shadow` starts with `$y$`, not `$6$` (SHA-512) |
| 6 | Rocky 10: the root account is locked by default | Admin work must go through a user with sudo, which matches the lab already |
| 6 | Password history and faillock | Use `authselect enable-feature with-pwhistory` and `with-faillock` instead of editing PAM files by hand |
| 7 | FreeIPA on EL10 | There is no `idm` module stream any more; install directly with `dnf install ipa-server ipa-server-dns` |
| 9 | CrowdSec on EL10 | Install from the official repo (`install.crowdsec.net`). The free plan only allows a limited number of Tor/Proxy blocklists from the Console; check the number again when writing the chapter |
| 10, 18 | Docker CE on Rocky 10 | dockerd may fail to start with `addrtype ... missing kernel module`; the fix is `dnf install kernel-modules-extra`, then reboot into the new kernel. Must go in "Troubleshooting" |
| 13 | GeoIP | Needs the MaxMind GeoLite2 City database, which requires a free account and a license key. Never commit the key to the repo |
| 18 | Containers on EL10 | cgroup v2 is the default and Podman uses `crun`. Explain that Docker CE works with cgroup v2, unlike older docs that still talk about cgroup v1 |
| 20 | Graylog Open and LDAP | Graylog Open supports LDAP authentication, but syncing groups to roles needs Enterprise, so the chapter sets a default role for users who log in through LDAP |
| 22 | ModSecurity | Trustwave stopped maintaining it on 1 Jul 2024 and handed it over to OWASP. OWASP CRS supports both ModSecurity and Coraza. Lab 32 uses the official `owasp/modsecurity-crs:nginx` image on node-01 instead of building it, with a callout suggesting Coraza as an alternative |
| 23 | LINE | Send messages through the Messaging API (`/v2/bot/message/push`) with a channel access token read from a secret file with mode 600 |

## Code and lab file checks (13 Oct 2026)

Every code block in the book and every file in the repo was checked automatically. The results confirm syntax and references; they do not replace running on real machines

| What was checked | Tool | Result |
| --- | --- | --- |
| 336 bash blocks and 49 script files | `bash -n`, `shellcheck -S warning` | Pass (fixed an unused variable in `find-rocky-image.sh`, changed the block label for sudoers) |
| 5 PowerShell files | PowerShell 7 parser | Pass |
| 100 custom Wazuh rules | Checked `if_sid`, `if_group`, `if_matched_*`, `decoded_as` against the Wazuh v4.14.0 ruleset | Pass, no duplicate IDs |
| 42 Graylog pipeline rules | `rule/when/then/end` structure, brackets, function names | Pass |
| 12 TracingPolicies | JSON schema from the Tetragon v1.7.1 CRD | Pass |
| 2 Docker Compose files | Compose Specification schema | Pass |
| 2 nginx files (including the Lab 31 page cache) | `nginx -t` | Pass (`http2 on` needs nginx 1.25.1 or later, which `nginx:stable` supports) |
| 169 audit rule lines | Syscall names with `ausyscall x86_64` | Pass |
| XML, YAML, JSON, Python | Standard parsers, `py_compile`, `pyflakes` | Pass |

Consistency fixes in this round: snapshot names of chapters 12, 19, 20 and 21 in `book-outline.md`, rules 100811/100813 of `suid-guard`, and study plan days 12, 16, 19, 24–26 and 35–58 to match the user names, groups, files and rules in the chapters

## References

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
