<#
.SYNOPSIS
    Detect Intel VTune Profiler and PMU compatibility.
.DESCRIPTION
    Searches standard oneAPI paths for vtune.exe. Also checks whether
    the current CPU supports VTune hardware PMU event-based sampling.
    Outputs JSON with vtune_path, pmu_compatible, cpu_info, reason.
.OUTPUTS
    JSON object on stdout:
    {
      "vtune_path": "C:\\...\\vtune.exe",
      "vtune_version": "2025.10",
      "pmu_compatible": true/false,
      "pmu_reason": "...",
      "cpu_name": "Intel Core i7-10875H",
      "cpu_microarchitecture": "Comet Lake"
    }
    On VTune not found, exits code 1 with error JSON.
#>

$searchRoots = @(
    "C:\Program Files (x86)\Intel\oneAPI\vtune",
    "D:\Program Files (x86)\Intel\oneAPI\vtune",
    "C:\Program Files\Intel\oneAPI\vtune",
    "D:\Program Files\Intel\oneAPI\vtune"
)

# ---- 1. Find VTune ----
$bestExe = $null
$bestVersion = [version]"0.0"
$bestVersionStr = ""

foreach ($root in $searchRoots) {
    if (-not (Test-Path $root)) { continue }
    Get-ChildItem $root -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '^\d{4}\.\d+' -and $_.Name -ne "latest" } |
        ForEach-Object {
            $exe = Join-Path $_.FullName "bin64\vtune.exe"
            if (Test-Path $exe) {
                $ver = $null
                if ([version]::TryParse($_.Name, [ref]$ver)) {
                    if ($ver -gt $bestVersion) {
                        $bestVersion = $ver
                        $bestVersionStr = $_.Name
                        $bestExe = $exe
                    }
                }
            }
        }
}

if (-not $bestExe) {
    $searchedJson = ($searchRoots | ForEach-Object { "`"$($_ -replace '\\','\\')`"" }) -join ','
    Write-Output "{`"error`":`"VTune not found`",`"searched`":[$searchedJson]}"
    exit 1
}

# ---- 2. Get CPU info ----
try {
    $cpuInfo = Get-CimInstance Win32_Processor -ErrorAction Stop | Select-Object -First 1
    $cpuName = $cpuInfo.Name -replace '\s+', ' '
} catch {
    Write-Output '{"error":"Cannot query CPU info via WMI","detail":"' + $_.Exception.Message + '"}'
    exit 1
}

# ---- 2b. Check for AMD first (before Skylake-era matching) ----
if ($cpuName -match "AMD|Ryzen|EPYC") {
    $result = [PSCustomObject]@{
        vtune_path            = $bestExe
        vtune_version         = $bestVersionStr
        pmu_compatible        = $false
        pmu_reason            = "AMD CPUs are not supported for VTune hardware PMU events. Software sampling works."
        cpu_name              = $cpuName
        cpu_microarchitecture = "AMD"
    }
    $result | ConvertTo-Json -Compress
    exit 0
}

# ---- 3. Determine microarchitecture ----
# Map CPU model/name to microarchitecture.
# Skylake-era client CPUs (Skylake, Kaby Lake, Coffee Lake, Comet Lake, Whiskey Lake, Amber Lake)
# are NOT supported by VTune 2025+ for HW PMU events because the EDP configs only
# cover Ice Lake and newer client CPUs plus selected server CPUs.
$skylakeEraCPUs = @(
    "i7-10"      # Comet Lake (i7-10xxxH/U/K/F, NOT i7-1065G7 which is Ice Lake)
    "i5-10"      # Comet Lake i5
    "i3-10"      # Comet Lake i3
    "i9-10"      # Comet Lake i9
    "i7-9"       # Coffee Lake Refresh
    "i5-9"
    "i9-9"
    "i7-8"       # Kaby Lake Refresh / Coffee Lake
    "i5-8"
    "i7-7"       # Kaby Lake
    "i5-7"
    "i7-6"       # Skylake
    "i5-6"
)
# Ice Lake 10th gen has G- suffix: i7-1065G7, i5-1035G7, i7-1068NG7, etc.
# Comet Lake 10th gen has H/U/K/F/suffix: i7-10875H, i7-10750H, i5-10210U, i7-10700K, etc.
# Distinguish: if model contains "G" followed by digit anywhere (e.g., 1065G7, 1068NG7), it's Ice Lake.

$cpuMicroarch = "Unknown"
$pmuCompatible = $true
$pmuReason = ""

# First check: is this a known Skylake-era CPU?
$isSkylakeEra = $false
foreach ($pattern in $skylakeEraCPUs) {
    if ($cpuName -match $pattern) {
        $isSkylakeEra = $true
        break
    }
}

if ($isSkylakeEra) {
    # Check if it's actually Ice Lake (G-suffix pattern: i7-1065G7, i5-1035G7, i7-1068NG7, etc.)
    # Ice Lake: model number contains G followed by a digit anywhere (covers G1, G4, G7, NG7)
    if ($cpuName -match 'i[3579]-\d{2,4}[A-Z]*G\d') {
        $cpuMicroarch = "Ice Lake (10nm client)"
        $pmuCompatible = $true
    } else {
        # It's Comet Lake or older Skylake derivative
        if ($cpuName -match 'i[3579]-10\d{2,3}[HUKF]') {
            $cpuMicroarch = "Comet Lake (14nm, Skylake derivative)"
        } elseif ($cpuName -match 'i[3579]-10\d{2,3}') {
            # Desktop Comet Lake without suffix (e.g., i7-10700, i5-10400)
            $cpuMicroarch = "Comet Lake (14nm, Skylake derivative)"
        } elseif ($cpuName -match 'i[3579]-9\d{2,3}') {
            $cpuMicroarch = "Coffee Lake Refresh (14nm, Skylake derivative)"
        } elseif ($cpuName -match 'i[3579]-8\d{2,3}') {
            $cpuMicroarch = "Coffee Lake / Kaby Lake Refresh (14nm, Skylake derivative)"
        } elseif ($cpuName -match 'i[3579]-7\d{2,3}') {
            $cpuMicroarch = "Kaby Lake (14nm, Skylake derivative)"
        } elseif ($cpuName -match 'i[3579]-6\d{2,3}') {
            $cpuMicroarch = "Skylake (14nm)"
        }
        $pmuCompatible = $false
        $pmuReason = "$cpuMicroarch CPUs are not supported by VTune $bestVersionStr for hardware PMU events. The VTune CPU database only covers Ice Lake (10nm) and newer client CPUs. Software sampling (SW mode) works fully."
    }
}

# If still Unknown and not Skylake-era, assume compatible
if ($cpuMicroarch -eq "Unknown" -and -not $isSkylakeEra) {
    $cpuMicroarch = "Modern Intel (Ice Lake or newer)"
    $pmuCompatible = $true
}

# ---- 4. Output result as JSON ----
$result = [PSCustomObject]@{
    vtune_path            = $bestExe
    vtune_version         = $bestVersionStr
    pmu_compatible        = $pmuCompatible
    pmu_reason            = $pmuReason
    cpu_name              = $cpuName
    cpu_microarchitecture = $cpuMicroarch
}

$result | ConvertTo-Json -Compress
