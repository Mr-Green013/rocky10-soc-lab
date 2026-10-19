**English** · [ภาษาไทย](README.th.md)

# Chapter 21 config files

Copies of the files that chapter 21 creates with `sudo tee FILE <<'EOF'`, laid out by their real path on the machine. Use them to compare against what you typed, or copy them instead of typing (check machine-specific values such as IP addresses and the domain name first). Comment lines that start with `EN:` are English translations of the Thai comment on the next line; they do not change how the file works.

| File in repo | Location on the machine | Note |
| --- | --- | --- |
| `files/etc/git-guard/hooks/pre-push` | `/etc/git-guard/hooks/pre-push` | |
| `files/etc/tetragon/tetragon.tp.d/85-git-egress.yaml` | `/etc/tetragon/tetragon.tp.d/85-git-egress.yaml` | complete file as of the end of the chapter |
| `files/var/ossec/etc/decoders/ch21-git-guard.snippet.xml` | `/var/ossec/etc/decoders/ch21-git-guard.snippet.xml` | complete file as of the end of the chapter |
| `files/var/ossec/etc/rules/ch21-git-rules.snippet.xml` | `/var/ossec/etc/rules/ch21-git-rules.snippet.xml` | complete file as of the end of the chapter |
