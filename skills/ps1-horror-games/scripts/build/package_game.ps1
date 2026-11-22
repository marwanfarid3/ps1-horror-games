# Portable Windows packager for a Godot 4 game.
# CHANGE FOR YOUR GAME: pass -GameName "My Game" and -GameFileName "MyGame" (no spaces).
# Godot path: pass -GodotPath, or set the GODOT_PATH environment variable.
# Expects, inside the project: an export preset named "Windows Portable", tests\pack_smoke.gd,
# and optionally art\icon.ico. Keep launcher.cs beside this script; the packager fills in its names.
param(
    [Parameter(Mandatory = $true)][string]$GameName,
    [Parameter(Mandatory = $true)][string]$GameFileName,
    [string]$GodotPath = $env:GODOT_PATH,
    [string]$OutputDirectory = '',
    [string]$ExtraLicenseFile = '',
    [switch]$SkipImport,
    [switch]$SkipZip
)

if (-not $GodotPath) { throw 'Set -GodotPath or the GODOT_PATH environment variable to your Godot 4 executable.' }
if (-not $OutputDirectory) { $OutputDirectory = "build\$GameFileName-Windows" }
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
$projectDirectory = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$packageDirectory = [System.IO.Path]::GetFullPath((Join-Path $projectDirectory $OutputDirectory))
$projectPrefix = $projectDirectory.TrimEnd('\') + '\'
if (-not $packageDirectory.StartsWith($projectPrefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'The output directory must stay inside this project.'
}
if (-not (Test-Path -LiteralPath $GodotPath -PathType Leaf)) { throw 'Godot executable was not found.' }
$consoleToolPath = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($GodotPath), [System.IO.Path]::GetFileNameWithoutExtension($GodotPath) + '_console.exe')
if (-not (Test-Path -LiteralPath $consoleToolPath -PathType Leaf)) {
    throw 'Place the matching Godot console wrapper beside the Godot executable for reliable build output.'
}
$compilerPath = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if (-not (Test-Path -LiteralPath $compilerPath -PathType Leaf)) { throw 'The Windows .NET Framework C# compiler was not found.' }

$checkDirectory = Join-Path $projectDirectory '.devcheck\packaging'
$runtimeDirectory = Join-Path $packageDirectory 'runtime'
$licenseDirectory = Join-Path $packageDirectory 'licenses'
New-Item -ItemType Directory -Path $packageDirectory, $runtimeDirectory, $licenseDirectory, $checkDirectory -Force | Out-Null
$userdataDirectory = Join-Path $checkDirectory 'userdata'
New-Item -ItemType Directory -Path $userdataDirectory -Force | Out-Null
$previousAppData = $env:APPDATA
$previousLocalAppData = $env:LOCALAPPDATA

function Invoke-CheckedEngine {
    param([string[]]$EngineArguments, [string]$LogName)
    $transcriptPath = Join-Path $checkDirectory $LogName
    $output = & $consoleToolPath @EngineArguments 2>&1
    $result = $LASTEXITCODE
    $output | Set-Content -LiteralPath $transcriptPath -Encoding UTF8
    if ($result -ne 0) { throw "Godot exited with code $result. See $transcriptPath" }
    if (($output -join "`n") -match 'SCRIPT ERROR:|Parse Error:|ERROR:') {
        throw "Godot reported an error. See $transcriptPath"
    }
}

try {
    # Packaging tests use isolated user data; the player's checkpoint is untouched.
    $env:APPDATA = $userdataDirectory
    $env:LOCALAPPDATA = $userdataDirectory
    if (-not $SkipImport) {
        Invoke-CheckedEngine -EngineArguments @('--headless', '--editor', '--path', $projectDirectory, '--quit') -LogName 'import.log'
    }
    $packPath = Join-Path $packageDirectory "$GameFileName.pck"
    Invoke-CheckedEngine -EngineArguments @('--headless', '--path', $projectDirectory, '--export-pack', 'Windows Portable', $packPath) -LogName 'export.log'

    # Bundle the already installed engine. No template download or Godot install is required to play.
    Copy-Item -LiteralPath $GodotPath -Destination (Join-Path $runtimeDirectory 'engine.exe') -Force
    $launcherPath = Join-Path $packageDirectory "$GameFileName.exe"
    $compilerArguments = @('/nologo', '/target:winexe', '/optimize+', '/platform:x64', '/reference:System.Windows.Forms.dll', "/out:$launcherPath")
    $iconPath = Join-Path $projectDirectory 'art\icon.ico'
    if (Test-Path -LiteralPath $iconPath) { $compilerArguments += "/win32icon:$iconPath" }
    $launcherSource = Join-Path $checkDirectory 'launcher.generated.cs'
    (Get-Content -LiteralPath (Join-Path $PSScriptRoot 'launcher.cs') -Raw).Replace('My Game', $GameName).Replace('MyGame', $GameFileName) | Set-Content -LiteralPath $launcherSource -Encoding UTF8
    $compilerArguments += $launcherSource
    & $compilerPath @compilerArguments
    if ($LASTEXITCODE -ne 0) { throw 'Launcher compilation failed.' }

    $packTestPath = Join-Path $projectDirectory 'tests\pack_smoke.gd'
    Invoke-CheckedEngine -EngineArguments @('--headless', '--path', $packageDirectory, '--main-pack', $packPath, '--script', $packTestPath, '--', '--license-output', $licenseDirectory, '--fresh') -LogName 'pack-test.log'
    if ($ExtraLicenseFile -and (Test-Path -LiteralPath $ExtraLicenseFile)) { Copy-Item -LiteralPath $ExtraLicenseFile -Destination $licenseDirectory -Force }

    @"
$($GameName.ToUpper())

Run $GameFileName.exe. Keep the runtime folder and $GameFileName.pck beside it.
No editor or Godot installation is required. Extract the ZIP before playing.

CONTROLS
(Write your game's controls here, one line each: move, look, interact, pause, fullscreen.)

SAVING
(Say when the game saves and what Continue / New Game do.)

Powered by Godot Engine. Engine and component notices are in licenses/.
Game assets are separate from the engine license.
"@ | Set-Content -LiteralPath (Join-Path $packageDirectory 'READ ME.txt') -Encoding UTF8

    $files = @("$GameFileName.exe", "$GameFileName.pck", 'runtime\engine.exe')
    $manifestFiles = foreach ($relativePath in $files) {
        $fullPath = Join-Path $packageDirectory $relativePath
        [ordered]@{ path = $relativePath; bytes = (Get-Item -LiteralPath $fullPath).Length; sha256 = (Get-FileHash -LiteralPath $fullPath -Algorithm SHA256).Hash }
    }
    [ordered]@{
        name = $GameName
        version = (Select-String -LiteralPath (Join-Path $projectDirectory 'project.godot') -Pattern '^config/version="([^"]+)"').Matches.Groups[1].Value
        builtUtc = [DateTime]::UtcNow.ToString('o')
        engine = (& $consoleToolPath --version | Out-String).Trim()
        validation = 'pack_smoke.gd passed; see project .devcheck/packaging/pack-test.log'
        files = @($manifestFiles)
    } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $packageDirectory 'build-manifest.json') -Encoding UTF8

    if (-not $SkipZip) {
        $archivePath = $packageDirectory.TrimEnd('\') + '.zip'
        Compress-Archive -LiteralPath $packageDirectory -DestinationPath $archivePath -CompressionLevel Optimal -Force
        Write-Output "ZIP: $archivePath"
    }
    Write-Output "READY: $launcherPath"
}
finally {
    $env:APPDATA = $previousAppData
    $env:LOCALAPPDATA = $previousLocalAppData
}
