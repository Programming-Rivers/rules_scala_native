# 05-intrinsics

## Goal

Learn about low-level operations and intrinsics that Scala Native provides access to.

## Build & Run

```bash
bazel run //:main
```

## Key Concepts

- **Unsigned Types**: Scala Native provides `UByte`, `UShort`, `UInt`, and `ULong` which map directly to unsigned machine types.
- **Performance**: High-performance operations that might not be available or efficient on a standard JVM.

## Next Steps

→ [03-interop/01-c-basic](../../03-interop/01-c-basic/): Calling into C code.
