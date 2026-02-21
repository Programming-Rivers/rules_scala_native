# C++ Interoperability

This directory demonstrates integrating C++ code with Scala Native via Bazel's `cc_library` and an `extern "C"` wrapper pattern.

## Showcases
- **`cpp_interop_bin`**: Scala Native natively expects the C ABI. By providing a thin C wrapper around a C++ class instance (`cpp_greeter.cpp`), we prove that the `rules_scala_native` LLVM toolchain integration perfectly links C++ standard libraries (`libc++` / `libstdc++`) to the final Scala Native executable.
- The Scala Native code securely creates, uses, and deletes a dynamically allocated C++ object.

### How to Run
```bash
bazel run //interop/cpp:cpp_interop_bin
```
