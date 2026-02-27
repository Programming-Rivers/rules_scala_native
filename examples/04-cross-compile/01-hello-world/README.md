# Cross-compiling a Hello World Binary

> **Prerequisites:** Familiarity with Scala and basic Bazel builds

## Goal

Compile a Scala Native binary for different target platforms using cross-compilation.

## Description
A Scala Native binary is an executable file compiled for a specific target platform. 
In this example, we demonstrate how to cross-compile our hello world application to a different architecture or OS using the `--platform` flag.

The entry point is the `greet` function in `Greetings.scala`, which is annotated with `@main`.

## Build & Run

To cross-compile the binary for a specific target, use the `--platforms` flag:
```bash
$ cd examples/04-cross-compile/01-hello-world
$ bazel build //... --platforms=<platform>
```

> **Note:** The command should run from the same directory that contains the `MODULE.bazel` file.

These are some platforms that you can use:
* `@toolchains_llvm_bootstrapped//platforms:linux_aarch64`
* `@toolchains_llvm_bootstrapped//platforms:linux_x86_64`
* `@toolchains_llvm_bootstrapped//platforms:macos_aarch64`
* `@toolchains_llvm_bootstrapped//platforms:macos_x86_64`
* `@toolchains_llvm_bootstrapped//platforms:windows_aarch64`
* `@toolchains_llvm_bootstrapped//platforms:windows_x86_64`

## Inspect the Build Output

The resulting binary will be built in the Bazel output directories (typically under `bazel-out/`) corresponding to the selected platform. Depending on the target architecture, you can inspect it using tools like `file` or `readelf`.

For example, if you cross-compile to Linux x86_64:
```bash
$ bazel build //:main --platforms=@toolchains_llvm_bootstrapped//platforms:linux_x86_64
$ file bazel-bin/main
bazel-bin/main: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 2.0.0, not stripped
```

If you cross-compile to Linux aarch64:
```bash
$ bazel build //:main --platforms=@toolchains_llvm_bootstrapped//platforms:linux_aarch64
$ file bazel-bin/main
bazel-bin/main: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-aarch64.so.1, for GNU/Linux 3.2.0, not stripped
```

If you cross-compile to macOS aarch64:
```bash
$ bazel build //:main --platforms=@toolchains_llvm_bootstrapped//platforms:macos_aarch64
$ file bazel-bin/main
bazel-bin/main: Mach-O 64-bit arm64 executable, flags:<NOUNDEFS|DYLDLINK|TWOLEVEL|PIE>
```

On windows the output is `main.exe`, not `main`:
```bash
$ bazel build //:main --platforms=@toolchains_llvm_bootstrapped//platforms:windows_aarch64
$ file bazel-bin/main.exe
bazel-bin/main.exe: PE32+ executable (console) Aarch64, for MS Windows, 6 sections
```

## Key Concepts
- **Cross-compilation**: Compiling code for a platform other than the one you are currently running on.
- **`--platforms` flag**: Instructs Bazel to build for a specific target platform. Bazel resolves this to the appropriate toolchain (like `@toolchains_llvm_bootstrapped`).

## Code Highlights

### MODULE.bazel (partial)
```python
module(name = "example_01_example_cross_compile_hello_world")

bazel_dep(name = "protobuf", version = "33.4")
bazel_dep(name = "rules_scala", version = "7.2.2")
bazel_dep(name = "rules_scala_native", version = "0.1.0")
# To cross-compile, we need a C/C++ toolchain.
# toolchains_llvm_bootstrapped provides a hermetic, zero-sysroot LLVM toolchain.
bazel_dep(name = "toolchains_llvm_bootstrapped", version = "0.5.9")
```

The `toolchains_llvm_bootstrapped` provides the LLVM for cross-compilation.

### BUILD.bazel
```python
load(
    "@rules_scala_native//scala_native:scala_native_binary.bzl",
    "scala_native_binary",
)
# Instruct bazel that the scala_native_library is required to build this package.
load(
    "@rules_scala_native//scala_native:scala_native_library.bzl",
    "scala_native_library",
)

# Defines a library containing the greeting logic.
scala_native_library(
    name = "greetings",
    srcs = ["Greetings.scala"],
)

# Defines the entry point required for the executable
scala_native_binary(
    name = "main",
    main_class = "examples.greet",  # main_class must match the signature of the @main function in Greetings.scala
    deps = [":greetings"],
)
```

### Greetings.scala
```scala
// Greetings.scala

package examples

@main
def greet: Unit =
  println(s"Hello from Scala Native!")
```

## Next Steps

→ [02-binary-with-dep](../02-binary-with-dep/): Linking binaries with external dependencies.
