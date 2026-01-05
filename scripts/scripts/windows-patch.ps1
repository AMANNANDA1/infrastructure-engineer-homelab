Write-Host "=== Windows Patch Management ===" -ForegroundColor Green
Get-HotFix | Sort InstalledOn -Descending | Select -First 5
Write-Host "Running services:"
Get-Service | Where-Object Status -eq Running | Select -First 5 Name
