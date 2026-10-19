#Requires -RunAsAdministrator
<#
.SYNOPSIS
  EN: Chapter 2 step 8: let Windows know the lab machine names (hosts file) and SSH to them by short name (~/.ssh/config)
  บทที่ 2 ขั้นที่ 8: ให้ Windows รู้จักชื่อเครื่องใน lab (hosts file) และ SSH ด้วยชื่อสั้นได้ (~/.ssh/config)

.DESCRIPTION
  เขียนบล็อก "# SOCLAB-BEGIN ... # SOCLAB-END" ลงไฟล์ทั้งสอง รันซ้ำได้ บล็อกเดิมจะถูกแทนที่ (EN: writes the SOCLAB-BEGIN/SOCLAB-END block into both files; safe to rerun, the old block is replaced)
  EN: -Remove deletes the block from both files
  -Remove ลบบล็อกออกจากทั้งสองไฟล์

.EXAMPLE
  .\Set-SocLabHosts.ps1
  .\Set-SocLabHosts.ps1 -Remove
#>
[CmdletBinding()]
param(
    [string] $HostsCsv = (Join-Path $PSScriptRoot '..\..\lab-hosts.csv'),
    [string] $Domain   = 'lab.internal',
    [string] $User     = 'aod',
    [switch] $Remove
)
$ErrorActionPreference = 'Stop'

function Set-Block([string]$Path, [string[]]$Lines, [System.Text.Encoding]$Enc) {
    $old = if (Test-Path $Path) { [IO.File]::ReadAllLines($Path) } else { @() }
    $keep = @(); $skip = $false
    foreach ($l in $old) {
        if ($l -eq '# SOCLAB-BEGIN') { $skip = $true; continue }
        if ($l -eq '# SOCLAB-END')   { $skip = $false; continue }
        if (-not $skip) { $keep += $l }
    }
    while ($keep.Count -gt 0 -and $keep[-1] -eq '') { $keep = $keep[0..($keep.Count - 2)] }
    $new = $keep
    if ($Lines) { $new += @('', '# SOCLAB-BEGIN') + $Lines + @('# SOCLAB-END') }
    [IO.File]::WriteAllLines($Path, [string[]]$new, $Enc)
}

$rows = Import-Csv $HostsCsv
$hostsFile = Join-Path $env:SystemRoot 'System32\drivers\etc\hosts'
$sshDir = Join-Path $env:USERPROFILE '.ssh'
$sshCfg = Join-Path $sshDir 'config'

if ($Remove) {
    Set-Block $hostsFile @() ([Text.Encoding]::ASCII)
    if (Test-Path $sshCfg) { Set-Block $sshCfg @() (New-Object Text.UTF8Encoding $false) }
    Write-Host 'ลบบล็อก SOCLAB ออกแล้ว'; return
}

$hostLines = @(("{0,-15} pve-01.{1} pve-01" -f '192.168.10.1', $Domain))
$hostLines += $rows | ForEach-Object { "{0,-15} {1}.{2} {1}" -f $_.ip, $_.name, $Domain }
Set-Block $hostsFile $hostLines ([Text.Encoding]::ASCII)

$names = ($rows | ForEach-Object { $_.name }) -join ' '
# EN: ssh uses the first match, so pve-01 (root) must come before the *.lab.internal pattern
# ssh ใช้ค่าแรกที่ตรง จึงต้องวาง pve-01 (root) ก่อน pattern *.lab.internal
$sshLines = @(
    "Host pve-01 pve-01.$Domain",
    "    User root",
    "Host $names *.$Domain",
    "    User $User",
    "    IdentityFile ~/.ssh/id_ed25519",
    "    IdentitiesOnly yes"
)
if (-not (Test-Path $sshDir)) { New-Item -ItemType Directory $sshDir | Out-Null }
Set-Block $sshCfg $sshLines (New-Object Text.UTF8Encoding $false)

ipconfig /flushdns | Out-Null
Write-Host "เขียนแล้ว: $hostsFile และ $sshCfg"
Resolve-DnsName "ipa-01.$Domain" -Type A -ErrorAction SilentlyContinue | Select-Object Name, IPAddress | Format-Table -AutoSize
