# Cross-compiling with External C Dependencies

> **Prerequisites:** Familiarity with [Basic Cross-compilation](../01-cross-compile-hello-world/) and [glibc Targeting](../03-cross-compile-with-glibc/)

## Goal

Build a Scala Native application that depends on an external C library (`WiringPi`) and cross-compile it for `linux_aarch64` (Raspberry Pi).

## Description

In real-world applications, you often need to interface with C libraries. When cross-compiling, these dependencies must also be available for the target architecture. 

This example demonstrates how to:
1. Fetch an external C library source using `http_archive`.
2. Define a `cc_library` for the external source.
3. Depend on that `cc_library` from a `scala_native_binary`.
4. Cross-compile the entire project for a different architecture.

We use the [WiringPi](https://github.com/WiringPi/WiringPi) library, commonly used for Raspberry Pi GPIO interaction.

## Build & Run

### For aarch64 (Raspberry Pi):
To cross-compile for a Raspberry Pi running a standard glibc-based Linux:
```bash
$ cd examples/04-cross-compile/04-cross-compile-dependencies
$ bazel build //:main --platforms=@llvm//platforms:linux_aarch64_gnu.2.42
```

### For x86_64:
Even though WiringPi is intended for Raspberry Pi, we can build it for x86_64 for verification:
```bash
$ cd examples/04-cross-compile/04-cross-compile-dependencies
$ bazel build //:main --platforms=@llvm//platforms:linux_x86_64_gnu.2.42
```

We can attempt to run the binary on x86_64 on a linux machine,
but it will fail, as exected, with:
```bash
$ bazel run //:main  --platforms=@llvm//platforms:linux_amd64_gnu.2.42
...
Initializing WiringPi...
Oops: Unable to determine Raspberry Pi board revision from /proc/device-tree/system/linux,revision and from /proc/cpuinfo
...
```

> **Note:** Running the `aarch64` binary requires an actual Raspberry Pi or an emulator.

## Code Highlights

### MODULE.bazel (partial)

We fetch the `WiringPi` source directly from GitHub with the `http_archive` rule.
```python
# ...

# Required to build the WiringPi library with GNU make
bazel_dep(name = "rules_foreign_cc", version = "0.15.1", dev_dependency = True)

http_archive = use_repo_rule(
    "@bazel_tools//tools/build_defs/repo:http.bzl",
    "http_archive",
)

# Instruct Bazel where to find the WiringPi source
http_archive(
    name = "wiringpi",
    build_file = "//third_party:wiringpi.BUILD.bazel",
    sha256 = "c7a06c462372df1650219a10cdd4e8e1da763a41399539ecd1ee1dd4e14e09a8",
    strip_prefix = "WiringPi-3.18",
    urls = ["https://github.com/WiringPi/WiringPi/archive/refs/tags/3.18.tar.gz"],
)

# ...

register_toolchains(
    "@llvm//toolchain:all",
    "@rules_foreign_cc//toolchains:preinstalled_make_toolchain",   # To have access to GNU Make
    "@rules_scala_toolchains//...:all",
)

```

### third_party/wiringpi.BUILD.bazel

Since the external `WiringPi` source doesn't contain a Bazel `BUILD` file, we define one here to tell Bazel how to compile it:

```python
cc_library(
    name = "wiringpi_lib",
    srcs = glob([
        "wiringPi/*.c",
    ], exclude = [
        # These files seem to be stale and have typos
        "wiringPi/drcNet.c",  
        "wiringPi/WiringpiV1.c",
    ]),
    hdrs = ["version.h"] + glob([
        "wiringPi/*.h",
        "wiringPiD/*.h",
    ]),
    includes = ["wiringPi/"],
    copts = ["-D_GNU_SOURCE"],  # required for functions such as `poll` and `ppoll`
    visibility = ["//visibility:public"],
)
```

- **`srcs`**: We use `glob` to include the C source files. Some files are excluded because they are either deprecated or contain errors that prevent compilation in this environment.
- **`includes`**: This tells Bazel to add `wiringPi/` to the include search path, allowing the library and its users to use simple `#include "wiringPi.h"` directives.
- **`copts`**: The `_GNU_SOURCE` macro is required to enable specific GNU/Linux features (like `poll`) used by the library.

### BUILD.bazel

The Scala Native binary simply lists the external C library in its `deps`:

```python
scala_native_binary(
    name = "main",
    main_class = "examples.main",
    deps = [
        "@wiringpi//:wiringpi_lib",
        ":wiringpi_sn",
    ],
)
```

## Key Concepts

- **Source-based Dependencies**: Fetching and building C dependencies from source within Bazel ensures that they are compiled with the same cross-compilation toolchain and flags as your Scala code.
- **rules_foreign_cc**: Used to bridge Bazel with non-Bazel build systems like GNU Make. In this example, it provides access to the `make` toolchain needed for certain build steps.
- **Hermeticity**: By managing C dependencies via Bazel, you avoid relying on "pre-installed" libraries on your build machine or guessing if the target machine has the right version.
- **Toolchain Propagation**: The `@llvm` toolchain automatically handles compiling the C sources for the target platform specified in `--platforms`.
