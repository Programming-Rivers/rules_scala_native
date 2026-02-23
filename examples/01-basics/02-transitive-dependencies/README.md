# Transitive Dependencies and Multi-Library Projects

> **Prerequisites:** [01-hello-world](../01-hello-world/) (Basic binary and library configuration)

## Goal

Understand how to structure a project with multiple libraries and manage complex, transitive dependency graphs in Bazel for such projecs.

## Description

In real-world projects, binaries rarely depend on a single library. Instead, they depend on libraries that in turn depend on other libraries. Bazel handles these **transitive dependencies** automatically.

In this example, we have the following dependency chain:
1.  **`main`** (Binary): The entry point of our application.
2.  **`pretty_printer`** (Library): Depends on `formatter`.
3.  **`formatter`** (Library): Depends on `char_operations`.
4.  **`char_operations`** (Library): A low-level utility library.

When we build `main`, Bazel ensures that `pretty_printer`, `formatter`, and `char_operations` are all compiled in the correct order.

## Project Structure

```text
02-transitive-dependencies/
├── BUILD.bazel               # Root build file (main and pretty_printer)
├── PrettyPrinter.scala       # Main entry point
├── core/
│   ├── BUILD.bazel           # Core library definition
│   └── CharOperations.scala  # Low-level utilities
└── services/
    ├── BUILD.bazel           # Services library definition
    └── Formatter.scala       # Formatting logic
```
A BUID.bazel file in a folder marks a package in Bazel.

> Best Practice: Bazel does NOT require a `src/main/scala/...` directory structure.
  It is recommended to structure the project directories in a way that resembles the logical components of the project.

> Best Practice: Bazel benefits from many small packages. They allow Bazel to build the project in parallel and avoid rebuilding unnecessary parts during incremental builds.

## Build & Run

To build and run the binary:
```bash
$ cd examples/01-basics/02-transitive-dependencies
$ bazel run //:main
```

The output will be:
```
FORMATED: MULTI TARGET GRAPH
```

## Key Concepts
- **Packages**: Any directory with a BUILD.bazel file is a package. The packages may have multiple targets. Packages should not beconfused with Bazel modules.
- **Label Syntax**:
    - `//:pretty_printer`: A target in the root `BUILD.bazel`.
    - `//services:formatter`: A target in the `services/BUILD.bazel` file.
- **Transitive Dependency**: If Target A depends on Target B, and Target B depends on Target C, then Target A transitively depends on Target C. Bazel manages this graph automatically.
- **Target Visibility**: Controls which other packages can depend on a target.
    - `//visibility:public`: Anyone can depend on this.
    - `//:__subpackages__`: Only targets within the top level package or its subpackages can depend on this.
    - `//path/to/a/specific:target`: Only the specificcan depend on this.

## Code Highlights

This project demonstrates how to split build logic across multiple files.

### Root `BUILD.bazel`
Defines the binary and the high-level library. Note how `pretty_printer` depends on `//services:formatter`.

```python
# BUILD.bazel (Partial)

scala_native_library(
    name = "pretty_printer",
    srcs = ["PrettyPrinter.scala"],
    deps = ["//services:formatter"],
)

scala_native_binary(
    name = "main",
    main_class = "example.run",
    deps = [":pretty_printer"],
)
```

### `services/BUILD.bazel`
Defines the `formatter` library. It uses `visibility = ["//:__subpackages__"]` to restrict usage to the root and its sub-directories.

```python
# services/BUILD.bazel
scala_native_library(
    name = "formatter",
    srcs = ["Formatter.scala"],
    deps = ["//core:char_operations"],
    visibility = ["//:__subpackages__"]
)
```

### `core/BUILD.bazel`
Defines the low-level `char_operations` library with public visibility.

```python
# core/BUILD.bazel
scala_native_library(
    name = "char_operations",
    srcs = ["CharOperations.scala"],
    visibility = ["//visibility:public"],
)
```

## Next Steps

Now that you've mastered dependency management, let's explore how to integrate with C and C++ libraries.

→ [03-static-and-dynamic-libraries](../03-static-and-dynamic-libraries/): Linking with native libraries.
