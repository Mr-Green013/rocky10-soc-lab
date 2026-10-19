**English** · [ภาษาไทย](README.th.md)

# SOC Lab on Azure with Terraform

Build every machine of course Labs 1–40 on Azure with one command, with a base config that can replace Labs 1–8 (hostname, FQDN, timezone, `/etc/hosts`, firewalld, SELinux enforcing, user `aod` + SSH key). Every machine's IP matches the course documents, so you can keep following the commands in them.

## What gets created

| Resource | Name | Notes |
| --- | --- | --- |
| Resource group | `rg-soclab` | Delete everything with `terraform destroy` |
| VNet / subnet | `vnet-soclab` 192.168.0.0/16, `snet-lab` 192.168.10.0/24 | Gateway .1 belongs to Azure |
| NSG | `nsg-soclab-lab` | Only SSH from `admin_source_cidrs` to admin-01 is open |
| NAT Gateway + public IP | `ng-soclab` | The single way out to the internet for every machine |
| 7 VMs | per the table below | Rocky Linux 10.1, no password, SSH key only |
| Auto-shutdown | every VM | Deallocates every day at 22:00 (Thailand time) |

| Machine | IP | Default size | Disk | Role |
| --- | --- | --- | --- | --- |
| admin-01 | 192.168.10.100 (+ public IP) | Standard_B2s | 32 GB | Jump host in place of the admin workstation |
| ipa-01 | 192.168.10.10 | Standard_B2ms | 64 GB | FreeIPA |
| graylog-01 | 192.168.10.20 | Standard_B4ms | 128 GB | Graylog 7.1 (Docker Compose) |
| wazuh-01 | 192.168.10.30 | Standard_B4ms | 128 GB | Wazuh all-in-one |
| lab-linux-01 | 192.168.10.41 | Standard_B2s | 32 GB | Linux server, git server |
| lab-linux-02 | 192.168.10.42 | Standard_B2s | 32 GB | Attack simulation machine, Samba |
| node-01 | 192.168.10.50 | Standard_B2ms | 64 GB | Docker, Falco, Tetragon, WordPress |

18 vCPUs in total, all B-series

## Prerequisites

1. Azure CLI logged in (`az login`, `az account set -s <subscription>`)
2. Terraform 1.6 or later
3. An SSH key: `ssh-keygen -t ed25519` if you do not have one yet
4. Enough B-series quota in your region for 18 vCPUs (new subscriptions often get less than this)

```bash
az vm list-usage -l southeastasia -o table | grep -E "Total Regional vCPUs|Standard BS Family"
```

If it is not enough, request more in the portal under **Quotas → Compute**, or reduce the sizes with `vm_sizes`

## Steps

### 1. Find the Rocky Linux 10.1 image

The Marketplace SKU name of Rocky 10, and whether it has a plan, differ by region. Check every time

```bash
./scripts/find-rocky-image.sh southeastasia
```

The script prints an `image = { ... }` block to copy into `terraform.tfvars`. If Rocky 10 is not found in that region, change the region or use `image.source = "image_id"` with an image from the Community Gallery or your own Azure Compute Gallery

If the image has a plan, accept the terms once per subscription

```bash
az vm image terms accept --urn resf:rockylinux-x86_64:<sku>:latest
```

### 2. Configure

```bash
cp terraform.tfvars.example terraform.tfvars
curl -s https://api.ipify.org; echo        # your public IP; put it in admin_source_cidrs as x.x.x.x/32
vi terraform.tfvars
```

### 3. Create

```bash
terraform init
terraform plan -out lab.tfplan
terraform apply lab.tfplan
```

### 4. Connect

```bash
terraform output -raw ssh_config >> ~/.ssh/config
ssh ipa-01                     # goes through admin-01 automatically with ProxyJump
./scripts/check-lab.sh         # checks cloud-init, FQDN, SELinux, firewalld, timezone, DNS, internet
```

What `check-lab.sh` should show: every machine `CLOUDINIT=done`, `SELINUX=Enforcing`, `FIREWALL=active`, `TZ=Asia/Bangkok`, and node-01 resolves every `*.lab.internal` name

Open the Web UIs through an SSH tunnel (the full commands are in `terraform output web_ui_tunnels`)

| UI | URL on your own machine |
| --- | --- |
| Graylog | http://localhost:9000 |
| Wazuh dashboard | https://localhost:8443 (after Lab 40, change the destination to 192.168.10.30:8443) |
| WordPress | http://localhost:8081 |

### 5. Switch DNS to FreeIPA (after Lab 11)

FreeIPA with its built-in DNS has to be the DNS server of every machine, so this is done in 2 rounds

1. Install IPA on ipa-01 as in Lab 11, with the Azure DNS as forwarder

    ```bash
    sudo ipa-server-install --setup-dns --forwarder=168.63.129.16 \
      --realm LAB.INTERNAL --domain lab.internal --no-ntp
    ```

    `--no-ntp` keeps the machine on the Hyper-V clock (PTP) provided by Azure

2. Set `use_ipa_dns = true`, then `terraform apply`
3. Make every machine pick up the new DNS: `sudo systemctl restart NetworkManager` or reboot, then check with `resolvectl status` or `cat /etc/resolv.conf`

After this round, ipa-01 must always start before the other machines, otherwise they cannot resolve names

## Labs that change when running on Azure

| Lab | In the documents | On Azure |
| --- | --- | --- |
| 1 Install Rocky | Install from the ISO | The machines come from an image; use this lab to review `hostnamectl`, `lsblk`, `rpm -qa` instead |
| 2 Config Network | Set a static IP with `nmcli` on `ens160` | The NIC is named `eth0` and the IP is set on the Azure NIC. **Never set a static IP inside the machine** — it will drop off the network. Practice `nmcli` by reading values, setting the DNS search domain, or creating a connection on a dummy interface instead |
| 6 NTP | Point chrony at an NTP server | Look at `chronyc sources` first. If there is a `PHC0` refclock (`/dev/ptp_hyperv`), the Hyper-V clock is already in use. You may add NTP servers, but do not remove the refclock |
| 11 FreeIPA | The lab DNS | Use step 5 above |
| 14 CrowdSec | Attack from lab-linux-02 | Same as before; the lab machines have no public IP, so there is no real brute force from the internet |
| 16 Graylog | Cloudflare Tunnel | Works as before (it is outbound through the NAT Gateway) |
| 19 GeoIP | Data from foreign IPs | Inject events with `logger` as in the documents |
| 39 Gmail | Postfix relay on port 587 | Azure blocks outbound port 25, but 587 works |
| 40 Change port | A rich rule letting 192.168.10.100 reach the dashboard | 192.168.10.100 is admin-01, so follow the documents as written |
| every section | snapshot `m0X-...-done` | `./scripts/snapshot.sh m05-done` (incremental snapshot of every machine's OS disk) |

## Cost and starting/stopping

Charged even while the VMs are off: managed disks (480 GB in total), the NAT Gateway, 2 public IPs and snapshots. VMs are charged only while running. Estimate the real price with the Azure Pricing Calculator for your region

```bash
RG=rg-soclab
# Start: ipa-01 first, then the other machines
az vm start -g $RG -n vm-ipa-01
az vm start --ids $(az vm list -g $RG --query "[?name!='vm-ipa-01'].id" -o tsv)
# Stop and stop paying for compute
az vm deallocate --ids $(az vm list -g $RG --query "[].id" -o tsv)
# Delete the whole lab (snapshots in the same RG are deleted too)
terraform destroy
```

## Lab security

- The only way in from the internet is SSH to admin-01 from the IPs you list. If your home IP changes, update `admin_source_cidrs` and apply
- There are no passwords in any file. The state only holds IPs and SSH public keys, but you should still keep the state somewhere safe or move it to a remote backend (the `azurerm` backend on a Storage Account)
- After Lab 29 (simulated web shell) and Lab 24 (container attacks), delete the test files per each lab's cleanup before opening a tunnel to anyone else

## Limitations and things to check yourself

- These files have not been through a real `terraform validate` or `apply` (the sandbox they were written in could not download the provider). Three things were checked: the HCL syntax of every file, that all 102 arguments exist in the azurerm v4.81.0 documentation, and that the rendered cloud-init passes the cloud-init schema checker
- The Marketplace SKU of Rocky 10 (`10-base` is the default) and whether it needs a plan have not been confirmed. Use the values from `find-rocky-image.sh`
- If you restore an OS disk from a snapshot by swapping the disk in the portal, Terraform will see `os_disk` change and propose recreating the VM. Treat snapshots as backups and restore only when necessary
- B-series VMs are burstable. If Graylog or Wazuh uses CPU continuously until the credits run out, they slow down a lot; switch to `Standard_D4as_v5` through `vm_sizes`
