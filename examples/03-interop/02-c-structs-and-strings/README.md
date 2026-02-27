# Interoperability with C Structs and Strings

> **Prerequisites:** [01-c-basic](../01-c-basic/) (Basic FFI), [02-scala-native-features/03-c-structs](../../02-scala-native-features/03-c-structs/) (Memory layouts).

## Goal

Learn how to pass complex types like pointers to structs and strings between Scala Native and C.

## Description

Real-world C libraries rarely deal only with integers. They frequently exchange strings and data structures. This example demonstrates how to bridge these types while maintaining memory safety using the `Zone` allocator.

Key aspects of this example:
1.  **C Strings**: How to convert a Scala `String` (which is a managed JVM-style object) into a native `CString` (a null-terminated buffer).
2.  **Structuring Memory**: Using `CStructN` to define a Scala type that matches a C `struct` layout exactly.
3.  **Pointer Semantics**: Passing a pointer (`Ptr[T]`) to the struct rather than the value itself, matching the standard C convention for data exchange.
4.  **Resource Management**: Using a `Zone` to ensure that both the string and the struct are allocated and subsequently freed automatically.

## Build and Run Commands

To build and run the binary:

```bash
$ cd examples/03-interop/02-c-structs-and-strings
$ bazel run //:main
```

The output will be:

```
Hello, Scala Native Learner! Your point is at (15, 30)
```

## Key Concepts

-   **`CString`**: Represents a pointer to a null-terminated array of characters. In systems programming, this is the standard representation for strings.
-   **`toCString`**: A utility function that allocates native memory and copies a Scala `String` into it. Because it allocates native memory, it requires an implicit `Zone`.
-   **`CStruct2[CInt, CInt]`**: A type alias that represents a C struct with two integer fields. Scala Native handles the alignment and padding to match the target CPU's ABI.
-   **`alloc[T]()`**: Allocates memory for type `T` within the current `Zone`. This is used here to reserve space for the `Point` struct.

## Code Highlights

### greeter.c

```c
typedef struct {
    int x;
    int y;
} Point;

void greet(const char* name, Point* p) {
    printf("Hello, %s! Your point is at (%d, %d)\n", name, p->x, p->y);
}
```

### CGreeter.scala

```scala
package examples

import scala.scalanative.unsafe.*

// Define a Scala type matching the C struct layout
type Point = CStruct2[CInt, CInt]

@extern
object CGreeter:
  def greet(name: CString, p: Ptr[Point]): Unit = extern

@main
def interopExample(): Unit =
  Zone: // Memory for 'p' and 'name' lives until this block ends
    val p = alloc[Point]()
    p._1 = 15 // Accessing struct fields via index-based setters
    p._2 = 30
    
    val name = toCString("Scala Native Learner")
    CGreeter.greet(name, p)
```

### BUILD.bazel

```python
load(
    "@rules_cc//cc:cc_library.bzl",
    "cc_library",
)
load(
    "@rules_scala_native//scala_native:scala_native_binary.bzl",
    "scala_native_binary",
)
load(
    "@rules_scala_native//scala_native:scala_native_library.bzl",
    "scala_native_library",
)

cc_library(
    name = "c_callbacks",
    srcs = ["callbacks.c"],
)

scala_native_library(
    name = "scala_callbacks",
    srcs = ["Callbacks.scala"],
)

scala_native_binary(
    name = "main",
    main_class = "examples.Callbacks",
    deps = [
        ":c_callbacks",
        ":scala_callbacks",
    ],
)
```

### MODULE.bazel (partial)
This project still needs the `rules_cc` and an LLVM toolchain, which are provided by the `MODULE.bazel` file:

```python
# Build rules that Bazel needs to compile, link, and produce artifacts from C or C++ source code.
bazel_dep(
    name = "rules_cc",
    version = "0.2.16",
)

# ...

# Use the hermetic, zero-sysroot LLVM toolchain.
bazel_dep(
    name = "llvm",
    version = "0.6.1",
)
```

## Next Steps

→ [03-c-advanced](../03-c-advanced/): Advanced C interop with function pointers and callbacks.

