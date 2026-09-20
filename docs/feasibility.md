# Feasibility, leg by leg

Assessed and verified 2026-09-20 on darwin/x86_64.

## `go2rust`: Go → Rust

Verified for the deliberately tiny payload. The generated body is:

```rust
fn main() {
    println!("{}", format!("{}", "hello from hell".to_string()));
}
```

Coverage remains the constraint: this is a small research transpiler, so the
payload should avoid demanding Go features. Its incomplete self-hosting support
also keeps the compiler-provenance variant parked.

## `rustc_codegen_jvm`: Rust → JVM bytecode

Verified. The backend produces a standalone Java 8 jar through Rust MIR and
OOMIR. The hello-world artifact is about 14 MB and contains 9,439 classes,
mostly compiled Rust `core` and `alloc` support. See `stage0-results.md`.

## Doppio: JVM bytecode → JavaScript

Verified, surprisingly without patches. The npm package `doppiojvm@0.5.0`
installs a Java 8 class library and its precompiled command-line runtime. It
loads the generated jar and prints the expected output under both ordinary
Node.js and GraalVM Node.js.

The package is old and produces BrowserFS deprecation warnings, but the Java 8
alignment is ideal: both Doppio and `rustc_codegen_jvm` target class-file major
version 52.

## GraalJS in JVM mode: JavaScript → JVM → native

Verified in the official GraalVM Node.js Community container. The important
constraint is invoking:

```text
node --jvm --polyglot ...
```

Without `--jvm`, the launcher may run as a Native Image, making the claimed
outer JVM disappear. Java interop reports `OpenJDK 64-Bit Server VM` from
`GraalVM Community` before the Doppio payload is run.

There is no current macOS/x86_64 GraalVM Node distribution, so the reproducible
path uses the official Linux/amd64 container. On this Intel Mac that is the
native architecture; Docker virtualizes Linux but does not emulate the CPU.

## Verdict

The selected tower is green end to end:

```text
Go → Rust → MIR → OOMIR → JVM bytecode → Doppio → JavaScript
   → GraalJS/Truffle → JVM bytecode → GraalVM HotSpot → x86-64
```
