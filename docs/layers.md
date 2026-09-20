# What each layer actually does

A layer earns its place only if it performs semantically non-trivial work.

| # | Layer | Non-trivial work | Proof |
|---|---|---|---|
| 1 | Go source | original program semantics | source |
| 2 | `go2rust` | language translation and ownership invention | generated `.rs` |
| 3 | rustc frontend / MIR | type checking, borrow checking, lowering | backend input |
| 4 | `rustc_codegen_jvm` / OOMIR | imperative Rust model to JVM object model | backend pipeline |
| 5 | payload JVM bytecode | stack-machine program, class-file version 52 | `javap -c` |
| 6 | Doppio | parses and interprets that bytecode as a JVM | payload output |
| 7 | JavaScript | implementation language of Doppio | published TS/JS package |
| 8 | GraalJS / Truffle | executes and specializes the JavaScript | GraalVM Node runtime |
| 9 | outer JVM bytecode | implementation of GraalJS/Truffle | `node --jvm` plus Java interop |
| 10 | GraalVM HotSpot | executes/JIT-compiles the outer Java program | `java.vm.name` proof |
| 11 | x86-64 | host ISA | `os.arch=amd64` |

## Nesting proof

The critical failure mode is accidentally using GraalVM Node's Native Image
launcher. That would give Doppio → JavaScript → native and eliminate the second
JVM. `scripts/stage1-doppio.sh` therefore always passes `--jvm --polyglot` and,
in the same image used for the payload, reads `java.vm.name`, `java.vm.vendor`,
and `os.arch` through `Java.type("java.lang.System")`.

The payload then runs through Doppio and prints `hello from hell`. Together,
those checks establish both halves of the nesting rather than merely showing
that each runtime exists independently.
