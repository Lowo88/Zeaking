# Zeaking — Nozy Sync Engine

Operator **indexer** for [NozyWallet](https://github.com/LEONINE-DAO/Nozy-wallet): ingest from **Zebrad** / **Zakura** JSON-RPC and serve lightwalletd **CompactTxStreamer** for the wallet.

This is the same split as **Zaino** to **Zingo**: this repo is the server; the wallet stays in Nozy-wallet. The wallet-side compact client (`zeaking::lwd`) remains in the wallet repo — it **consumes** this gRPC, it is not this binary.

**GitHub:** https://github.com/Lowo88/Zeaking  
**Wallet tracking:** [LEONINE-DAO/Nozy-wallet#274](https://github.com/LEONINE-DAO/Nozy-wallet/issues/274)

```text
Zebrad / Zakura  --JSON-RPC :8232-->  Nozy Sync Engine (this repo)  --gRPC :9067-->  Nozy / zeaking::lwd
```

## Build

Needs `protoc` on `PATH`.

```bash
cargo build --release
```

## Run

```bash
set ZEBRA_RPC_URL=http://127.0.0.1:8232
cargo run --release -- --bind 127.0.0.1:9067 --db-path nozy_sync_engine_compact.sqlite
```

Windows: `.\scripts\start-nozy-sync-engine.ps1`

Point Nozy at this process:

```bash
set LIGHTWALLETD_GRPC=http://127.0.0.1:9067
```

### Flags / env

| Flag / env | Default | Meaning |
|------------|---------|---------|
| `--rpc-url` / `ZEBRA_RPC_URL` | `http://127.0.0.1:8232` | Node JSON-RPC |
| `--bind` / `NOZY_SYNC_ENGINE_BIND` | `127.0.0.1:9067` | CompactTxStreamer listen |
| `--db-path` / `NOZY_SYNC_ENGINE_DB` | `nozy_sync_engine_compact.sqlite` | Compact SQLite |
| `--backfill` / `NOZY_SYNC_ENGINE_BACKFILL` | `500` | On empty DB, start this many blocks below tip |

Auth: `ZEBRA_RPC_*` / `ZAKURA_RPC_*` user/pass, inline cookie, or `~/.cache/{zebra,zakura}/.cookie`.

## RPCs

| RPC | Status |
|-----|--------|
| `GetLightdInfo`, `GetLatestBlock`, `GetBlock`, `GetBlockRange`, `Ping` | Landed |
| `GetTreeState`, `GetLatestTreeState`, `GetSubtreeRoots` | Landed |
| `SendTransaction` | Landed (proxies `sendrawtransaction`) |

**UNIMPLEMENTED:** transparent UTXO/balance streams, mempool streams, `GetTransaction`.

## Smoke

```powershell
$env:LIGHTWALLETD_GRPC = "http://127.0.0.1:9067"
cargo run --example live_smoke_probe
cargo run --example lwd_parity_probe
# ZEBRA_RPC_URL + optional NOZY_PARITY_ENGINE_GRPC; default reference https://zec.rocks:443
```

## License

MIT
