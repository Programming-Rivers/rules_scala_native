# rules_scala_native

Bazel rulesets for building [Scala Native](https://scala-native.org/) applications.

This project provides two main rules:

- **`scala_native_library`** — compiles Scala sources to class files, tasty files, and NIR (Native Intermediate Representation).
- **`scala_native_binary`** — links NIR files into a native executable using a hermetic C++ toolchain (clang/lld).
- **`scala_native_test`** — a test rule for running Scala Native JUnit tests.

## Requirements

- **Bazel 9+** (bzlmod only, no WORKSPACE support)
- **Scala 3.8.1**
- **Scala Native 0.5.10**
- **Linux, macOS** (x86_64, aarch64)

## Quick Start

### 1. Configure `MODULE.bazel`

```python
module(name = "my_scala_native_app")

bazel_dep(name = "protobuf", version = "33.4")
bazel_dep(name = "rules_scala", version = "7.2.2")
bazel_dep(name = "rules_scala_native", version = "0.1.0")
bazel_dep(name = "toolchains_llvm_bootstrapped", version = "0.5.4")

# Register hermetic C++ toolchain (clang/lld) for native linking
register_toolchains(
    "@toolchains_llvm_bootstrapped//toolchain:all",
)

# Configure Scala
scala_config = use_extension(
    "@rules_scala//scala/extensions:config.bzl",
    "scala_config",
)
scala_config.settings(scala_version = "3.8.1")
use_repo(scala_config, "rules_scala_config")

scala_deps = use_extension(
    "@rules_scala//scala/extensions:deps.bzl",
    "scala_deps",
)
scala_deps.scala()
use_repo(scala_deps, "rules_scala_toolchains")

register_toolchains(
    "@rules_scala_toolchains//...:all",
)
```

### 2. Configure `.bazelrc`

```
common --tool_java_runtime_version=remotejdk_17
common --java_runtime_version=remotejdk_17
common --@protobuf//bazel/toolchains:prefer_prebuilt_protoc
```

### 3. Write Scala Native code

```scala
// HelloNative.scala
package examples.native

@main
def sayHello(name: String): Unit =
    println(s"Hello from Scala Native to $name")
```

```scala
// NativeTest.scala
package examples.native

import org.junit.Test
import org.junit.Assert.*

class NativeTest:
  @Test
  def testMath(): Unit =
    assertEquals("Basic arithmetic should work", 4, 2 + 2)
```

### 4. Define build targets

```python
load("@rules_scala_native//scala_native:scala_native_library.bzl", "scala_native_library")
load("@rules_scala_native//scala_native:scala_native_binary.bzl", "scala_native_binary")
load("@rules_scala_native//scala_native:scala_native_test.bzl", "scala_native_test")

scala_native_library(
    name = "hello_native",
    srcs = ["HelloNative.scala"],
)

scala_native_binary(
    name = "hello_native_bin",
    main_class = "examples.native.sayHello",
    deps = [":hello_native"],
)

scala_native_test(
    name = "hello_native_test",
    srcs = ["NativeTest.scala"],
    deps = [":hello_native"],
)
```

### 5. Build and run

```bash
$ bazel run //:hello_native_bin -- "the World!"
```

It should print this output:
```
Hello from Scala Native to the World
Hello from a C function!
```

To run tests:
```bash
$ bazel test //:hello_native_test
```

## Cross-Compilation Support

`rules_scala_native` supports hermetic cross-compilation by bridging Bazel's C++ toolchain infrastructure with the Scala Native linking pipeline. This ensures that target triples, sysroots, and standard library configurations are correctly applied.

### Support Matrix

| Platform    | Architectures  | C Library / Toolchain   | Build        | Execution     |
| :---------- | :------------- | :---------------------- | :----------- | :------------ |
| Linux       | aarch64        | glibc (2.28—2.42), musl | ✅ Succeeded | ❓ Not tested |
| Linux       | x86_64         | glibc (2.28—2.42), musl | ✅ Succeeded | ✅ Succeeded  |
| macOS       | aarch64        | Native Apple SDK        | ✅ Succeeded | ✅ Succeeded  |
| macOS       | x86_64         | Native Apple SDK        | ✅ Succeeded | ❓ Not tested |
| Windows     | aarch64        | -                       | ❌ Failed    | -             |
| Windows     | x86_64         | -                       | ❌ Failed    | -             |
| WebAssembly | wasm32         | -                       | ❌ Failed    | -             |
| WebAssembly | wasm64         | -                       | ❌ Failed    | -             |

> **Note:** Cross-compilation has been verified from a Linux x86_64 host to a total of 72 targets, including multiple architectures and glibc versions 2.28 through 2.42.

## Architecture

### Build Pipeline

```
Scala sources  →  scalac + nscplugin  →  .class + .nir files  →  Scala Native linker  →  native binary
                                                                        ↓
                                                                   clang/lld (hermetic)
```

### Key Components

| Component | Description |
|-----------|-------------|
| `scala_native_toolchain` | Manages Scala Native dependencies (nscplugin, runtime libs, linker) |
| `scala_native_library` macro | Injects the nscplugin compiler plugin for NIR generation |
| `scala_native_test` | Runs Scala Native JUnit tests |
| `NativeLinker` | Bridges the Scala Native build API with Bazel's action graph |

### Dependencies

This project depends on:
- [`rules_scala`](https://github.com/bazel-contrib/rules_scala) — for Scala compilation infrastructure
- [`rules_cc`](https://github.com/bazelbuild/rules_cc) — for C++ toolchain access
- [`toolchains_llvm_bootstrapped`](https://github.com/nicholasgasior/toolchains_llvm_bootstrapped) — for hermetic clang/lld

## Current Limitations

- Only Scala 3.8.1 is supported
- Only Scala Native 0.5.10 is supported
- Windows and WebAssembly support is currently work-in-progress.

## Related

- [rules_scala issue #1409](https://github.com/bazel-contrib/rules_scala/issues/1409) — Support for Scala Native
- [rules_scala PR #1809](https://github.com/bazel-contrib/rules_scala/pull/1809) — Original proof of concept
- [Scala Native](https://scala-native.org/) — Scala Native project

## License

See [LICENSE.txt](LICENSE.txt).
