# GraalVM 23.0.2 is the last published GraalVM Node.js Community line.
# --jvm at runtime is essential: without it, the launcher may use Native Image
# and the outer JVM layer would not exist.
FROM ghcr.io/graalvm/nodejs-community:23.0.2-jvm17

WORKDIR /opt/madness
COPY stage1-jvm/package.json stage1-jvm/package-lock.json ./
RUN npm ci --no-audit --no-fund

COPY stage1-jvm/run-doppio.js ./run-doppio.js
COPY out/stage0-crate/target/jvm-unknown-jvm/debug/hello_from_hell.jar /payload.jar

ENTRYPOINT ["node", "--no-warnings", "--jvm", "--polyglot", "/opt/madness/run-doppio.js"]
CMD ["-jar", "/payload.jar"]
