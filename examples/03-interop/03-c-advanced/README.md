# Advanced C Interop: Callbacks and Function Pointers

> **Prerequisites:** [02-c-structs-and-strings](../02-c-structs-and-strings/) (Complex types), [02-scala-native-features/03-c-structs](../../02-scala-native-features/03-c-structs/) (Memory layouts).

## Goal

Learn how to work with function pointers and handle callbacks between Scala Native and C.

## Description

In systems programming, it is common for a C library to accept a "callback"—a pointer to a function that the library will execute later. Scala Native supports this through the `CFuncPtr` family of types.

This example demonstrates how to:
1.  **Define a C Callback**: A C function (`perform_action`) that takes an integer and a function pointer.
2.  **Declare the Interface in Scala**: Using `CFuncPtr1[CInt, Unit]` to represent the C function pointer signature in our `@extern` object.
3.  **Implement the Callback in Scala**: Defining a Scala function and passing it directly to the C code. Scala Native automatically handles the "lifting" of the Scala function into a format that the C ABI understands.

Callbacks are essential for implementing event loops, asynchronous APIs, and plugin systems where native code needs to trigger high-level logic.

## Build and Run Commands

To build and run the binary:

```bash
$ cd examples/03-interop/03-c-advanced
$ bazel run //:main
```

The output will be:

```
C: Performing action with value 21...
Scala: Callback received value 42
```

## Key Concepts

-   **`CFuncPtrN[T1, ..., TN, R]`**: A family of types representing C function pointers that take $N$ arguments of types $T$ and return $R$.
-   **Function Lifting**: The process where a Scala function is converted into a raw pointer that matches the C Calling Convention.
-   **`@extern` Objects**: Used here to map the C function that takes the pointer.

## Code Highlights

### callbacks.c

```c
#include <stdio.h>

typedef void (*callback_t)(int);

void perform_action(int value, callback_t cb) {
    printf("C: Performing action with value %d...\n", value);
    cb(value * 2);
}
```

### Callbacks.scala

```scala
package examples

import scala.scalanative.unsafe.*

@extern
object CCallbacks:
  // CFuncPtr1[T1, R] is a function pointer that takes T1 and returns R
  def perform_action(value: CInt, cb: CFuncPtr1[CInt, Unit]): Unit = extern

inline def callback(n: CInt): Unit =
  println(s"Scala: Callback received value $n")

@main
def callbacks(): Unit =
  CCallbacks.perform_action(21, callback)
```

### BUILD.bazel (partial)

```python
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
    main_class = "examples.callbacks",
    deps = [
        ":c_callbacks",
        ":scala_callbacks",
    ],
)
```

## Next Steps

→ [04-cpp](../04-cpp/): Interoperating with C++ using `extern "C"` wrappers.

