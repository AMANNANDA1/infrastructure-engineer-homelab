@'
# =============================================================
# Windows Patch Management & Health Report
# Author : Aman Nanda
# Purpose: Audit installed patches, services, and system health
# Tested : Windows 11 (Home lab)
# =============================================================

$LogPath = "$env:USERPROFILE\Documents\patch-report-$(Get-Date -f yyyy-MM-dd).txt"
$Date    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

function Log($msg) {
    $line = "[$Date] $msg"
    Write-Host $line
    Add-Content -Path $LogPath -Value $line
}

Log "===== Windows Patch & Health Report ====="
Log "Hostname : $env:COMPUTERNAME"
Log "User     : $env:USERNAME"

Log "--- Patches Installed (Last 30 Days) ---"
$cutoff = (Get-Date).AddDays(-30)
$patches = Get-HotFix | Where-Object { $_.InstalledOn -gt $cutoff } |
           Select-Object HotFixID, Description, InstalledOn |
           Sort-Object InstalledOn -Descending
$patches | Format-Table -AutoSize
Log "Total patches in last 30 days: $($patches.Count)"

Log "--- Critical Service Status ---"
$services = @("wuauserv","WinDefend","EventLog","Dnscache","W32Time")
foreach ($svc in $services) {
    $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($s) {
        $status = $s.Status
        $flag = if ($status -ne "Running") { " <<< WARNING" } else { "" }
        Log "  $svc : $status$flag"
    }
}

Log "--- Disk Space ---"
Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -gt 0 } | ForEach-Object {
    $usedPct = [math]::Round(($_.Used / ($_.Used + $_.Free)) * 100, 1)
    $flag = if ($usedPct -gt 80) { " <<< WARNING: above 80%" } else { "" }
    Log "  Drive $($_.Name): ${usedPct}% used$flag"
}

Log "--- Windows Defender Status ---"
try {
    $def = Get-MpComputerStatus
    Log "  AntivirusEnabled    : $($def.AntivirusEnabled)"
    Log "  RealTimeProtection  : $($def.RealTimeProtectionEnabled)"
    Log "  SignatureAge (days) : $($def.AntivirusSignatureAge)"
    if ($def.AntivirusSignatureAge -gt 3) { Log "  WARNING: Signatures older than 3 days" }
} catch { Log "  Defender status unavailable" }

Log "===== Report Complete. Saved to: $LogPath ====="
'@ | Out-File "$env:USERPROFILE\Documents\windows-patch.ps1" -Encoding UTF8

.\windows-patch.ps1
