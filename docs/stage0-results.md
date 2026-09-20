# Stage 0 results — measured 2026-09-20

`./scripts/stage0.sh` runs green end to end on darwin/x86_64.

```
Go source
  │ go2rust                         tylerlaprade/go2rust @ main
Rust source
  │ rustc nightly-2026-09-20        borrowck, monomorphisation
Rust MIR
  │ rustc_codegen_jvm
OOMIR
  │
JVM bytecode                        major version 52 (Java 8)
  │ HotSpot (Temurin 25) + C2
x86-64
```

Output: `hello from hell`.

## The artifact

| | |
|---|---|
| jar | `out/stage0-crate/target/jvm-unknown-jvm/debug/hello_from_hell.jar` |
| size | 14 MB |
| classes | 9,439 |
| class file version | 52 (Java 8) |
| entry point | `hello_from_hell.hello_from_hell` |
| runs standalone | `java -jar <jar>` ✅ |

Rust's `core`/`alloc` are compiled into the jar as ordinary JVM classes —
`org/rustlang/alloc/vec.class` alone is 156 KB. Cold build of the stdlib
overlay took ~36s; the jar is self-contained afterwards.

## The number that matters

**The entire 9,439-class jar statically references only 29 JCL classes.**

```
java/lang:     AssertionError Boolean Class ClassValue Double Float
               IllegalArgumentException Long Object Runnable RuntimeException
               String Thread Thread$UncaughtExceptionHandler ThreadLocal Throwable
java/lang/ref: ReferenceQueue WeakReference
java/lang/reflect: Field InvocationHandler Method
java/util:     IdentityHashMap concurrent/ConcurrentHashMap
java/math:     BigInteger
java/net:      InetAddress InetSocketAddress
java/nio:      charset/Charset charset/StandardCharsets
java/io:       IOException
```

The entry class itself touches exactly two: `java/lang/Object` and
`java/lang/String`. Several of the 29 are reachable only through runtime
features hello world never uses (the `java/net` pair, the reflection trio).

This is the empirical confirmation of the leverage hypothesis in
[feasibility.md](feasibility.md): **the innermost JVM does not need to be a
real JVM.** It needs Java 8 class file parsing, the full bytecode interpreter,
and roughly a dozen `java.lang` classes. That is toy-JVM territory — and it is
why this tower can go deeper than one where the payload is ordinary Java.

That small dependency surface is also why the old Java 8-era Doppio runtime can
execute the payload successfully.
