**English** · [ภาษาไทย](README.th.md)

# Chapter 22 config files

Copies of the files that chapter 22 creates with `sudo tee FILE <<'EOF'`, laid out by their real path on the machine. Use them to compare against what you typed, or copy them instead of typing (check machine-specific values such as IP addresses and the domain name first). Comment lines that start with `EN:` are English translations of the Thai comment on the next line; they do not change how the file works.

| File in repo | Location on the machine | Note |
| --- | --- | --- |
| `files/opt/orders-api/orders_api.py` | `/opt/orders-api/orders_api.py` | |
| `files/etc/systemd/system/orders-api.service` | `/etc/systemd/system/orders-api.service` | |
| `files/etc/rsyslog.d/91-legacy-app.conf` | `/etc/rsyslog.d/91-legacy-app.conf` | |
| `files/opt/wordpress/compose.yaml` | `/opt/wordpress/compose.yaml` | |
| `files/opt/wordpress/nginx/default.conf` | `/opt/wordpress/nginx/default.conf` | |
| `files/etc/logrotate.d/wp-nginx` | `/etc/logrotate.d/wp-nginx` | |
| `files/opt/wordpress/waf/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf` | `/opt/wordpress/waf/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf` | |
