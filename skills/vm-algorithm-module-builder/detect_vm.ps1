# VM detection script for vm-algorithm-module-builder
# Called via: powershell -NoProfile -ExecutionPolicy Bypass -File detect_vm.ps1
# Output format:
#   FOUND:<assemblyPath>        (VM found, registry value)
#   VM_ROOT:<rootPath>          (VM root directory)
#   VM_MAJOR_MINOR:<X.Y>        (major.minor version)
#   VM_FULL:<dirName>           (full VM directory name)
#   NOT_FOUND                   (VM not installed)

$keyPath = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319\AssemblyFoldersEx\VisionMaster"

try {
    $key = Get-Item -Path $keyPath -ErrorAction Stop
    $vmAssemblyPath = $key.GetValue("")
} catch {
    $vmAssemblyPath = $null
}

if (-not $vmAssemblyPath) {
    Write-Output "NOT_FOUND"
    exit 0
}

Write-Output "FOUND:$vmAssemblyPath"

# Extract VM root by walking up from the registry path
$path = $vmAssemblyPath
while ($path -and (Split-Path $path -Leaf) -notmatch "^VisionMaster") {
    $path = Split-Path $path -Parent
}

$vmDirName = if ($path) { Split-Path $path -Leaf } else { "" }

if ($vmDirName -match "VisionMaster(\d+)\.(\d+)") {
    $vmMajorMinor = "$($Matches[1]).$($Matches[2])"
    $vmFullVersion = $vmDirName
} else {
    $vmMajorMinor = "<unknown>"
    $vmFullVersion = $vmDirName
}

Write-Output "VM_ROOT:$path"
Write-Output "VM_MAJOR_MINOR:$vmMajorMinor"
Write-Output "VM_FULL:$vmFullVersion"
