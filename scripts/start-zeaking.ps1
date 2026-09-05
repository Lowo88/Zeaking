# Start the Zeaking indexer (Windows).
# Usage:
#   .\scripts\start-zeaking.ps1
#   .\scripts\start-zeaking.ps1 -Bind 127.0.0.1:9067 -RpcUrl http://127.0.0.1:8232
#   .\scripts\start-zeaking.ps1 -Release

param(
    [string]$RpcUrl = $(if ($env:ZEBRA_RPC_URL) { $env:ZEBRA_RPC_URL } else { "http://127.0.0.1:8232" }),
    [string]$Bind = $(if ($env:ZEAKING_BIND) { $env:ZEAKING_BIND } else { "127.0.0.1:9067" }),
    [string]$DbPath = $(if ($env:ZEAKING_DB) { $env:ZEAKING_DB } else { "zeaking_compact.sqlite" }),
    [switch]$Release
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

$env:ZEBRA_RPC_URL = $RpcUrl
if ($Bind -notmatch '^https?://') {
    $env:LIGHTWALLETD_GRPC = "http://$Bind"
} else {
    $env:LIGHTWALLETD_GRPC = $Bind
}

Write-Host "Zeaking"
Write-Host "  RPC:  $RpcUrl"
Write-Host "  Bind: $Bind  (set LIGHTWALLETD_GRPC=$($env:LIGHTWALLETD_GRPC))"
Write-Host "  DB:   $DbPath"

$cargoArgs = @("run")
if ($Release) { $cargoArgs += "--release" }
$cargoArgs += @(
    "--",
    "--rpc-url", $RpcUrl,
    "--bind", $Bind,
    "--db-path", $DbPath
)

& cargo @cargoArgs
