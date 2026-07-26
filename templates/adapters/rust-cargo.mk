# name: rust-cargo
# desc: Rust + cargo + rustfmt + clippy
# needs: cargo

SETUP     := cargo fetch
DEV       := cargo watch -x run
FMT       := cargo fmt
FMT_CHECK := cargo fmt --check
LINT      := cargo clippy --all-targets -- -D warnings
TYPECHECK := cargo check --all-targets
TEST      := cargo test
BUILD     := cargo build --release
SHIP      :=
