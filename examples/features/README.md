# Scala Native Power Features

This directory goes beyond simple printing to showcase the unique systems-programming features of Scala Native itself.

## Showcases

- **`zone_alloc_bin`**: Demonstrates safe, automatic unmanaged memory management using **Zone Allocation** (`Zone { implicit z => ... }`), which cleanly abstracts away `malloc`/`free` lifetimes while providing deterministic performance.
- **`struct_bin`**: Shows how to define C-binary-compatible structs (`CStruct3`) purely in Scala source code (`Struct.scala`). It requires no bridging header files, showcasing Scala Native's deep awareness of native memory layouts.
- **`posix_bin`**: Proves direct, no-overhead access into underlying POSIX operating system structures. It utilizes `@extern` to connect to `unistd` (calling `getpid` and `getcwd`) directly from Scala context without Java JNI intermediaries.

### How to Run
```bash
bazel run //features:zone_alloc_bin
bazel run //features:struct_bin
bazel run //features:posix_bin
```
