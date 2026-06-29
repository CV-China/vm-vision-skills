# perfview_find_fallback.ps1
# Pure ASCII fallback when perfview_detect.ps1 fails (encoding issues).
# Searches common paths and uses dir /s for broader search.
param(
    [string]$ToolName = "PerfView.exe"
)

$results = @()

# Priority 1: PATH
$pathExts = @('.exe', '.bat', '.cmd')
foreach ($dir in $env:PATH -split ';') {
    $candidate = Join-Path $dir $ToolName
    if (Test-Path $candidate -PathType Leaf) {
        $results += [PSCustomObject]@{ Path = $candidate; Method = "PATH" }
        Write-Output "PATH: $candidate"
    }
}

# Priority 2: Common install locations
$commonRoots = @(
    'C:\PerfView', 'D:\PerfView', 'E:\PerfView', 'F:\PerfView',
    'C:\Program Files', 'C:\Program Files (x86)',
    'D:\Program Files', 'E:\Program Files'
)
foreach ($root in $commonRoots) {
    $candidate = Join-Path $root $ToolName
    if (Test-Path $candidate -PathType Leaf) {
        $results += [PSCustomObject]@{ Path = $candidate; Method = "CommonPath" }
        Write-Output "CommonPath: $candidate"
    }
}

# Priority 3: Desktop and Downloads
$userDirs = @(
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\Downloads"
)
foreach ($dir in $userDirs) {
    $found = Get-ChildItem -Path $dir -Filter $ToolName -Recurse -Depth 2 -ErrorAction SilentlyContinue
    foreach ($f in $found) {
        $results += [PSCustomObject]@{ Path = $f.FullName; Method = "UserDir" }
        Write-Output "UserDir: $($f.FullName)"
    }
}

# Priority 4: Search all drive roots (depth 3)
$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -gt 0 }
foreach ($drive in $drives) {
    $root = "$($drive.Root)"
    $found = Get-ChildItem -Path $root -Filter $ToolName -Recurse -Depth 3 -ErrorAction SilentlyContinue |
        Select-Object -First 5
    foreach ($f in $found) {
        $results += [PSCustomObject]@{ Path = $f.FullName; Method = "DriveRoot" }
        Write-Output "DriveRoot: $($f.FullName)"
    }
}

if ($results.Count -eq 0) {
    Write-Warning "NOT_FOUND: $ToolName not found in any search location"
    exit 1
}

# Return first result as the recommended path
$best = $results | Select-Object -First 1
Write-Output ""
Write-Output "RECOMMENDED: $($best.Path) (found via $($best.Method))"
