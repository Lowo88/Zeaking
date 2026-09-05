# Start Nozy Sync Engine (Windows)
# Drop-in CompactTxStreamer for Nozy / Zeaking (`LIGHTWALLETD_GRPC`).
#
# Usage:
#   .\scripts\start-nozy-sync-engine.ps1
#   .\scripts\start-nozy-sync-engine.ps1 -Bind 127.0.0.1:9067 -RpcUrl http://127.0.0.1:8232
#   .\scripts\start-nozy-sync-engine.ps1 -Release

param(
    [string]$RpcUrl = $(if ($env:ZEBRA_RPC_URL) { $env:ZEBRA_RPC_URL } else { "http://127.0.0.1:8232" }),
    [string]$Bind = $(if ($env:NOZY_SYNC_ENGINE_BIND) { $env:NOZY_SYNC_ENGINE_BIND } else { "127.0.0.1:9067" }),
    [string]$DbPath = $(if ($env:NOZY_SYNC_ENGINE_DB) { $env:NOZY_SYNC_ENGINE_DB } else { "nozy_sync_engine_compact.sqlite" }),
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

Write-Host "Nozy Sync Engine"
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
