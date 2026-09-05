//! `zeaking` process: load config, ingest compact blocks, listen for CompactTxStreamer.

use std::sync::Arc;

use clap::Parser;
use tokio::sync::RwLock;
use tracing::info;

use zeaking::config::IndexerConfig;
use zeaking::ingest::{bootstrap, run_ingest_loop};
use zeaking::rpc::RpcClient;
use zeaking::serve::ServeState;
use zeaking::store::IndexerStore;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let cfg = IndexerConfig::parse();
    cfg.validate()?;

    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| tracing_subscriber::EnvFilter::new(&cfg.rust_log)),
        )
        .init();

    let rpc_url = cfg.effective_rpc_url().to_string();
    info!(%rpc_url, bind = %cfg.bind, db = %cfg.db_path.display(), "starting Zeaking");

    let rpc = RpcClient::new(&rpc_url)?;
    let store = Arc::new(IndexerStore::open(&cfg.db_path)?);
    let handle = bootstrap(&rpc, &store, &cfg.network).await?;

    let node = Arc::new(RwLock::new(handle.node.clone()));
    let rpc_serve = Arc::new(RpcClient::new(&rpc_url)?);
    let serve = ServeState {
        store: Arc::clone(&store),
        rpc: rpc_serve,
        node: Arc::clone(&node),
        node_kind: handle.node_kind,
        vendor: "Zeaking".into(),
        version: env!("CARGO_PKG_VERSION").into(),
    };

    let poll_ms = cfg.poll_ms;
    let start_height = cfg.start_height;
    let backfill = cfg.backfill;
    let rpc_ingest = RpcClient::new(&rpc_url)?;
    let store_ingest = Arc::clone(&store);
    tokio::spawn(async move {
        run_ingest_loop(rpc_ingest, store_ingest, poll_ms, start_height, backfill).await;
    });

    let rpc_meta = RpcClient::new(&rpc_url)?;
    let node_meta = Arc::clone(&node);
    tokio::spawn(async move {
        loop {
            if let Ok(info) = rpc_meta.probe_node().await {
                *node_meta.write().await = info;
            }
            tokio::time::sleep(std::time::Duration::from_secs(15)).await;
        }
    });

    info!(
        "CompactTxStreamer listening on {} (point LIGHTWALLETD_GRPC here)",
        cfg.bind
    );
    tonic::transport::Server::builder()
        .add_service(serve.into_service())
        .serve(cfg.bind)
        .await?;

    Ok(())
}
