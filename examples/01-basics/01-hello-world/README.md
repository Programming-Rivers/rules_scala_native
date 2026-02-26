# Hello World Binary with Library

> **Prerequisites:** Familiarity with Scala

## Goal

Create and run a hello world binary in Scala Native.

## Description
A Scala Native binary is an executable file compiled for a specific target platform. 
In this example, we demonstrate how to:
1. Define a **library** (`greetings`) containing shared logic.
2. Define a **binary** (`hello_world`) that depends on that library.

The entry point is the `greet` function in `Greetings.scala`, which is annotated with `@main`.

## Build & Run

To build and run the binary:
```bash
$ cd examples/01-basics/01-hello-world
$ bazel run //:hello_world
```

The output will be:
```
Hello from Scala Native!
```

Bazel tracks all the dependencies required to build and run the hello world binary.
Bazel ensures the required dependencies are built and available before running the hello world binary.

Run this command to build, but not run, the binary:
```bash
$ cd examples/01-basics/01-hello-world
$ bazel build //:main
```

## Inspect the Build Output

The jar output of the library `greetings` contains not only .class/.tasty files but also .nir files.
The .nir files can be linked together to produce a native executable.
```bash
# List the contents of the jar file
$ jar --list --file=bazel-bin/greetings.jar
META-INF/
META-INF/MANIFEST.MF
examples/
examples/Greetings$package$.class
examples/Greetings$package$.nir
examples/Greetings$package.class
examples/Greetings$package.nir
examples/Greetings$package.tasty
examples/greet.class
examples/greet.nir
examples/greet.tasty
```

The generated binary is specific to the platform it was built on. For example, if you build on Linux with an x86-64 architecture, the result is an ELF64 binary.
You can inspect the header file of the binary using the `readelf` command.
```
# Read the headerfile of the hello_world binary
$ readelf --file-header bazel-bin/hello_world
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00 
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              DYN (Position-Independent Executable file)
  Machine:                           Advanced Micro Devices X86-64
  Version:                           0x1
  Entry point address:               0x62960
  Start of program headers:          64 (bytes into file)
  Start of section headers:          1444744 (bytes into file)
  Flags:                             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         11
  Size of section headers:           64 (bytes)
  Number of section headers:         29
  Section header string table index: 27
```


## Key Concepts
- **Scala Native binary**: An executable file produced by compiling Scala code using Scala Native.
- **`scala_native_binary` rule**: A Bazel rule that links Scala Native source and libraries into an executable.
- **Scala Native library**: A jar file containing NIR files, used as a dependency.
- **`scala_native_library` rule**: A Bazel rule that compiles Scala code into a Scala Nativelibrary.
- **`name` attribute**: The string identifier for a target, such as a library or a binary.
- **`deps` attribute**: Libraries that the binary depends on.

## Code Highlights

### BUILD.bazel
```python
load(
    "@rules_scala_native//scala_native:scala_native_binary.bzl",
    "scala_native_binary",
)
# Instruct bazel that the scala_native_library is required to build this package.
load(
    "@rules_scala_native//scala_native:scala_native_library.bzl",
    "scala_native_library",
)

# Defines a library containing the greeting logic.
scala_native_library(
    name = "greetings",
    srcs = ["Greetings.scala"],
)

# Defines the entry point required for the executable
scala_native_binary(
    name = "main",
    main_class = "examples.greet",  # main_class must match the signature of the @main function in Greetings.scala
    deps = [":greetings"],
)
```

### Greetings.scala
```scala
// Greetings.scala

package examples

@main
def greet: Unit =
  println(s"Hello from Scala Native!")
```

## Next Steps

→ [02-binary-with-dep](../02-binary-with-dep/): Linking binaries with external dependencies.
