**English** · [ภาษาไทย](README.th.md)

# Chapter 4 SELinux and systemd

Course lab: 8

SELinux modes and contexts, booleans, semanage port, reading AVC denials with ausearch and audit2why, and managing services with systemctl, unit drop-ins and targets.

What you get at the end of the chapter:

- You fix SELinux problems without disabling SELinux
- You write unit drop-ins to adjust services safely

Status: draft written, waiting to be tested on real machines

Start this chapter from the previous chapter's snapshot. See the [book outline](../docs/book-outline.md)

## Files

| File | Runs on | Purpose |
| --- | --- | --- |
| `guest/ch04-check.sh` | every VM | Checks SELinux, systemd and the mini-lab cleanup |

Run the guest-side script on every machine from Windows:

```powershell
cd tools\windows
.\Invoke-SocLabScript.ps1 -Script ..\..\ch04-selinux-systemd\guest\ch04-check.sh
```
