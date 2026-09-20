#!/usr/bin/env bash
# Stage 0: Go -> Rust -> MIR -> OOMIR -> JVM bytecode -> HotSpot -> x86-64
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/out"
CRATE="$OUT/stage0-crate"

say() { printf '\n\033[1m== %s\033[0m\n' "$*"; }

say "1/4  build go2rust"
[ -d "$ROOT/vendor/go2rust" ] || git clone --depth 1 \
  https://github.com/tylerlaprade/go2rust.git "$ROOT/vendor/go2rust"
(cd "$ROOT/vendor/go2rust" && go build -o "$OUT/go2rust" ./go)

say "2/4  Go -> Rust"
# go2rust writes <name>.rs next to the input
"$OUT/go2rust" "$ROOT/stage0-hello/go/hello.go"
mkdir -p "$CRATE/src"
cp "$ROOT/stage0-hello/go/hello.rs" "$CRATE/src/main.rs"
cat > "$CRATE/Cargo.toml" <<'TOML'
[package]
name = "hello_from_hell"
version = "0.1.0"
edition = "2021"
TOML
cat "$CRATE/src/main.rs"

say "3/4  native sanity check (not part of the tower)"
(cd "$CRATE" && cargo run --quiet)

say "4/4  Rust -> JVM bytecode -> HotSpot"
(cd "$CRATE" && cargo jvm run)
