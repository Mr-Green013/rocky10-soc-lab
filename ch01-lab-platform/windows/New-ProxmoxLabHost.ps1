#Requires -RunAsAdministrator
<#
.SYNOPSIS
  สร้าง VM สำหรับติดตั้ง Proxmox VE บน Hyper-V (nested virtualization) สำหรับ SOC lab

.DESCRIPTION
  - Switch "PVE-Uplink" (Internal + NAT 172.31.255.0/24): ให้ Proxmox ออก internet
      Windows = 172.31.255.1, Proxmox vmbr0 = 172.31.255.2
  - Switch "SOC-Lab" (Internal, ไม่มี NAT): network ของ lab 192.168.10.0/24
      Windows = 192.168.10.100 (admin workstation ตามเอกสาร), Proxmox vmbr1 = 192.168.10.1 (gateway ของ lab)
  - VM Gen 2, static memory, เปิด nested virtualization, ปิด Secure Boot, เปิด MAC spoofing

.EXAMPLE
  .\New-ProxmoxLabHost.ps1 -IsoPath D:\ISO\proxmox-ve_9.2-1.iso -VMPath D:\Hyper-V

  ส่วนหนึ่งของหนังสือ "SOC Lab บน Rocky Linux 10" บทที่ 1
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $IsoPath,
    [string] $VMName      = 'pve-01',
    [string] $VMPath      = 'D:\Hyper-V',
    [int]    $CpuCount    = 20,
    [long]   $MemoryBytes = 56GB,
    [long]   $DiskBytes   = 600GB
)
$ErrorActionPreference = 'Stop'

function Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }

# --- 0. ตรวจความพร้อม -------------------------------------------------------
Step 'ตรวจ Hyper-V และไฟล์ ISO'
if (-not (Test-Path $IsoPath)) { throw "ไม่พบ ISO: $IsoPath" }

$hv = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
if ($hv.State -ne 'Enabled') {
    Write-Warning 'Hyper-V ยังไม่ได้เปิด กำลังเปิดให้ (ต้องเป็น Windows Pro/Enterprise/Education) แล้วต้อง reboot แล้วรัน script นี้อีกครั้ง'
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -All -NoRestart | Out-Null
    return
}

if (Get-VM -Name $VMName -ErrorAction SilentlyContinue) { throw "มี VM ชื่อ $VMName อยู่แล้ว" }

# subnet ของ lab ต้องไม่ชนกับ network ที่มีอยู่แล้ว (LAN บ้าน, VPN, WSL, Docker Desktop)
function ConvertTo-UInt32([string]$ip) {
    $b = ([System.Net.IPAddress]::Parse($ip)).GetAddressBytes(); [Array]::Reverse($b); [BitConverter]::ToUInt32($b, 0)
}
function Test-Overlap([string]$ipA, [int]$lenA, [string]$ipB, [int]$lenB) {
    $len  = [Math]::Min($lenA, $lenB)
    $mask = if ($len -eq 0) { [uint32]0 } else { [uint32]((([uint64]4294967295) -shl (32 - $len)) -band 4294967295) }
    ((ConvertTo-UInt32 $ipA) -band $mask) -eq ((ConvertTo-UInt32 $ipB) -band $mask)
}
$labNets = @(@{ Ip = '172.31.255.0'; Len = 24; Alias = 'vEthernet (PVE-Uplink)' },
             @{ Ip = '192.168.10.0'; Len = 24; Alias = 'vEthernet (SOC-Lab)' })
foreach ($a in Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue) {
    foreach ($n in $labNets) {
        if ($a.InterfaceAlias -ne $n.Alias -and (Test-Overlap $a.IPAddress $a.PrefixLength $n.Ip $n.Len)) {
            throw ("{0}/{1} บน '{2}' ชนกับ subnet ของ lab {3}/{4} ต้องแก้ก่อน (ดูหัวข้อวิธีแก้ปัญหาในบทที่ 1)" -f $a.IPAddress, $a.PrefixLength, $a.InterfaceAlias, $n.Ip, $n.Len)
        }
    }
}

$logical = (Get-CimInstance Win32_Processor | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum
if ($CpuCount -gt $logical) { throw "CpuCount ($CpuCount) มากกว่า logical processors ของเครื่อง ($logical)" }

# --- 1. Uplink switch + NAT -----------------------------------------------------
Step 'สร้าง switch PVE-Uplink และ NAT 172.31.255.0/24'
if (-not (Get-VMSwitch -Name 'PVE-Uplink' -ErrorAction SilentlyContinue)) {
    New-VMSwitch -Name 'PVE-Uplink' -SwitchType Internal | Out-Null
}
$up = Get-NetAdapter -Name 'vEthernet (PVE-Uplink)'
if (-not (Get-NetIPAddress -InterfaceIndex $up.ifIndex -IPAddress 172.31.255.1 -ErrorAction SilentlyContinue)) {
    New-NetIPAddress -InterfaceIndex $up.ifIndex -IPAddress 172.31.255.1 -PrefixLength 24 | Out-Null
}
$otherNat = Get-NetNat -ErrorAction SilentlyContinue | Where-Object Name -ne 'PVE-Uplink-NAT'
if ($otherNat) {
    Write-Warning ("มี NetNat อื่นอยู่แล้ว: {0} บาง Windows build รองรับ NAT ได้ชุดเดียว ถ้าขั้นต่อไป error ให้ลบหรือรวม prefix" -f ($otherNat.Name -join ', '))
}
if (-not (Get-NetNat -Name 'PVE-Uplink-NAT' -ErrorAction SilentlyContinue)) {
    New-NetNat -Name 'PVE-Uplink-NAT' -InternalIPInterfaceAddressPrefix '172.31.255.0/24' | Out-Null
}

# --- 2. Lab switch (L2 ล้วน, Windows เป็น 192.168.10.100) ------------------------
Step 'สร้าง switch SOC-Lab และตั้ง Windows เป็น 192.168.10.100'
if (-not (Get-VMSwitch -Name 'SOC-Lab' -ErrorAction SilentlyContinue)) {
    New-VMSwitch -Name 'SOC-Lab' -SwitchType Internal | Out-Null
}
$lab = Get-NetAdapter -Name 'vEthernet (SOC-Lab)'
if (-not (Get-NetIPAddress -InterfaceIndex $lab.ifIndex -IPAddress 192.168.10.100 -ErrorAction SilentlyContinue)) {
    # ไม่ใส่ default gateway: internet ของ Windows ยังออกทาง NIC จริงเหมือนเดิม
    New-NetIPAddress -InterfaceIndex $lab.ifIndex -IPAddress 192.168.10.100 -PrefixLength 24 | Out-Null
}

# --- 3. VM ---------------------------------------------------------------------
Step "สร้าง VM $VMName ($CpuCount vCPU, $([math]::Round($MemoryBytes/1GB)) GB, disk $([math]::Round($DiskBytes/1GB)) GB)"
$vhd = Join-Path $VMPath "$VMName\$VMName.vhdx"
New-VM -Name $VMName -Generation 2 -Path $VMPath -MemoryStartupBytes $MemoryBytes `
       -NewVHDPath $vhd -NewVHDSizeBytes $DiskBytes -SwitchName 'PVE-Uplink' | Out-Null

# nested virtualization ต้องใช้ static memory
Set-VM -Name $VMName -ProcessorCount $CpuCount -StaticMemory `
       -AutomaticCheckpointsEnabled $false -AutomaticStopAction ShutDown -AutomaticStartAction Nothing
Set-VMProcessor -VMName $VMName -ExposeVirtualizationExtensions $true

# NIC ตัวที่ 2 ต่อ SOC-Lab, MAC spoofing ให้ VM ข้างใน Proxmox ใช้ MAC ของตัวเองได้
Add-VMNetworkAdapter -VMName $VMName -SwitchName 'SOC-Lab' -Name 'soc-lab'
Get-VMNetworkAdapter -VMName $VMName | Set-VMNetworkAdapter -MacAddressSpoofing On

# Proxmox installer บูตได้โดยไม่ต้องตั้ง Secure Boot template
Set-VMFirmware -VMName $VMName -EnableSecureBoot Off
Add-VMDvdDrive -VMName $VMName -Path $IsoPath
Set-VMFirmware -VMName $VMName -FirstBootDevice (Get-VMDvdDrive -VMName $VMName)

# Defender ไม่ต้องสแกน VHDX ทุกครั้งที่ VM เขียน disk
Add-MpPreference -ExclusionPath (Join-Path $VMPath $VMName) -ErrorAction SilentlyContinue

# --- 4. สรุป -------------------------------------------------------------------
Step 'เสร็จ: ตรวจค่า'
Get-VMProcessor -VMName $VMName | Select-Object VMName, Count, ExposeVirtualizationExtensions | Format-Table
# จด MAC ไว้: ใช้เลือก NIC ที่ถูกต้องในตัวติดตั้ง Proxmox (PVE-Uplink = management)
Get-VMNetworkAdapter -VMName $VMName | Select-Object Name, SwitchName, MacAddressSpoofing, MacAddress | Format-Table

Write-Host @"
ขั้นต่อไป:
  1. Start-VM $VMName ; vmconnect localhost $VMName
  2. ในตัวติดตั้ง Proxmox เลือก NIC ตัวแรก (PVE-Uplink) เป็น management:
       Hostname  pve-01.lab.internal
       IP        172.31.255.2/24   Gateway 172.31.255.1   DNS 1.1.1.1
  3. หลังติดตั้ง รัน proxmox/pve-repos.sh และ proxmox/pve-setup-network.sh บน pve-01
     แล้วเปิด https://192.168.10.1:8006 จาก Windows
"@
