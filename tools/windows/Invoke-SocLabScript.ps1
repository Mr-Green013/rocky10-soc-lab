<#
.SYNOPSIS
  EN: Runs any chapter's script on several lab machines at once from Windows
  รัน script ของบทใดก็ได้บนเครื่องใน lab หลายเครื่องพร้อมกันจาก Windows

.DESCRIPTION
  EN: Copies the script (and the extra files in -Files) to /tmp/soclab/ on each machine, then runs it with sudo
  คัดลอก script (และไฟล์ประกอบใน -Files) ไปที่ /tmp/soclab/ ของแต่ละเครื่อง แล้วรันด้วย sudo
  EN: Uses the Windows ssh/scp with the key in ssh-agent, like Initialize-SocLab.ps1 in chapter 1
  ใช้ ssh/scp ของ Windows กับ key ใน ssh-agent เหมือน Initialize-SocLab.ps1 ของบทที่ 1
  EN: Copied files are always converted from CRLF to LF before running
  ไฟล์ที่คัดลอกถูกแปลง CRLF เป็น LF ก่อนรันเสมอ

.EXAMPLE
  .\Invoke-SocLabScript.ps1 -Script ..\..\ch02-network-ssh-hostname\guest\set-identity.sh -Files ..\..\lab-hosts.csv
  .\Invoke-SocLabScript.ps1 -Script ..\..\ch02-network-ssh-hostname\guest\ch02-check.sh -Name lab-linux-01
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $Script,
    [string[]] $Name,
    [string[]] $Files = @(),
    [string]   $Arguments = '',
    [string]   $User     = 'aod',
    [string]   $KeyPath  = (Join-Path $env:USERPROFILE '.ssh\id_ed25519'),
    [string]   $HostsCsv = (Join-Path $PSScriptRoot '..\..\lab-hosts.csv')
)
$ErrorActionPreference = 'Stop'

$all = @((Resolve-Path $Script).Path) + @($Files | ForEach-Object { (Resolve-Path $_).Path })
$scriptName = Split-Path $Script -Leaf
$sshOpts = @('-o', 'StrictHostKeyChecking=accept-new', '-o', 'ConnectTimeout=10', '-o', 'BatchMode=yes')
if (Test-Path $KeyPath) { $sshOpts += @('-i', $KeyPath) }

$hosts = Import-Csv $HostsCsv
if ($Name) { $hosts = $hosts | Where-Object { $Name -contains $_.name } }
if (-not $hosts) { throw 'ไม่พบเครื่องตามชื่อที่ระบุใน lab-hosts.csv' }

$results = foreach ($h in $hosts) {
    Write-Host "==> $($h.name) ($($h.ip))" -ForegroundColor Cyan
    $target = "$User@$($h.ip)"
    & ssh @sshOpts $target 'mkdir -p /tmp/soclab' | Out-Host
    if ($LASTEXITCODE -ne 0) { [pscustomobject]@{ Name = $h.name; IP = $h.ip; Result = 'NO-SSH' }; continue }
    & scp @sshOpts $all "${target}:/tmp/soclab/" | Out-Host
    $cmd = "sed -i 's/\r`$//' /tmp/soclab/* && sudo bash /tmp/soclab/$scriptName $Arguments"
    & ssh @sshOpts $target $cmd | Out-Host
    $r = if ($LASTEXITCODE -eq 0) { 'OK' } else { "FAIL($LASTEXITCODE)" }
    [pscustomobject]@{ Name = $h.name; IP = $h.ip; Result = $r }
}
$results | Format-Table -AutoSize
exit @($results | Where-Object Result -ne 'OK').Count
