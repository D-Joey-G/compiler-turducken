#!/usr/bin/env bash
# Stage 1: JVM bytecode -> Doppio (TypeScript/JavaScript JVM) -> GraalJS ->
# Truffle -> JVM bytecode -> GraalVM HotSpot -> x86-64.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="madness/doppio-graalvm:latest"
JAR="$ROOT/out/stage0-crate/target/jvm-unknown-jvm/debug/hello_from_hell.jar"

say() { printf '\n\033[1m== %s\033[0m\n' "$*"; }

docker info >/dev/null 2>&1 || { echo "Docker daemon is not running."; exit 1; }

if [ ! -f "$JAR" ]; then
  echo "Missing stage-0 jar; building it first."
  "$ROOT/scripts/stage0.sh"
fi

say "1/3  build Doppio on GraalVM Node.js"
docker build --platform linux/amd64 -f "$ROOT/stage1-jvm/Dockerfile" -t "$IMAGE" "$ROOT"

say "2/3  prove Node is running on the JVM, not as a Native Image"
docker run --rm --platform linux/amd64 --entrypoint node "$IMAGE" \
  --jvm --polyglot -e '
    const System = Java.type("java.lang.System");
    console.log("java.vm.name   = " + System.getProperty("java.vm.name"));
    console.log("java.vm.vendor = " + System.getProperty("java.vm.vendor"));
    console.log("os.arch        = " + System.getProperty("os.arch"));
  '

say "3/3  run the Go-derived jar inside Doppio"
docker run --rm --platform linux/amd64 "$IMAGE"
