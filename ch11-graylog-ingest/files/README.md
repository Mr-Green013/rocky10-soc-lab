**English** · [ภาษาไทย](README.th.md)

# Chapter 11 config files

Copies of the files that chapter 11 creates with `sudo tee FILE <<'EOF'`, laid out by their real path on the machine. Use them to compare against what you typed, or copy them instead of typing (check machine-specific values such as IP addresses and the domain name first). Comment lines that start with `EN:` are English translations of the Thai comment on the next line; they do not change how the file works.

| File in repo | Location on the machine | Note |
| --- | --- | --- |
| `files/etc/systemd/system/docker-user-lab.service` | `/etc/systemd/system/docker-user-lab.service` | |
| `files/etc/rsyslog.d/90-graylog.conf` | `/etc/rsyslog.d/90-graylog.conf` | |
| `files/etc/rsyslog.d/10-audit-local.conf` | `/etc/rsyslog.d/10-audit-local.conf` | |
| `files/graylog/SOC-SSH-pipeline.rules` | Graylog Web UI (System → Pipelines → Manage rules), paste in | complete file as of the end of the chapter |
