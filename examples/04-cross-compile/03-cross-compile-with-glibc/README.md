# Cross-compiling with a specific glibc version

> **Prerequisites:** Familiarity with Scala and [basic cross-compilation](../01-cross-compile-hello-world/)

## Goal

Compile a Scala Native binary for Linux while targeting a specific version of the GNU C Library (`glibc`).

## Description

When distributing Linux binaries, targeting an older version of `glibc` is a common strategy to ensure maximum compatibility across different Linux distributions. Newer distributions are usually backward-compatible with older `glibc` versions, but not vice-versa.

In this example, we demonstrate how to use `toolchains_llvm_bootstrapped` to target specific `glibc` versions using the `--platforms` flag.

## Build & Run

To cross-compile the binary targeting a specific `glibc` version (e.g., 2.28), use the corresponding platform:

### For x86_64:
```bash
$ cd examples/04-cross-compile/03-cross-compile-with-glibc
$ bazel build //... --platforms @toolchains_llvm_bootstrapped//platforms:linux_x86_64_gnu.2.28
```

### For aarch64:
```bash
$ cd examples/04-cross-compile/03-cross-compile-with-glibc
$ bazel build //... --platforms @toolchains_llvm_bootstrapped//platforms:linux_aarch64_gnu.2.28 
```

> **Note:** The command should run from the same directory that contains the `MODULE.bazel` file.

## Available glibc Versions

To list all available glibc versions use the following command:
```bash
$ bazel query @toolchains_llvm_bootstrapped//platforms:all  \
     | grep linux_aarch64_gnu
@toolchains_llvm_bootstrapped//platforms:linux_aarch64_gnu.2.28
@toolchains_llvm_bootstrapped//platforms:linux_aarch64_gnu.2.29
@toolchains_llvm_bootstrapped//platforms:linux_aarch64_gnu.2.30
@toolchains_llvm_bootstrapped//platforms:linux_aarch64_gnu.2.31
@toolchains_llvm_bootstrapped//platforms:linux_aarch64_gnu.2.32
@toolchains_llvm_bootstrapped//platforms:linux_aarch64_gnu.2.33
@toolchains_llvm_bootstrapped//platforms:linux_aarch64_gnu.2.34
@toolchains_llvm_bootstrapped//platforms:linux_aarch64_gnu.2.35
@toolchains_llvm_bootstrapped//platforms:linux_aarch64_gnu.2.36
@toolchains_llvm_bootstrapped//platforms:linux_aarch64_gnu.2.37
@toolchains_llvm_bootstrapped//platforms:linux_aarch64_gnu.2.38
@toolchains_llvm_bootstrapped//platforms:linux_aarch64_gnu.2.39
@toolchains_llvm_bootstrapped//platforms:linux_aarch64_gnu.2.40
@toolchains_llvm_bootstrapped//platforms:linux_aarch64_gnu.2.41
@toolchains_llvm_bootstrapped//platforms:linux_aarch64_gnu.2.42
```

Similar versions of glibc exist for `linux_x86_64`.

## Inspect the Build Output

You can verify that the resulting binary is linked against the expected `glibc` version using `readelf` or `strings`.

```bash
$ bazel build //:main --platforms=@toolchains_llvm_bootstrapped//platforms:linux_x86_64_gnu.2.28
$ strings bazel-bin/main | grep GLIBC_2.28
GLIBC_2.28
```

## Key Concepts

- **glibc Compatibility**: Targeting an older `glibc` (like 2.28) allows the binary to run on older systems (like Debian 10, RHEL 8, or Ubuntu 18.04) while still being Runnable on modern systems.
- **Hermetic Toolchains**: `toolchains_llvm_bootstrapped` provides the headers and libraries for these specific versions, so you don't need the corresponding Linux distribution installed to build for it.

## Code Highlights

### MODULE.bazel (partial)

The configuration is standard as the toolchain handles the versioning through platforms.

```python
bazel_dep(name = "toolchains_llvm_bootstrapped", version = "0.5.9")
```

### Build Command

By specifying the platform with a version suffix, Bazel selects the appropriate sysroot:

```bash
bazel build //... --platforms @toolchains_llvm_bootstrapped//platforms:linux_x86_64_gnu.2.31
```
