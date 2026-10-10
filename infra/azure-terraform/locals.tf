locals {
  # IP plan เดียวกับเอกสารหลักสูตร (หมวด 1, Lab 0)
  # admin-01 แทน "admin workstation 192.168.10.100" และเป็นเครื่องเดียวที่มี public IP
  hosts = {
    "admin-01" = {
      ip      = "192.168.10.100"
      size    = "Standard_B2s"
      disk_gb = 32
      role    = "jump host / admin workstation"
      public  = true
    }
    "ipa-01" = {
      ip      = "192.168.10.10"
      size    = "Standard_B2ms"
      disk_gb = 64
      role    = "FreeIPA (Lab 11, 25)"
      public  = false
    }
    "graylog-01" = {
      ip      = "192.168.10.20"
      size    = "Standard_B4ms"
      disk_gb = 128
      role    = "Graylog 7.1 on Docker Compose (Lab 16-20)"
      public  = false
    }
    "wazuh-01" = {
      ip      = "192.168.10.30"
      size    = "Standard_B4ms"
      disk_gb = 128
      role    = "Wazuh all-in-one (Lab 21-23, 34, 38-40)"
      public  = false
    }
    "lab-linux-01" = {
      ip      = "192.168.10.41"
      size    = "Standard_B2s"
      disk_gb = 32
      role    = "Linux server, git server (Lab 1-15, 27)"
      public  = false
    }
    "lab-linux-02" = {
      ip      = "192.168.10.42"
      size    = "Standard_B2s"
      disk_gb = 32
      role    = "attacker simulation, Samba (Lab 14, 22)"
      public  = false
    }
    "node-01" = {
      ip      = "192.168.10.50"
      size    = "Standard_B2ms"
      disk_gb = 64
      role    = "Docker, Falco, Tetragon, WordPress (Lab 24, 29-37)"
      public  = false
    }
  }

  vms = {
    for name, h in local.hosts : name => merge(h, {
      size = lookup(var.vm_sizes, name, h.size)
    })
  }

  ipa_ip = local.hosts["ipa-01"].ip

  common_tags = merge({
    project    = "soc-lab"
    managed-by = "terraform"
    course     = "rocky-linux-10-soc-labs"
  }, var.tags)

  admin_ssh_public_key = trimspace(file(pathexpand(var.admin_ssh_public_key_path)))

  # /etc/hosts ของทุกเครื่อง: ให้ชื่อ .lab.internal ใช้ได้ตั้งแต่ก่อนมี FreeIPA DNS
  # FreeIPA ต้องการให้ FQDN ของตัวเอง resolve เป็น IP จริง ไม่ใช่ 127.0.0.1
  etc_hosts = join("\n", concat(
    [
      "127.0.0.1   localhost localhost.localdomain localhost4",
      "::1         localhost localhost.localdomain localhost6",
    ],
    [for name, h in local.hosts : "${h.ip} ${name}.${var.domain} ${name}"],
    [""]
  ))

  cloud_init = {
    for name, h in local.vms : name => {
      hostname                  = name
      fqdn                      = "${name}.${var.domain}"
      prefer_fqdn_over_hostname = true
      manage_etc_hosts          = false
      timezone                  = var.guest_timezone
      package_update            = true
      package_upgrade           = var.package_upgrade
      packages = [
        "vim-enhanced", "nano", "tmux", "jq", "bash-completion", "tar", "rsync",
        "curl", "wget", "bind-utils", "policycoreutils-python-utils",
        "firewalld", "chrony",
      ]
      write_files = [
        {
          path        = "/etc/hosts"
          permissions = "0644"
          owner       = "root:root"
          content     = local.etc_hosts
        },
        {
          # เรียงก่อน 10-auth.conf (Lab 12) และ 50-redhat.conf; ไม่แตะ PasswordAuthentication
          # เพื่อให้ Lab 14 เปิด password ชั่วคราวได้ตามเอกสาร
          path        = "/etc/ssh/sshd_config.d/05-soclab-baseline.conf"
          permissions = "0600"
          owner       = "root:root"
          content     = "PermitRootLogin no\n"
        },
        {
          path        = "/etc/motd"
          permissions = "0644"
          owner       = "root:root"
          content     = "SOC lab | ${name}.${var.domain} | ${h.ip}\nrole: ${h.role}\n"
        },
      ]
      runcmd = [
        ["systemctl", "enable", "--now", "chronyd"],
        ["systemctl", "enable", "--now", "firewalld"],
        ["firewall-cmd", "--permanent", "--add-service=ssh"],
        ["firewall-cmd", "--reload"],
        # ถ้า image ปิด SELinux มาตั้งแต่ต้น ต้อง relabel ทั้งเครื่องตอน reboot ครั้งถัดไป
        ["sh", "-c", "[ \"$(getenforce)\" = Disabled ] && touch /.autorelabel; sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config; setenforce 1 || true"],
        ["sh", "-c", "systemctl reload sshd || true"],
        ["sh", "-c", "date -Is > /var/lib/soclab-bootstrap.done"],
      ]
    }
  }

  use_marketplace_image = var.image.source == "marketplace"
}
