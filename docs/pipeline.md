# The pipeline

One hello world, two JVMs, and JavaScript in the middle. Status as of
2026-09-20: **verified end to end**.

## The tower

```mermaid
flowchart TD
    A["<b>Go source</b><br/>fmt.Println: hello from hell"]
    B["<b>Rust source</b>"]
    C["<b>Rust MIR</b><br/><i>borrow checking and lowering</i>"]
    D["<b>OOMIR</b><br/><i>imperative to object model</i>"]
    E["<b>JVM bytecode</b><br/>Java 8 · 14 MB · 9,439 classes"]
    F["<b>Doppio JVM</b><br/><i>TypeScript compiled to JavaScript</i>"]
    G["<b>GraalJS + Truffle</b><br/><i>JavaScript implementation in Java</i>"]
    H["<b>JVM bytecode</b><br/><i>GraalJS and Truffle</i>"]
    I["<b>GraalVM HotSpot</b>"]
    J["<b>x86-64</b>"]

    A -->|go2rust| B
    B -->|rustc frontend| C
    C -->|rustc_codegen_jvm| D
    D --> E
    E -->|interpreted by| F
    F -->|JavaScript execution| G
    G -->|implemented as| H
    H -->|executes on| I
    I -->|JIT| J

    classDef done fill:#17351f,stroke:#49b86e,stroke-width:2px,color:#effff3
    class A,B,C,D,E,F,G,H,I,J done
```

## Why this is genuinely nested

```text
hello_from_hell.jar
  └─ JVM bytecode produced from Rust
      └─ Doppio's JVM interpreter
          └─ JavaScript compiled from TypeScript
              └─ GraalJS language implementation
                  └─ Truffle AST execution and specialization
                      └─ Java classes / JVM bytecode
                          └─ GraalVM HotSpot
                              └─ x86-64
```

The proof is not merely that a GraalVM image contains Java. Stage 1 starts Node
with `--jvm --polyglot`, then accesses `java.lang.System` from JavaScript and
prints:

```text
java.vm.name   = OpenJDK 64-Bit Server VM
java.vm.vendor = GraalVM Community
os.arch        = amd64
```

Only after that check does the same image invoke Doppio and print
`hello from hell` from the Go-derived jar.

## Assembly

```mermaid
flowchart LR
    GO[hello.go] -->|go2rust| RS[main.rs]
    RS -->|cargo jvm| JAR[hello_from_hell.jar]
    JAR --> DOPPIO[Doppio 0.5.0]
    TS[Doppio TypeScript sources] -->|precompiled npm package| DOPPIO
    DOPPIO --> JS[JavaScript]
    JS -->|node --jvm| GRAAL[GraalJS / Truffle]
    GRAAL --> JVM[GraalVM Community JVM]
    JVM --> CPU[x86-64]
```

The container pins Doppio 0.5.0 and GraalVM Node.js Community 23.0.2. Doppio's
installer supplies its Java 8 class library. The generated payload is also Java
8 bytecode (class-file major version 52), which is the compatibility hinge that
makes this old research JVM usable.

## Reproduce

```bash
./scripts/stage0.sh
./scripts/stage1-doppio.sh
```

Stage 1 builds `stage1-jvm/Dockerfile`, proves JVM mode through Java interop,
and runs the payload. The expected final line is:

```text
hello from hell
```

Doppio uses BrowserFS's deprecated-but-supported legacy ZipFS API. The stage-1
wrapper suppresses only those known compatibility notices while preserving all
other warnings and errors.
