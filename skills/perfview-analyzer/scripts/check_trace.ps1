<#
.SYNOPSIS
    Check if a PerfView trace is running and inspect ETL file sizes.
.DESCRIPTION
    Checks for running PerfView processes, verifies ETL file sizes at the
    given base path, and lists active PerfView ETW sessions via logman.
.PARAMETER BasePath
    Base path to the trace files (without .etl extension).
.EXAMPLE
    .\check_trace.ps1 -BasePath "C:\Traces\MyApp_Mem_20260624_120000"
#>

param(
    [Parameter(Mandatory)]
    [string]$BasePath
)

$ErrorActionPreference = "Continue"

# Check if PerfView process is running
$perfviewProcs = Get-Process PerfView -ErrorAction SilentlyContinue
if ($perfviewProcs) {
    Write-Host "PerfView processes running:"
    $perfviewProcs | Select-Object Id, ProcessName, StartTime | Format-List
} else {
    Write-Host "No PerfView process running (trace may have stopped or auto-completed)"
}

# Check for ETL files at the specified base path
$etlFile = "$BasePath.etl"
$kernelFile = "$BasePath.kernel.etl"

if (Test-Path $etlFile) {
    $f = Get-Item $etlFile
    Write-Host "ETL (user): $([math]::Round($f.Length/1KB,1)) KB"
} else {
    Write-Host "ETL (user): not found at $etlFile"
}
if (Test-Path $kernelFile) {
    $f = Get-Item $kernelFile
    Write-Host "ETL (kernel): $([math]::Round($f.Length/1KB,1)) KB"
}

# Check for running ETW sessions
Write-Host ""
Write-Host "ETW trace sessions:"
& logman query -ets 2>&1 | Select-String "PerfView"
