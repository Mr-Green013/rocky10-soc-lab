**English** · [ภาษาไทย](README.th.md)

# Chapter 19 config files

Copies of the files that chapter 19 creates with `sudo tee FILE <<'EOF'`, laid out by their real path on the machine. Use them to compare against what you typed, or copy them instead of typing (check machine-specific values such as IP addresses and the domain name first). Comment lines that start with `EN:` are English translations of the Thai comment on the next line; they do not change how the file works.

| File in repo | Location on the machine | Note |
| --- | --- | --- |
| `files/usr/local/sbin/acct-activity.sh` | `/usr/local/sbin/acct-activity.sh` | |
| `files/etc/tetragon/tetragon.tp.d/10-block-tmp-exec.yaml` | `/etc/tetragon/tetragon.tp.d/10-block-tmp-exec.yaml` | complete file as of the end of the chapter |
| `files/etc/tetragon/tetragon.tp.d/20-guillotine.yaml` | `/etc/tetragon/tetragon.tp.d/20-guillotine.yaml` | complete file as of the end of the chapter |
| `files/etc/tetragon/tetragon.tp.d/30-protect-shadow.yaml` | `/etc/tetragon/tetragon.tp.d/30-protect-shadow.yaml` | complete file as of the end of the chapter |
| `files/etc/tetragon/tetragon.tp.d/40-keyguard.yaml` | `/etc/tetragon/tetragon.tp.d/40-keyguard.yaml` | complete file as of the end of the chapter |
| `files/etc/tetragon/tetragon.tp.d/50-suid-guard.yaml` | `/etc/tetragon/tetragon.tp.d/50-suid-guard.yaml` | complete file as of the end of the chapter |
| `files/etc/tetragon/tetragon.tp.d/60-sensitive-files.yaml` | `/etc/tetragon/tetragon.tp.d/60-sensitive-files.yaml` | complete file as of the end of the chapter |
| `files/etc/tetragon/tetragon.tp.d/70-account-tracker.yaml` | `/etc/tetragon/tetragon.tp.d/70-account-tracker.yaml` | complete file as of the end of the chapter |
| `files/etc/tetragon/tetragon.tp.d/80-egress-private-only.yaml` | `/etc/tetragon/tetragon.tp.d/80-egress-private-only.yaml` | complete file as of the end of the chapter |
| `files/etc/tetragon/tetragon.tp.d/81-connect-audit.yaml` | `/etc/tetragon/tetragon.tp.d/81-connect-audit.yaml` | complete file as of the end of the chapter |
| `files/var/ossec/etc/rules/160-container_rules.tetragon-snippet.xml` | `/var/ossec/etc/rules/160-container_rules.tetragon-snippet.xml` | complete file as of the end of the chapter |
