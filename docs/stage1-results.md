# Stage 1 results: Doppio on GraalVM

Verified 2026-09-20 with:

- `doppiojvm@0.5.0`
- `ghcr.io/graalvm/nodejs-community:23.0.2-jvm17`
- Linux/amd64 Docker on an Intel Mac
- the unmodified stage-0 Java 8 jar

## Result

```text
$ ./scripts/stage1-doppio.sh

== 2/3  prove Node is running on the JVM, not as a Native Image
java.vm.name   = OpenJDK 64-Bit Server VM
java.vm.vendor = GraalVM Community
os.arch        = amd64

== 3/3  run the Go-derived jar inside Doppio
hello from hell
```

This closes the full nesting claim:

```text
payload JVM bytecode
  → Doppio JVM interpreter (TypeScript/JavaScript)
  → GraalJS and Truffle (Java)
  → outer JVM bytecode
  → GraalVM HotSpot
  → x86-64
```

## Compatibility notes

- Doppio's npm package dates from 2016 but installs successfully with the Node
  18 runtime in GraalVM Node.js 23.0.2.
- Doppio and the payload both use Java 8-era class files/libraries.
- Current BrowserFS emits cosmetic deprecation notices because Doppio uses its
  legacy ZipFS API. `run-doppio.js` filters only those known notices.
- `--jvm` is mandatory. Merely running inside a GraalVM-branded Node container
  is insufficient evidence because its launcher also supports Native Image
  mode.
