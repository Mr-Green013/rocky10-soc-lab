**English** · [ภาษาไทย](README.th.md)

# Chapter 9 config files

Copies of the files that chapter 9 creates with `sudo tee FILE <<'EOF'`, laid out by their real path on the machine. Use them to compare against what you typed, or copy them instead of typing (check machine-specific values such as IP addresses and the domain name first). Comment lines that start with `EN:` are English translations of the Thai comment on the next line; they do not change how the file works.

| File in repo | Location on the machine | Note |
| --- | --- | --- |
| `files/etc/ssh/sshd_config.d/00-lab-password.conf` | `/etc/ssh/sshd_config.d/00-lab-password.conf` | |
| `files/etc/crowdsec/parsers/s02-enrich/00-lab-admin-whitelist.yaml` | `/etc/crowdsec/parsers/s02-enrich/00-lab-admin-whitelist.yaml` | |
| `files/usr/local/sbin/crowdsec-tor-import.sh` | `/usr/local/sbin/crowdsec-tor-import.sh` | |
| `files/etc/systemd/system/crowdsec-tor-import.service` | `/etc/systemd/system/crowdsec-tor-import.service` | |
| `files/etc/systemd/system/crowdsec-tor-import.timer` | `/etc/systemd/system/crowdsec-tor-import.timer` | |
