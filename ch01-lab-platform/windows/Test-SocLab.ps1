<#
.SYNOPSIS
  EN: Chapter 1 verification: check every lab machine from Windows and summarize as a table
  บทที่ 1 วิธีตรวจสอบ: ตรวจทุกเครื่องใน lab จาก Windows แล้วสรุปเป็นตาราง

.DESCRIPTION
  EN: Checks the Proxmox Web UI (192.168.10.1:8006), then SSHes into every machine to run soclab-check
  ตรวจ Proxmox Web UI (192.168.10.1:8006) แล้ว SSH เข้าทุกเครื่องเพื่อรัน soclab-check
  EN: A machine that passes must show: X86_64_V3=yes, SELINUX=Enforcing, FIREWALLD=active, CLOUDINIT=disabled,
  เครื่องที่ผ่านต้องได้: X86_64_V3=yes, SELINUX=Enforcing, FIREWALLD=active, CLOUDINIT=disabled,
  EN: GATEWAY/DNS/INTERNET=ok, and a MACHINE_ID that no other machine has
  GATEWAY/DNS/INTERNET=ok และ MACHINE_ID ไม่ซ้ำกัน

.EXAMPLE
  .\Test-SocLab.ps1
  .\Test-SocLab.ps1 -Detail
#>
[CmdletBinding()]
param(
    [string] $User     = 'aod',
    [string] $KeyPath  = (Join-Path $env:USERPROFILE '.ssh\id_ed25519'),
    [string] $HostsCsv = (Join-Path $PSScriptRoot '..\..\lab-hosts.csv'),
    [switch] $Detail      # แสดงทุกค่า (KERNEL, FQDN, X86_64_V3, ...) ของทุกเครื่อง (EN: show every value (KERNEL, FQDN, X86_64_V3, ...) for every machine)
)
$ErrorActionPreference = 'Stop'

function Test-TcpPort([string]$Ip, [int]$Port, [int]$TimeoutMs = 1500) {
    $c = New-Object System.Net.Sockets.TcpClient
    try {
        $iar = $c.BeginConnect($Ip, $Port, $null, $null)
        if (-not $iar.AsyncWaitHandle.WaitOne($TimeoutMs)) { return $false }
        $c.EndConnect($iar); return $true
    } catch { return $false } finally { $c.Close() }
}

$sshOpts = @('-o', 'BatchMode=yes', '-o', 'ConnectTimeout=8', '-o', 'StrictHostKeyChecking=accept-new')
if (Test-Path $KeyPath) { $sshOpts += @('-i', $KeyPath) }

$pve = Test-TcpPort '192.168.10.1' 8006
Write-Host ("Proxmox Web UI https://192.168.10.1:8006 : {0}" -f $(if ($pve) { 'OK' } else { 'FAIL' }))

$rows = foreach ($h in Import-Csv $HostsCsv) {
    $row = [ordered]@{ Name = $h.name; IP = $h.ip; SSH = 'fail' }
    if (Test-TcpPort $h.ip 22) {
        $out = & ssh @sshOpts "$User@$($h.ip)" 'sudo /usr/local/sbin/soclab-check' 2>$null
        if ($LASTEXITCODE -eq 0 -and $out) {
            $row.SSH = 'ok'
            foreach ($line in $out) {
                if ($line -match '^([A-Z0-9_]+)=(.*)$') { $row[$Matches[1]] = $Matches[2] }
            }
        }
    }
    $o = [pscustomobject]$row
    $problems = @()
    if ($o.SSH -ne 'ok') { $problems += 'ssh' } else {
        if ($o.X86_64_V3 -ne 'yes')      { $problems += 'cpu' }
        if ($o.SELINUX -ne 'Enforcing')  { $problems += 'selinux' }
        if ($o.FIREWALLD -ne 'active')   { $problems += 'firewalld' }
        if ($o.CLOUDINIT -ne 'disabled') { $problems += 'cloud-init' }
        foreach ($k in 'GATEWAY', 'DNS', 'INTERNET') { if ($o.$k -ne 'ok') { $problems += $k.ToLower() } }
    }
    $o | Add-Member -NotePropertyName Status -NotePropertyValue $(if ($problems) { 'FAIL: ' + ($problems -join ',') } else { 'PASS' })
    $o
}

$rows | Format-Table Name, IP, SSH, OS, SELINUX, ROOT_SIZE, INTERNET, MACHINE_ID, Status -AutoSize
if ($Detail) { $rows | Format-List }

$dup = $rows | Where-Object { $_.MACHINE_ID } | Group-Object MACHINE_ID | Where-Object Count -gt 1
if ($dup) { Write-Warning ("machine-id ซ้ำกัน: {0} (golden-prep.sh ไม่ได้ล้าง machine-id)" -f (($dup | ForEach-Object { $_.Group.Name -join '=' }) -join '; ')) }

$failed = @($rows | Where-Object { $_.Status -ne 'PASS' }).Count
if (-not $pve) { $failed++ }
if ($failed -eq 0) { Write-Host 'ผลรวม: ผ่านทุกเครื่อง พร้อมทำ snapshot ch01-base' -ForegroundColor Green }
else { Write-Host "ผลรวม: ไม่ผ่าน $failed รายการ ดูตารางวิธีแก้ปัญหาในบทที่ 1" -ForegroundColor Yellow }
exit $failed
