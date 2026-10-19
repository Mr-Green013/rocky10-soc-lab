**English** · [ภาษาไทย](README.th.md)

# Chapter 17 config files

Copies of the files that chapter 17 creates with `sudo tee FILE <<'EOF'`, laid out by their real path on the machine. Use them to compare against what you typed, or copy them instead of typing (check machine-specific values such as IP addresses and the domain name first). Comment lines that start with `EN:` are English translations of the Thai comment on the next line; they do not change how the file works.

| File in repo | Location on the machine | Note |
| --- | --- | --- |
| `files/etc/audit/rules.d/10-base.rules` | `/etc/audit/rules.d/10-base.rules` | |
| `files/etc/audit/rules.d/30-soc.rules` | `/etc/audit/rules.d/30-soc.rules` | |
| `files/etc/audit/rules.d/20-exclude.rules` | `/etc/audit/rules.d/20-exclude.rules` | |
| `files/etc/audit/rules.d/40-cis.rules` | `/etc/audit/rules.d/40-cis.rules` | |
| `files/etc/audit/rules.d/41-audit-self.rules` | `/etc/audit/rules.d/41-audit-self.rules` | |
| `files/etc/audit/rules.d/99-finalize.rules` | `/etc/audit/rules.d/99-finalize.rules` | |
| `files/etc/audit/rules.d/26-web.rules` | `/etc/audit/rules.d/26-web.rules` | |
| `files/usr/local/sbin/proctitle-api.py` | `/usr/local/sbin/proctitle-api.py` | |
| `files/etc/systemd/system/proctitle-api.service` | `/etc/systemd/system/proctitle-api.service` | |
