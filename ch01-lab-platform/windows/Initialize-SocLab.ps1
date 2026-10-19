<#
.SYNOPSIS
  EN: Chapter 1 step 11: post-clone tasks for every lab machine (run from Windows)
  บทที่ 1 ขั้นที่ 11: งานหลัง clone ของทุกเครื่องใน lab (รันจาก Windows)

.DESCRIPTION
  EN: For each machine in lab-hosts.csv:
  สำหรับแต่ละเครื่องใน lab-hosts.csv:
    EN: 1. Wait for port 22 to open (cloud-init has finished the first boot)
    1. รอให้ port 22 เปิด (cloud-init บูตครั้งแรกเสร็จ)
    EN: 2. Copy guest\post-clone.sh and guest\soclab-check.sh to /tmp
    2. คัดลอก guest\post-clone.sh และ guest\soclab-check.sh ไปที่ /tmp
    EN: 3. Run post-clone.sh with sudo: grow the disk, disable cloud-init, install soclab-check
    3. รัน post-clone.sh ด้วย sudo: ขยาย disk, ปิด cloud-init, ติดตั้ง soclab-check
  EN: Uses the ssh/scp that ships with Windows (OpenSSH client) and the key in ssh-agent or -KeyPath
  ใช้ ssh/scp ที่มากับ Windows (OpenSSH client) และ key ใน ssh-agent หรือ -KeyPath

.EXAMPLE
  .\Initialize-SocLab.ps1
  .\Initialize-SocLab.ps1 -Name ipa-01,node-01
#>
[CmdletBinding()]
param(
    [string[]] $Name,
    [string]   $User      = 'aod',
    [string]   $KeyPath   = (Join-Path $env:USERPROFILE '.ssh\id_ed25519'),
    [string]   $HostsCsv  = (Join-Path $PSScriptRoot '..\..\lab-hosts.csv'),
    [int]      $WaitSeconds = 300
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

$guest = Join-Path $PSScriptRoot '..\guest'
$files = @((Join-Path $guest 'post-clone.sh'), (Join-Path $guest 'soclab-check.sh'))
foreach ($f in $files) { if (-not (Test-Path $f)) { throw "ไม่พบ $f" } }
if (-not (Get-Command ssh -ErrorAction SilentlyContinue)) { throw 'ไม่พบ ssh: ติดตั้ง OpenSSH Client ใน Settings > System > Optional features' }

$sshOpts = @('-o', 'StrictHostKeyChecking=accept-new', '-o', 'ConnectTimeout=10')
if (Test-Path $KeyPath) { $sshOpts += @('-i', $KeyPath) }

$hosts = Import-Csv $HostsCsv
if ($Name) { $hosts = $hosts | Where-Object { $Name -contains $_.name } }

$results = foreach ($h in $hosts) {
    Write-Host "==> $($h.name) ($($h.ip))" -ForegroundColor Cyan
    $deadline = (Get-Date).AddSeconds($WaitSeconds)
    while (-not (Test-TcpPort $h.ip 22)) {
        if ((Get-Date) -gt $deadline) { break }
        Start-Sleep -Seconds 5
    }
    if (-not (Test-TcpPort $h.ip 22)) {
        Write-Warning "$($h.name): port 22 ไม่เปิดภายใน $WaitSeconds วินาที ดู console ของ VM $($h.vmid)"
        [pscustomobject]@{ Name = $h.name; IP = $h.ip; Result = 'NO-SSH' }; continue
    }
    $target = "$User@$($h.ip)"
    & scp @sshOpts $files "${target}:/tmp/" | Out-Host
    if ($LASTEXITCODE -ne 0) { [pscustomobject]@{ Name = $h.name; IP = $h.ip; Result = 'SCP-FAIL' }; continue }
    # EN: sed strips CR in case git on Windows converted the file to CRLF
    # sed ลบ CR เผื่อ git บน Windows แปลงไฟล์เป็น CRLF
    & ssh @sshOpts $target "sed -i 's/\r`$//' /tmp/post-clone.sh /tmp/soclab-check.sh && sudo bash /tmp/post-clone.sh" | Out-Host
    $r = if ($LASTEXITCODE -eq 0) { 'OK' } else { "FAIL($LASTEXITCODE)" }
    [pscustomobject]@{ Name = $h.name; IP = $h.ip; Result = $r }
}
$results | Format-Table -AutoSize
Write-Host 'ขั้นต่อไป: .\Test-SocLab.ps1'
