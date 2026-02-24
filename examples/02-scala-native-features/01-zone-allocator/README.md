# Zone Allocator

> **Prerequisites:** Familiarity with Scala, and understanding of basic Bazel Scala Native rules from the `examples/01-basics` section.

## Goal

Set up a Bazel project to use `Zone` for semi-automatic memory management in Scala Native.

## Description

In systems programming, manual memory management is often required, particularly when interacting with C-style APIs. Scala Native provides a unique feature called a `Zone` allocator, which allows for semi-automatic memory management.

A `Zone` represents a region of memory. When you allocate memory within a `Zone`, you don't need to manually free it object by object. Instead, all memory allocated within that `Zone` is automatically freed in a single operation when the `Zone` is closed (i.e., when the code block inside the `Zone` finishes executing). This helps prevent memory leaks while still providing control over memory lifetimes.

In this example, we:
1. Open a `Zone`.
2. Allocate a C-style string (`toCString`), which requires an implicit `Zone` in scope.
3. Access the value in the allocated memory using `fromCString`.
4. Observe that the memory is automatically freed when the `Zone` block exits.

## Build and Run Commands

To build and run the binary:
```bash
$ cd examples/02-scala-native-features/01-zone-allocator
$ bazel run //:main
```

The output will be:
```
Inside the zone. Allocating memory for a CString...
Value in zone-allocated memory: Hello world!
Zone closed. Memory has been freed.
```

## Key Concepts

- **`Zone`**: A region of memory where objects can be allocated. All objects in a `Zone` are deallocated when the zone is closed.
- **`implicit Zone`**: Many Scala Native memory operations (like `alloc[T]()` or `toCString`) require an implicit `Zone` in scope.
- **Memory Safety**: `Zone` helps prevent memory leaks by guaranteeing memory is freed, but you must ensure you do not use zone-allocated pointers outside the `Zone`'s scope.

## Code Highlights

### ZoneExample.scala
```scala
package examples

import scala.scalanative.unsafe.*

@main
def zone(): Unit =
    // Zones provide a way to manage lifetimes of allocated memory.
    // All memory allocated within a zone is freed when the zone is closed.
    Zone:
      println("Inside the zone. Allocating memory for a CString...")
      val cStr = toCString("Hello world!")  // toCString requires a zone allocator
      println(s"Value in zone-allocated memory: ${fromCString(cStr)}")

    // Memory pointed to by 'ptr' is now invalid/freed.
    println("Zone closed. Memory has been freed.")
```

### BUILD.bazel
```python
load(
    "@rules_scala_native//scala_native:scala_native_binary.bzl",
    "scala_native_binary",
)
load(
    "@rules_scala_native//scala_native:scala_native_library.bzl",
    "scala_native_library",
)

scala_native_library(
    name = "zone_example",
    srcs = ["ZoneExample.scala"],
)

scala_native_binary(
    name = "main",
    main_class = "examples.zone",
    deps = [
        ":zone_example",
    ],
)
```

## Next Steps

→ [02-pointers](../02-pointers/): Understand how to work with pointers in Scala Native.
