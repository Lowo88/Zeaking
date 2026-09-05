# Zeaking

Zeaking is NozyWallet’s **compact-block indexer**. Operators run it next to **Zebrad** or **Zakura**. It ingests JSON-RPC, keeps a local compact SQLite cache, and serves the lightwalletd **CompactTxStreamer** API so Nozy can sync shielded chain data on `:9067`.

This repository is that operator process. [NozyWallet](https://github.com/LEONINE-DAO/Nozy-wallet) is the wallet. Point the wallet at Zeaking with `LIGHTWALLETD_GRPC` — the wallet does not embed this binary.

**GitHub:** https://github.com/Lowo88/Zeaking  
**Wallet tracking:** [LEONINE-DAO/Nozy-wallet#274](https://github.com/LEONINE-DAO/Nozy-wallet/issues/274)

```text
Zebrad / Zakura  --JSON-RPC :8232-->  Zeaking (this repo)  --gRPC :9067-->  NozyWallet
```

## What’s in this repo

| Path | What it actually is |
|------|---------------------|
| `src/main.rs` | Process entry: start ingest loop + gRPC listen |
| `src/lib.rs` | Crate root; re-exports config, errors, store |
| `src/config.rs` | CLI flags and `ZEAKING_*` / `ZEBRA_RPC_URL` env |
| `src/rpc.rs` | JSON-RPC client to Zebrad/Zakura (cookie / basic auth) |
| `src/ingest.rs` | Tip-follow: pull blocks, compact them, write SQLite |
| `src/compact.rs` | Raw block bytes → shielded `CompactBlock` protobuf |
| `src/store.rs` | SQLite compact-block cache |
| `src/serve.rs` | CompactTxStreamer gRPC service |
| `src/treestate.rs` | Map `z_gettreestate` / subtree RPC JSON → LWD protos |
| `src/tree_sizes.rs` | Sapling / Orchard / Ironwood `ChainMetadata` sizes |
| `src/parity.rs` | Compare our compact blocks to a reference streamer |
| `src/error.rs` | Recoverable error types |
| `build.rs` | Compile `proto/*.proto` at build time |
| `proto/service.proto` | CompactTxStreamer RPC definitions |
| `proto/compact_formats.proto` | CompactBlock / CompactTx message types |
| `examples/live_smoke_probe.rs` | Hit a running Zeaking: info, tip, treestate |
| `examples/lwd_parity_probe.rs` | Compare encode/serve vs a reference LWD |
| `scripts/start-zeaking.ps1` | Windows launcher |
| `Cargo.toml` | Package `zeaking`, binary `zeaking` |

## Build

Needs `protoc` on `PATH`. Binary is `zeaking`.

```bash
cargo build --release
```

## Run

```bash
set ZEBRA_RPC_URL=http://127.0.0.1:8232
cargo run --release -- --bind 127.0.0.1:9067 --db-path zeaking_compact.sqlite
```

Windows: `.\scripts\start-zeaking.ps1`

Point Nozy at this process:

```bash
set LIGHTWALLETD_GRPC=http://127.0.0.1:9067
```

### Flags / env

| Flag / env | Default | Meaning |
|------------|---------|---------|
| `--rpc-url` / `ZEBRA_RPC_URL` | `http://127.0.0.1:8232` | Node JSON-RPC |
| `--indexer-rpc-url` / `ZEAKING_RPC_URL` | (unset) | Optional RPC URL override |
| `--bind` / `ZEAKING_BIND` | `127.0.0.1:9067` | CompactTxStreamer listen |
| `--db-path` / `ZEAKING_DB` | `zeaking_compact.sqlite` | Compact SQLite |
| `--backfill` / `ZEAKING_BACKFILL` | `500` | On empty DB, start this many blocks below tip |

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
# ZEBRA_RPC_URL + optional ZEAKING_PARITY_ENGINE_GRPC; default reference https://zec.rocks:443
```

## License

MIT
