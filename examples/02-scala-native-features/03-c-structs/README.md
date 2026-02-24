# C-Compatible Structs

> **Prerequisites:** [02-pointers](../02-pointers/) (Working with pointers) and [01-zone-allocator](../01-zone-allocator/) (Memory management).

## Goal

Learn how to define and use C-compatible structs in Scala Native using `CStruct`.

## Description

In systems programming, data is often organized into contiguous blocks called structs. To interoperate with C libraries or manage low-level data layouts efficiently, Scala Native provides `CStruct` types. 

A `CStruct` allows you to define a fixed-size aggregate data structure that is memory-layout compatible with C. Fields in a `CStruct` are accessed using numbered accessors (`_1`, `_2`, etc.), which map directly to offsets in the underlying memory.

This example demonstrates:
1. Defining a `Coordinate` alias using `CStruct2[CInt, CInt]`.
2. Allocating memory for the struct within a `Zone`.
3. Setting and reading field values using the numbered accessors.

## Build and Run Commands

To build and run the binary:
```bash
$ cd examples/02-scala-native-features/03-c-structs
$ bazel run //:main
```

The output will be:
```
Location coordinates: x=10, y=20
```

## Key Concepts

- **`CStructN[T1, T2, ...]`**: Types representing fixed-size aggregate data structures compatible with C (where N is the number of fields, up to 22).
- **Numbered Accessors**: Fields are accessed via `_1`, `_2`, ..., `_N`. These are both getters and setters (using Scala's update syntax).
- **Memory Layout**: A `CStruct` is laid out in memory exactly like a C struct, making it safe to pass to native functions via pointers.
- **`alloc[T]()`**: Allocates memory for the type `T` (like our struct) within the current implicit `Zone`.

## Code Highlights

### Coordinate.scala
```scala
package examples

import scala.scalanative.unsafe.*

// Define a C-compatible struct entirely in Scala Native.
// This is equivalent to C's: struct Point { int x; int y; }
type Coordinate = CStruct2[CInt, CInt]

@main
def createCoordinate(): Unit =
  Zone:
    val location = alloc[Coordinate]()
    
    // Access fields using _1, _2, etc.
    location._1 = 10
    location._2 = 20
    
    println(s"Location coordinates: x=${location._1}, y=${location._2}")
```

### BUILD.bazel
```python
scala_native_library(
    name = "struct_coordinate",
    srcs = ["Coordinate.scala"],
)

scala_native_binary(
    name = "main",
    main_class = "examples.createCoordinate",
    deps = [
        ":struct_coordinate",
    ],
)
```

## Next Steps

→ [04-posix-bindings](../04-posix-bindings/): Interacting with the operating system using POSIX bindings.
