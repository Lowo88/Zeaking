# Zeaking - Nozy sync engine

Zeaking is NozyWallet’s **compact-block indexer**. Operators run it next to **Zebrad** or **Zakura**. It ingests JSON-RPC, keeps a local compact SQLite cache, and serves the lightwalletd **CompactTxStreamer** API so Nozy can sync shielded chain data on `:9067`.

This repository is that operator process. [NozyWallet](https://github.com/LEONINE-DAO/Nozy-wallet) is the wallet. Point the wallet at Zeaking with `LIGHTWALLETD_GRPC` — the wallet does not embed this binary.

**GitHub:** https://github.com/Lowo88/Zeaking  
**Wallet tracking:** [LEONINE-DAO/Nozy-wallet#274](https://github.com/LEONINE-DAO/Nozy-wallet/issues/274)

```text
Zebrad / Zakura  --JSON-RPC :8232-->  Zeaking (this repo)  --gRPC :9067-->  NozyWallet
