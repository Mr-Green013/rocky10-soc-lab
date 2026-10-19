**English** · [ภาษาไทย](README.th.md)

# Chapter 3 Kernel, System Version, Timezone and NTP

Course labs: 4, 6, 7

Check the kernel and system version with uname, rpm and os-release, set the Asia/Bangkok timezone and chrony so every machine agrees on the time, and see why clocks that drift apart make it impossible to investigate an incident from logs.

What you get at the end of the chapter:

- Every machine syncs its time from the same source
- You can read chronyc sources and tracking

Status: draft written, waiting to be tested on real machines

Start this chapter from the previous chapter's snapshot. See the [book outline](../docs/book-outline.md)

## Files

| File | Runs on | Purpose |
| --- | --- | --- |
| `proxmox/pve-ntp-server.sh` | pve-01 | chrony on pve-01 serves time to the lab |
| `guest/set-time.sh` | every VM | Timezone, and chrony pointed at pve-01 |
| `guest/ch03-check.sh` | every VM | Checks the kernel, BTF, OS and time |

Run the guest-side script on every machine from Windows:

```powershell
cd tools\windows
.\Invoke-SocLabScript.ps1 -Script ..\..\ch03-kernel-time-ntp\guest\ch03-check.sh
```
