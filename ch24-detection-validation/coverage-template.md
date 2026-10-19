**English** · [ภาษาไทย](coverage-template.th.md)

# Detection coverage — chapter 24

Fill this in after simulating the signal of each CVE (benign only). Record the time and the rule that fired.
It measures what the system **sees**, not how many rules it has.

| CVE            | Simulated signal                         | Layer that saw it (net/host/kernel) | Rule/alert that fired | Time (to alert) | Detected | Notes / gaps |
| -------------- | ---------------------------------------- | ----------------------------------- | --------------------- | --------------- | -------- | ------------ |
| CVE-2021-44228 | egress outside private ranges (ebpf-01)  |                                     |                       |                 |          |              |
| CVE-2017-5638  | network tool run inside a container      |                                     |                       |                 |          |              |
| CVE-2014-6271  | web → bash (Lab 29)                      |                                     |                       |                 |          |              |
| CVE-2024-6387  | repeated SSH failures from lab-linux-02  |                                     |                       |                 |          |              |
| CVE-2021-4034  | pkexec execve + a new SUID file          |                                     |                       |                 |          |              |
| CVE-2024-3094  | change to a watched system file          |                                     |                       |                 |          |              |

## OWASP Top 10 (2021)

| Category | Signal / test method (benign)       | Detector | Detected | Notes |
| -------- | ----------------------------------- | -------- | -------- | ----- |
| A01 Broken Access Control | curl /wp-admin from lab-linux-02 |          |          |       |
| A02 Cryptographic Failures | FIM on the TLS config          |          |          |       |
| A03 Injection | CRS test strings from Lab 32            |          |          |       |
| A04 Insecure Design | (threat modeling, not detection)  | —        | —        | closed by design |
| A05 Security Misconfiguration | FIM test + port check     |          |          |       |
| A06 Vulnerable Components | Wazuh vuln / dnf check-update  |          |          |       |
| A07 Auth Failures | brute-force (24.3.5)                |          |          |       |
| A08 Integrity Failures | FIM test on a WordPress file   |          |          |       |
| A09 Logging/Monitoring | logger → confirm it reaches Graylog |     |          |       |
| A10 SSRF | egress test (24.3.2)                         |          |          |       |

## Summary
- Biggest gap (a signal no layer saw, or saw too late):
- Plan to close the gaps (rules/policies to add):
