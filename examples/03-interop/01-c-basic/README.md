# Basic C Interoperability

> **Prerequisites:** [02-scala-native-features/03-c-structs](../../02-scala-native-features/03-c-structs/) (Memory layouts)

## Goal

Learn how to call basic C functions from Scala Native using the `@extern` annotation and standard Bazel `cc_library` rules.

## Description

Interoperability with C is a core feature of Scala Native. This example demonstrates the most basic form of "Foreign Function Interface" (FFI): calling a simple C function that performs integer addition.

In this setup:
1.  **C Implementation**: We have a standard C file (`adder.c`) containing an `add` function.
2.  **Bazel Bridging**: We use the standard Bazel `cc_library` rule to compile the C code. This library is then added as a dependency to our `scala_native_binary`.
3.  **Scala Declaration**: In Scala, we use the `@extern` annotation on a singleton object to declare the signature of the foreign function. The `extern` keyword marks the method body, telling the compiler that the implementation will be provided at link-time.

This pattern is the foundation for all native interop, including interacting with system libraries like POSIX or specialized hardware drivers.

## Build and Run Commands

To build and run the binary:

```bash
$ cd examples/03-interop/01-c-basic
$ bazel run //:main
```

The output will be:

```
Result of C add(5, 7): 12
```

## Key Concepts

-   **`@extern` annotation**: Tells the Scala Native compiler that the methods in the annotated object are implemented in external C code.
-   **`extern` keyword**: Used as a placeholder in Scala method bodies that are bound to foreign functions.
-   **`cc_library`**: The standard Bazel rule for C/C++ libraries. `rules_scala_native` is designed to seamlessly link with these native components.
-   **Link-time Resolution**: The actual connection between the Scala call and the C implementation happens during the linking phase of the Bazel build.

## Code Highlights

### adder.c

```c
int add(int a, int b) {
    return a + b;
}
```

### Adder.scala

```scala
package examples

import scala.scalanative.unsafe.*

@extern
object CAdd:
    // This signature must match the C implementation exactly
    def add(a: CInt, b: CInt): CInt = extern

@main
def add(): Unit =
    val result = CAdd.add(5, 7)
    println(s"Result of C add(5, 7): $result")
```
### MODULE.bazel (partial)
To use both Scala Native and C code in the same project, we need to use `rules_cc`
and provide a C toolchain to Bazel.

```python
# Build rules that Bazel needs to compile, link, and produce artifacts from C or C++ source code.
bazel_dep(
    name = "rules_cc",
    version = "0.2.16",
)

# ... 

# Use the hermetic, zero-sysroot LLVM toolchain.
# A hermeticity isolates the build from host environment variations,
#     ensuring bit-by-bit reproducibility.
# A zero-sysroot toolchain provides its own C library and headers,
#     avoiding host dependencies, making cross-compilation easier and more reliable.
bazel_dep(
    name = "llvm",
    version = "0.6.1",
)
```

Providinng a hermatic toolchain is not mandatory,
but it prevents Bazel to fall back on the toolchain installed on the host,
which can cause issues for cross-compilation.

Here we use `llvm` to provide a hermatic toolchain,
and vanish the source of many potential cross-compilation issues,
such as the exact location or version of the library and headers.

### BUILD.bazel

```python
# NOTE: cc_library is required for compiling C (or C++).
cc_library(
    name = "c_adder",
    srcs = ["adder.c"],
)
load(
    "@rules_scala_native//scala_native:scala_native_binary.bzl",
    "scala_native_binary",
)
load(
    "@rules_scala_native//scala_native:scala_native_library.bzl",
    "scala_native_library",
)

scala_native_library(
    name = "scala_adder",
    srcs = ["Adder.scala"],
    # NOTE: No need to link the C code implementation to the scala_native_library.
    # The C code will be linked to the scala_native_binary.
)

scala_native_binary(
    name = "main",
    main_class = "examples.add",
    deps = [
        ":c_adder",      # Link the C code implementation
        ":scala_adder",
    ],
)
```

## Next Steps

→ [02-c-structs-and-strings](../02-c-structs-and-strings/): Passing complex types like strings and structs between languages.

