# Rust Interoperability

This directory demonstrates interoperability between Rust and Scala Native inside Bazel.

## Showcases
- **`rust_interop_bin`**: Shows how to call a Rust function from Scala Native using the C-ABI.
- It leverages `rules_rust` to compile Rust source code into a static library (`rust_static_library`), which is then linked into the Scala Native binary.
- Demonstrates handling of C-compatible types across the language boundary.

### How to Run
```bash
bazel run //interop/rust:rust_interop_bin
```
