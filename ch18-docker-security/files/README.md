**English** · [ภาษาไทย](README.th.md)

# Chapter 18 config files

Copies of the files that chapter 18 creates with `sudo tee FILE <<'EOF'`, laid out by their real path on the machine. Use them to compare against what you typed, or copy them instead of typing (check machine-specific values such as IP addresses and the domain name first). Comment lines that start with `EN:` are English translations of the Thai comment on the next line; they do not change how the file works.

| File in repo | Location on the machine | Note |
| --- | --- | --- |
| `files/etc/docker/daemon.json` | `/etc/docker/daemon.json` | |
| `files/etc/audit/rules.d/27-container-runtime.rules` | `/etc/audit/rules.d/27-container-runtime.rules` | |
| `files/usr/local/sbin/docker-sock-check.sh` | `/usr/local/sbin/docker-sock-check.sh` | |
| `files/var/ossec/active-response/bin/container-response.sh` | `/var/ossec/active-response/bin/container-response.sh` | |
| `files/etc/falco/config.d/10-lab.yaml` | `/etc/falco/config.d/10-lab.yaml` | |
| `files/etc/logrotate.d/falco` | `/etc/logrotate.d/falco` | |
| `files/etc/falco/rules.d/lab_rules.yaml` | `/etc/falco/rules.d/lab_rules.yaml` | |
| `files/etc/logrotate.d/web-01` | `/etc/logrotate.d/web-01` | |
