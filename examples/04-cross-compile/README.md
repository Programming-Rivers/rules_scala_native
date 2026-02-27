# Cross-Compilation

This section demonstrates how to build Scala Native applications for different architectures and operating systems using Bazel's platform-based toolchain resolution.

## Examples

- **[01-cross-compile-hello-world](01-cross-compile-hello-world)**: Basic cross-compilation of a "Hello World" application to various platforms (Linux, macOS, Windows).
- **[02-cross-compile-with-musl](02-cross-compile-with-musl)**: Targeting Linux with the `musl` C library instead of the default `glibc`.
- **[03-cross-compile-with-glibc](03-cross-compile-with-glibc)**: Targeting specific versions of `glibc` for maximum Linux distribution compatibility.
