# Scala Native Examples

Welcome to the Scala Native examples! This repository provides a progressive, step-by-step curriculum designed to help you master Bazel for buliding Scala Native applications.

Each example is a self-contained Bazel module that focuses on a specific set of concepts, building upon the previous ones.

## 🎓 Learning Curriculum

### 1. [Basics](./01-basics)
Learn the fundamental building blocks of a Scala Native project in Bazel.
- **[00-bazel-setup](./01-basics/00-bazel-setup)**: The absolute minimum setup required for a Scala Native project.
- **[01-hello-world](./01-basics/01-hello-world)**: Creating your first native binary.
- **[02-transitive-dependencies](./01-basics/02-transitive-dependencies)**: Managing library dependencies and classpath.
- **[03-testing](./01-basics/03-testing)**: Setting up and running JUnit tests for native code.
- **[05-static-and-dynamic-libraries](./01-basics/05-static-and-dynamic-libraries)**: Building and linking against static and shared libraries.

### 2. [Scala Native Features](./02-scala-native-features)
Explore features that allow you to write high-performance code close to the hardware.
- **[01-zone-allocator](./02-scala-native-features/01-zone-allocator)**: Efficient memory management using Zones.
- **[02-pointers](./02-scala-native-features/02-pointers)**: Manual memory management and pointer arithmetic.
- **[03-c-structs](./02-scala-native-features/03-c-structs)**: Working with C-style data structures directly in Scala.
- **[04-posix-bindings](./02-scala-native-features/04-posix-bindings)**: Interacting with the underlying operating system using standard POSIX APIs.
- **[05-intrinsics](./02-scala-native-features/05-intrinsics)**: Accessing platform-specific low-level instructions.

### 3. [Interoperability](./03-interop)
Master the art of calling code written in other native languages.
- **[01-c-basic](./03-interop/01-c-basic)**: Simple Foreign Function Interface (FFI) calls to C.
- **[02-c-structs-and-strings](./03-interop/02-c-structs-and-strings)**: Passing complex data types between Scala and C.
- **[03-c-advanced](./03-interop/03-c-advanced)**: Advanced patterns like callbacks and opaque pointers.
- **[04-cpp](./03-interop/04-cpp)**: Interfacing with C++ code via C wrappers.
- **[05-rust](./03-interop/05-rust)**: seamless integration with the Rust ecosystem.
- **[06-zig](./03-interop/06-zig)**: Using Zig as a modern systems language with Scala Native.

### 3. [Cross-compilation](./04-cross-compile)
- **[01-c-basic](./04-cross-compile/01-cross-compile-hello-world)**: Cross compile hello world to various platforms

## 🚀 How to Run

To run any example, navigate to its directory or use the full Bazel label from the root. For example, to run the "Hello World" example:

```bash
# From the project root
bazel run //examples/01-basics/01-hello-world:hello
```

To run tests:

```bash
bazel test //examples/01-basics/03-testing:test
```

## 🛠️ Requirements

See the root [README.md](../README.md) for detailed requirements, including Bazel version and toolchain setup.
