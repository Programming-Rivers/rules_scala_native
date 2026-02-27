# Interoperability with Rust

> **Prerequisites:** [04-cpp](../04-cpp/) (C wrapper interop), [01-c-basic](../01-c-basic/) (Basic FFI).

## Goal

Learn how to interoperate with Rust code from Scala Native using `rules_rust` and the C ABI.

## Description

Thanks to the C ABI (Application Binary Interface) serving as the *lingua franca* of systems programming, Scala Native can directly interoperate with any language that can expose C-compatible symbols. Rust is a modern, memory-safe language that makes exposing C APIs very straightforward.

In this example:
1.  **Rust Implementation**: We define an `add` function in Rust (`rust_adder.rs`). We use `#[unsafe(no_mangle)]` and `pub extern "C" fn` to ensure the Rust compiler exports the function under its exact name using the C calling convention.
2.  **Bazel Bridging**: We use `rules_rust` to compile the Rust file into a `rust_static_library`. This static library is then directly linked into our `scala_native_binary`.
3.  **Scala Declaration**: From Scala Native's perspective, calling Rust is indistinguishable from calling C. We simply declare the `@extern` object and use exactly the same FFI mechanisms as in `01-c-basic`.

## Build and Run Commands

To build and run the binary:

```bash
$ cd examples/03-interop/05-rust
$ bazel run //:main
```

The output will be:

```
Starting Rust Interop Example...
Result from Rust: 42
--- Done ---
```

## Key Concepts

-   **`rust_static_library`**: A Bazel rule from `rules_rust` used to compile Rust source files into a static library that Scala Native can easily link against.
-   **`#[unsafe(no_mangle)]` / `#[no_mangle]`**: A Rust attribute that prevents the compiler from obfuscating (mangling) the function's name in the compiled object file. Scala Native looks for the exact function name.
-   **`pub extern "C" fn`**: Tells the Rust compiler to use the C calling convention for this function.
-   **Shared C ABI**: The underlying mechanism that allows zero-overhead calls between Scala Native and Rust.

## Code Highlights

### rust_adder.rs

```rust
#[unsafe(no_mangle)]
pub extern "C" fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

### RustInterop.scala

```scala
package examples

import scala.scalanative.unsafe.*

@extern
object RustAdder:
    def add(a: CInt, b: CInt): CInt = extern

@main
def rustInteropExample(): Unit =
  println("Starting Rust Interop Example...")
  val result = RustAdder.add(10, 32)
  println(s"Result from Rust: $result")
  println("--- Done ---")
```

### BUILD.bazel

```python
# rules_rust is required for building Rust code
load(
    "@rules_rust//rust:defs.bzl",
    "rust_static_library",
)
load(
    "@rules_scala_native//scala_native:scala_native_binary.bzl",
    "scala_native_binary",
)
load(
    "@rules_scala_native//scala_native:scala_native_library.bzl",
    "scala_native_library",
)

# Build a static library from Rust source code.
rust_static_library(
    name = "rust_adder_lib",
    srcs = ["rust_adder.rs"],
)

scala_native_library(
    name = "scala_rust_interop",
    srcs = ["RustInterop.scala"],
)

scala_native_binary(
    name = "main",
    main_class = "examples.rustInteropExample",
    deps = [
        ":rust_adder_lib", # Link the Rust code implementation
        ":scala_rust_interop",
    ],
)
```

### MODULE.bazel (partial)

To compile Rust, you must include `rules_rust` and register a Rust toolchain in your module setup:

```python
bazel_dep(
    name = "rules_rust",
    version = "0.68.1",
)

# ...

rust = use_extension("@rules_rust//rust:extensions.bzl", "rust")
rust.toolchain(
    edition = "2024",
    versions = ["1.93.0"],
)
use_repo(rust, "rust_toolchains")

register_toolchains("@rust_toolchains//:all")
```

### .bazelrc

```bash
common --tool_java_runtime_version=remotejdk_17
common --java_runtime_version=remotejdk_17
common --@protobuf//bazel/toolchains:prefer_prebuilt_protoc
# Instruct clang to not link libunwind becaeuse
# Rust has specific its own unwinding strategy for panics.
# Note that unwinding accross FFI boundaries is undefined behavior.
build --linkopt="-unwindlib=none"
# Rust toolcahin needs libgcc_s
build --@llvm//config:experimental_stub_libgcc_s=True
```
The two extra settings required for Rust interop are:
1. `build --linkopt="-unwindlib=none"`
   Instruct clang to not link libunwind.
   libunwind is used for unwinding the stack during an exception in C++.
   Rust does not use exceptions and has specific its own unwinding strategy for panics.
   Note that unwinding accross FFI boundaries is undefined behavior.
2. `build --@llvm//config:experimental_stub_libgcc_s=True`
   Rust toolcahin needs libgcc_s.
   The default llvm does not provide libgcc_s.
   But it is possible to instruct the toolchain to provide the default libgcc_s,
   or a sepecific version of it.
   See [Usage with Rust](https://github.com/cerisier/llvm?tab=readme-ov-file#usage-with-rust)
   for other flags that may be required for interop with Rust. 

## Next Steps

→ [06-zig](../06-zig/): Interoperating with Zig.
