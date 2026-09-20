# madness

An attempt at a deep, credible execution stack where every layer does
semantically non-trivial work.

```text
Go source
  │ go2rust
Rust source
  │ rustc frontend
Rust MIR
  │ rustc_codegen_jvm
OOMIR
  │
JVM bytecode
  │ Doppio (a JVM written in TypeScript)
JavaScript
  │ GraalJS / Truffle, forced into JVM mode
JVM bytecode
  │ GraalVM HotSpot
x86-64
```

The fun part is the middle: JVM bytecode is interpreted by a JVM written in
JavaScript; that JavaScript is executed by GraalJS, written in Java and running
on another JVM.

## Status

| Leg | State |
|---|---|
| Go → Rust with `go2rust` | ✅ |
| Rust → MIR → OOMIR → Java 8 bytecode | ✅ |
| generated jar on host HotSpot | ✅ |
| generated jar inside Doppio on ordinary Node.js | ✅ |
| Doppio on GraalJS in JVM mode | ✅ `hello from hell` |

## Reproduce

Prerequisites: Go, Rust/rustup, JDK, and Docker.

```bash
./scripts/stage0.sh         # build Go → Rust → JVM jar and run it on HotSpot
./scripts/stage1-doppio.sh  # run that jar through Doppio → GraalJS → HotSpot
```

The stage-1 script explicitly invokes `node --jvm`. This matters: GraalVM's
Node launcher can otherwise use a Native Image, which would remove the outer
JVM layer. The script proves the active runtime through Java interop before
starting Doppio.

See [docs/pipeline.md](docs/pipeline.md) for diagrams,
[docs/stage0-results.md](docs/stage0-results.md) for artifact measurements, and
[docs/stage1-results.md](docs/stage1-results.md) for the verified nested run.

## Layout

```text
stage0-hello/   Go payload
stage1-jvm/     pinned Doppio + GraalVM container recipe
scripts/        reproducible drivers
vendor/         cloned upstream sources (gitignored)
out/            generated artifacts (gitignored)
docs/           design and measurements
```
