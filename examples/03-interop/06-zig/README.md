# Interoperability with Zig

> **Prerequisites:** [01-c-basic](../01-c-basic/) (Basic FFI).

## Goal

Learn how to interoperate with Zig code from Scala Native using `rules_zig` and the C ABI.

## Description

Scala Native can integrate smoothly with Zig by leveraging the C Application Binary Interface (ABI).
Zig is particularly well-suited for interop because it naturally speaks C and can easily expose C-compatible symbols.

In this example:
1.  **Zig Implementation**: We define an `add` function in Zig (`adder.zig`).
    By using the `export fn` keyword,
    we instruct the Zig compiler to expose the function
    using the standard C calling convention without name mangling.
2.  **Bazel Bridging**: We use `rules_zig` to compile the Zig source
    into a `zig_static_library`.
    We then link this static library as a dependency of our `scala_native_binary`.
3.  **Scala Declaration**: Just like with C and Rust,
    we declare an `@extern` object in Scala Native
    with a signature matching the exported Zig function.

This allows us to seamlessly call high-performance Zig code
from Scala Native with zero overhead.

## Build and Run Commands

To build and run the binary:

```bash
$ cd examples/03-interop/06-zig
$ bazel run //:main
```

The output will be:

```
Result of Zig add(15, 27): 42
```

## Key Concepts

-   **`zig_static_library`**: A Bazel rule from `rules_zig`
    used to compile Zig source files into a static library
    suitable for linking with Scala Native or C.
-   **`export fn`**: Zig's syntax for defining a function
    that is exported with the C ABI.
    It prevents name mangling and makes the function callable by Scala Native.
-   **C ABI compatibility**: Since Zig natively supports C ABIs,
    Scala Native can call Zig functions without any wrapper or intermediary code.

## Code Highlights

### adder.zig

```zig
const std = @import("std");

export fn add(a: i32, b: i32) i32 {
    return a + b;
}
```

### Adder.scala

```scala
package examples

import scala.scalanative.unsafe.*

@extern
object ZigAdder:
    def add(a: CInt, b: CInt): CInt = extern

@main
def add(): Unit =
    val result = ZigAdder.add(15, 27)
    println(s"Result of Zig add(15, 27): $result")
```

### BUILD.bazel

```python
# rules_zig is required for building Zig code
load(
    "@rules_zig//zig:defs.bzl",
    "zig_static_library",
)
load(
    "@rules_scala_native//scala_native:scala_native_binary.bzl",
    "scala_native_binary",
)
load(
    "@rules_scala_native//scala_native:scala_native_library.bzl",
    "scala_native_library",
)

# Build a static library from Zig source code.
zig_static_library(
    name = "zig_adder",
    # -fPIC is required for linking with Scala Native
    main = "adder.zig",
    zigopts = ["-fPIC"],
    compiler_runtime = "include",
)

scala_native_library(
    name = "scala_adder",
    srcs = ["Adder.scala"],
)

scala_native_binary(
    name = "main",
    main_class = "examples.add",
    deps = [
        ":zig_adder", # Link the Zig code implementation
        ":scala_adder",
    ],
)
```

> **NOTE**: Scala Native's linker requires position-independent code (PIC).
  The `-fPIC` flag instructs Zig to generate relocatable code, otherwise
  Zig static libraries are built with absolute address relocations by default.

### MODULE.bazel (partial)

To compile Zig code, you must include `rules_zig` and register a Zig toolchain in your module setup:

```python
bazel_dep(
    name = "rules_zig",
    version = "0.12.3",
)

# ...

zig = use_extension("@rules_zig//zig:extensions.bzl", "zig")
zig.toolchain(zig_version = "0.14.1")
use_repo(zig, "zig_toolchains")

register_toolchains("@zig_toolchains//:all")
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

## Next Steps

Congratulations! You have completed the **Cross-Language Interop** learning path. You now know how to integrate C, C++, Rust, and Zig libraries seamlessly into your Scala Native modules using Bazel.
