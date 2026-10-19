**English** · [ภาษาไทย](README.th.md)

# Chapter 16 config files

Copies of the files that chapter 16 creates with `sudo tee FILE <<'EOF'`, laid out by their real path on the machine. Use them to compare against what you typed, or copy them instead of typing (check machine-specific values such as IP addresses and the domain name first). Comment lines that start with `EN:` are English translations of the Thai comment on the next line; they do not change how the file works.

| File in repo | Location on the machine | Note |
| --- | --- | --- |
| `files/etc/audit/rules.d/25-identity.rules` | `/etc/audit/rules.d/25-identity.rules` | |
| `files/var/ossec/etc/shared/linux/agent.conf` | `/var/ossec/etc/shared/linux/agent.conf` | |
| `files/etc/rsyslog.d/20-samba-audit.conf` | `/etc/rsyslog.d/20-samba-audit.conf` | |
| `files/etc/logrotate.d/smbd_audit` | `/etc/logrotate.d/smbd_audit` | |
| `files/usr/local/sbin/graylog-ti-relay.py` | `/usr/local/sbin/graylog-ti-relay.py` | |
| `files/etc/systemd/system/graylog-ti-relay.service` | `/etc/systemd/system/graylog-ti-relay.service` | |
