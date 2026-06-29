param(
    [Parameter(Mandatory)]
    [int]$TargetPid
)

$target = Get-Process -Id $TargetPid -ErrorAction SilentlyContinue
if (-not $target) { Write-Host "Process not found"; exit 1 }

Write-Host "Process: $($target.ProcessName) (PID: $TargetPid)"
Write-Host "WorkingSet: $([math]::Round($target.WorkingSet64/1MB,1)) MB"
Write-Host "StartTime: $($target.StartTime)"
Write-Host ""

$clrModules = $target.Modules | Where-Object { $_.ModuleName -like '*clr*' -or $_.ModuleName -like '*coreclr*' }
if ($clrModules) {
    Write-Host ".NET process confirmed - CLR modules found:"
    $clrModules | ForEach-Object { Write-Host "  $($_.ModuleName) ($($_.FileVersionInfo.ProductVersion))" }
} else {
    Write-Host "WARNING: No CLR modules detected. This may not be a .NET process."
    Write-Host "All loaded modules (first 30):"
    $target.Modules | Select-Object -First 30 | ForEach-Object { Write-Host "  $($_.ModuleName)" }
}
