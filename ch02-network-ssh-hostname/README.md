**English** · [ภาษาไทย](README.th.md)

# Chapter 2 Network, SSH and Hostname

Course labs: 2, 3, 5

Set the IP, DNS and search domain with nmcli, read NetworkManager profiles, set an FQDN hostname and /etc/hosts the way FreeIPA expects, then install and check sshd, including the order in which files in sshd_config.d are read.

What you get at the end of the chapter:

- Every machine has an FQDN that resolves to its real IP
- You understand which file sshd reads a value from first (sshd -T)

Status: draft written, waiting to be tested on real machines

Start this chapter from the previous chapter's snapshot. See the [book outline](../docs/book-outline.md)

## Files

| File | Runs on | Purpose |
| --- | --- | --- |
| `guest/set-identity.sh` | every VM | Sets the FQDN, the lab /etc/hosts and the profile named lab |
| `guest/ch02-check.sh` | every VM | Checks network, hostname and SSH |
| `../tools/windows/Set-SocLabHosts.ps1` | Windows (Admin) | The Windows hosts file and ~/.ssh/config |

Run the guest-side script on every machine from Windows:

```powershell
cd tools\windows
.\Invoke-SocLabScript.ps1 -Script ..\..\ch02-network-ssh-hostname\guest\set-identity.sh -Files ..\..\lab-hosts.csv
```

`Set-SocLabHosts.ps1` runs directly on Windows, in PowerShell as Admin:

```powershell
cd tools\windows
.\Set-SocLabHosts.ps1
```
