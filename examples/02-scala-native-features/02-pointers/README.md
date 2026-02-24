# Pointers and Stack Allocation

> **Prerequisites:** [01-zone-allocator](../01-zone-allocator/) (Memory management)

## Goal

Understand how to work with pointers (`Ptr[T]`), perform stack-based memory allocation, and use pointer arithmetic in Scala Native.

## Description

Pointers are the foundational tool for interacting with memory in systems programming. In Scala Native, the `Ptr[T]` type represents a pointer to a value of type `T`. 

This example demonstrates three core operations:

1.  **Stack Allocation**: Using `stackalloc[T]` to reserve memory on the current thread's stack. This is the fastest form of allocation and is automatically managed—the memory is reclaimed as soon as the function returns.
2.  **Dereferencing**: Using the unary `!` operator to read from or write to the memory location pointed to. This provides direct access to the underlying bytes.
3.  **Pointer Arithmetic**: Using operators like `+` to move the pointer address. In Scala Native, adding `1` to a `Ptr[T]` moves the address forward by exactly `sizeof(T)` bytes, allowing you to traverse arrays or contiguous memory buffers.

Unlike `Zone` allocation, which manages object lifetimes within a block, `stackalloc` has a lifetime tied strictly to the function call, making it ideal for temporary buffers or small, short-lived records.

## Build and Run Commands

To build and run the binary:

```bash
$ cd examples/02-scala-native-features/02-pointers
$ bazel run //:main
```

The output will be:

```
Value at pointer: 42
Value at next pointer: 100
```

## Key Concepts

-   **`Ptr[T]`**: A type representing a memory address.
-   **`stackalloc[T]`**: Allocates memory for type `T` on the stack.
-   **`!` (Dereference)**: The operator used to access the value at the pointer's memory address. `!ptr = value` performs a store, and `!ptr` performs a load.
-   **Pointer Arithmetic**: The ability to increment or decrement a pointer to point to adjacent memory elements of the same type.

## Code Highlights

### PointerOps.scala

```scala
package examples

import scala.scalanative.unsafe.*

@main
def pointerExample(): Unit =
    // Allocate an integer on the stack
    val ptr = stackalloc[CInt]()
    
    // Set the value (dereference and assign)
    !ptr = 42
    
    println(s"Value at pointer: ${!ptr}")
    
    // Pointer arithmetic (moving to the "next" int position)
    val nextPtr = ptr + 1
    !nextPtr = 100
    
    println(s"Value at next pointer: ${!nextPtr}")
```

### BUILD.bazel

```python
scala_native_library(
    name = "pointer_example",
    srcs = ["PointerOps.scala"],
)

scala_native_binary(
    name = "main",
    main_class = "examples.pointerExample",
    deps = [
        ":pointer_example",
    ],
)
```

## Next Steps

→ [03-c-structs](../03-c-structs/): Mapping Scala objects to C-style memory layouts.
