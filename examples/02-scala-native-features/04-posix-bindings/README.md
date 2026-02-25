# POSIX Bindings

> **Prerequisites:** [01-pointers](../01-pointers/), [02-pointers](../02-pointers/)

## Goal

Understand how to use the built-in POSIX bindings in Scala Native to make system calls.

## Description

Scala Native provides built-in bindings for many standard POSIX (Portable Operating System Interface) functions. This allows your Scala code to interact directly with the operating system without the overhead of the JVM or the need to write custom C wrappers.

The `scala.scalanative.posix.*` package contains these bindings, mirroring the structure of standard C headers like `unistd.h`, `sys/stat.h`, `fcntl.h`, etc.

In this example, we:
1. Call `unistd.getpid()` to retrieve the current process ID.
2. Call `unistd.getcwd()` to get the current working directory, which requires passing a C-style string buffer allocated via `alloc` inside a `Zone`.

## Build and Run Commands

To build and run the binary:
```bash
$ cd examples/02-scala-native-features/04-posix-bindings
$ bazel run //:main
```

The output will be similar to:
```
Making direct POSIX system calls from Scala Native...
The current process ID is: 2993154
Current working directory: /home/.../bazel-out/k8-fastbuild/bin/main.runfiles/_main
```

> Note: The current worknig directory is within the sandbox created by Bazel, not the directory where the Bazel command was run.

## Key Concepts

- **`scala.scalanative.posix.*`**: The package containing bindings to common POSIX libraries and functions.
- **System Calls**: Scala Native allows zero-overhead calls to operating system functions, giving you the same low-level capabilities as C.
- **Buffer Management**: Many POSIX functions require passing memory buffers (like `CChar` arrays). These buffers must be managed properly using `Zone`, `alloc`, or `stackalloc`.

## Code Highlights

### FileStats.scala
```scala
package examples

import scala.scalanative.unsafe.*
import scala.scalanative.unsigned.*
import scala.scalanative.posix.unistd

@main
def posixExample(): Unit =
  println("Making direct POSIX system calls from Scala Native...")

  // Get current process ID
  val pid = unistd.getpid()
  println(s"The current process ID is: $pid")

  Zone:
    val buffer = alloc[CChar](1024)
    // Get current working directory
    unistd.getcwd(buffer, 1024.toCSize) match
      case null => 
        println("Failed to get current working directory.")
      case cwdPtr =>
        println(s"Current working directory: ${fromCString(cwdPtr)}")
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
    name = "posix_bindings",
    srcs = ["FileStats.scala"],
    deps = [
        "@org_scala_native_posixlib//jar",  # Required for importing scala.scalanative.posix
        "@org_scala_native_clib//jar",      # Required for access to types such as size_t
    ],
)

scala_native_binary(
    name = "main",
    main_class = "examples.posixExample",
    deps = [
        ":posix_bindings",
    ],
)
```

## Next Steps

→ [05-intrinsics](../05-intrinsics/): Using low-level compiler intrinsics.
