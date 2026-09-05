//! Zeaking library: ingest, compact encode, SQLite store, and CompactTxStreamer types.
//!
//! The `zeaking` binary in `src/main.rs` wires these modules into a process.

pub mod compact;
pub mod config;
pub mod error;
pub mod ingest;
pub mod parity;
pub mod rpc;
pub mod serve;
pub mod store;
pub mod tree_sizes;
pub mod treestate;

#[allow(clippy::all)]
pub mod proto {
    tonic::include_proto!("cash.z.wallet.sdk.rpc");
}

pub use config::IndexerConfig;
pub use error::{IndexerError, IndexerResult};
pub use store::IndexerStore;
