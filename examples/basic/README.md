# Basic Scala Native Examples

This directory contains the most basic, fundamental examples of Scala Native built with Bazel.

## Showcases
- **`hello_native_bin`**: A simple Scala `println` executable that also natively calls a trivial C function (`c_greetings()`). It demonstrates that Scala Native can easily compile Scala source and link an `extern "C"` target within a single Bazel `cc_library` definition without complex build configuration.

### How to Run
```bash
bazel run //basic:hello_native_bin
```
