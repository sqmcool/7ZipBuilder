﻿param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string] $BuildVersion
)

$workDir = $PSScriptRoot
$tempDir = "$workDir\Temp"
$buildDir = "$workDir\$BuildVersion"

if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir
}

# 下载7zR
if (-not (Test-Path "$tempDir\7zr.exe")) {
    Invoke-WebRequest -Uri "https://www.7-zip.org/a/7zr.exe" -OutFile "$tempDir\7zr.exe"
}

# 下载并解压源码
if (-not (Test-Path $buildDir)) {
    if (-not (Test-Path "$tempDir\$BuildVersion-src.7z")) {
        Invoke-WebRequest -Uri "https://7-zip.org/a/$BuildVersion-src.7z" -OutFile "$tempDir\$BuildVersion-src.7z"
    }
    & "$tempDir\7zr.exe" x "$tempDir\$BuildVersion-src.7z" -o"$buildDir"
}

# 如果子流程存在则调用子流程用于自定义操作源码
$subPrepareScript = "$workDir\SubPrepare.ps1"
if (Test-Path $subPrepareScript) {
    & $subPrepareScript $buildDir $BuildVersion
}
