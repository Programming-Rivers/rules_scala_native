# Zig Interoperability

This directory demonstrates interoperability between Zig and Scala Native inside Bazel.

## Showcases
- **`zig_interop_bin`**: Shows how to call a Zig function from Scala Native using the C-ABI.
- It leverages `rules_zig` to compile Zig source code into a static library, which is then linked into the Scala Native binary.
- Demonstrates handling of C-compatible types across the language boundary.

### How to Run
```bash
bazel run //interop/zig:zig_interop_bin
```
