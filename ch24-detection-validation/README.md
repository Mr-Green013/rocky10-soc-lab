**English** · [ภาษาไทย](README.th.md)

# Chapter 24 Attack Simulation in the Lab to Study Defense (Detection Validation)

Course labs: wrap-up (uses the detectors from chapters 8, 9, 15–19 and 22)

Map 6 real CVEs (Log4Shell, Struts2, Shellshock, regreSSHion, PwnKit, xz/liblzma) onto the book's 3 detection layers, then simulate **only the signal** each detector looks for, using benign steps that reuse the existing lab, to measure detection coverage.

What you get at the end of the chapter:

- The signals of all 6 CVEs simulated without any real exploit, each raising an alert
- A detection coverage table with the gaps that still need closing

Files in this chapter:

- `guest/ch24-check.sh` — checks that the 3 detection layers are ready (runs no attacks). Run it on wazuh-01, node-01 and lab-linux-01
- `coverage-template.md` — template for the detection coverage table

Safety guidance: work only in an isolated lab. Use test accounts/containers and clean up every time. There are no real exploits or payloads; when an external destination is needed, use documentation IPs (RFC 5737).

Status: chapter fully written. Lab files: `guest/ch24-check.sh` and `coverage-template.md` (still to be confirmed on real machines)

Start this chapter from the `ch23-final` snapshot. See the [book outline](../docs/book-outline.md)
