**English** · [ภาษาไทย](README.th.md)

# Chapter 22 Application and Web Logging: Nginx, WordPress, Redis and WAF

Course labs: 28, 29, 30, 31, 32

Send application logs to Graylog, separate the Nginx and WordPress logs, write rules that detect and block shell execution in WordPress, speed things up with Redis, and put a Web Application Firewall (ModSecurity + OWASP CRS) in front — detecting first, then blocking.

What you get at the end of the chapter:

- Web stack logs that are separated and searchable
- Web shell detection
- A tuned WAF that sends its logs to Graylog

Status: chapter fully written. Lab files: `guest/ch22-check.sh` and config in `files/` (still to be confirmed on real machines)

For the newly added subtopics see [docs/proposed-subtopics.md](../docs/proposed-subtopics.md)
