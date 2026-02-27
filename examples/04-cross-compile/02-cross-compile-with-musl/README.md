# Cross-compiling with musl libc

> **Prerequisites:** Familiarity with Scala and [basic cross-compilation](../01-cross-compile-hello-world/)

## Goal

Compile a Scala Native binary for Linux using the `musl` C library instead of the default `glibc`.

## Description

By default, Linux binaries are often linked against `glibc`.
```bash
$ bazel build //:main --platforms=@llvm//platforms:linux_x86_64
$ ldd bazel-bin/main
        linux-vdso.so.1 (0x00007cab7550b000)
        libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007cab753f6000)
        libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007cab753f1000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007cab75308000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007cab75000000)
        /lib64/ld-linux-x86-64.so.2 (0x00007cab7550d000)
```

However, for creating small, static, or portable binaries
(e.g., for Alpine Linux or containerized environments, or embedded systems), `musl` is a popular alternative.

In this example, we demonstrate how to use `llvm` to target `musl` using the `--platforms` flag.

## Build & Run

To cross-compile the binary for a musl-based Linux system, use the corresponding platform:

```bash
$ cd examples/04-cross-compile/02-cross-compile-with-musl
$ bazel build //... --platforms @llvm//platforms:linux_aarch64_musl
```

Available musl platforms in `llvm`:
* `@llvm//platforms:linux_aarch64_musl`
* `@llvm//platforms:linux_x86_64_musl`

## Inspect the Build Output

```bash
$ bazel build //:main --platforms=@llvm//platforms:linux_x86_64_musl
```
Use the `lld` command on Linux to see the libraries linked to the output binary:
```bash
$ ldd bazel-bin/main
        statically linked
```
The output binary is statically linked, meaning it does not depend on any external C libraries.

## Key Concepts

- **musl libc**: A lightweight, fast, and simple C library implementation.
- **`ldd` command**: The `ldd` command prints shared object dependencies of a binary
  (not to be confused with related commands such as `ld` or `lld`)

## Code Highlights

### MODULE.bazel (partial)

The configuration is identical to the standard cross-compilation example, as the toolchain already includes musl support.

```python
bazel_dep(name = "llvm", version = "0.6.1")
```

### Build Command

The magic happens at the command line by selecting the musl-specific platform:

```bash
bazel build //... --platforms @llvm//platforms:linux_aarch64_musl
```
