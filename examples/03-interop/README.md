# Interoperability with Other Languages

## Goal

Learn how to interface with other programming languages using Foreign Function Interfaces (FFI).

## Description

Scala Native provides a C-compatible ABI, which allows you to seamlessly integrate your Scala code with other programming languages, such as C, C++, Rust, and Zig.

In this section we will see how to create libraries in C, C++, Rust, and Zig and use them in Scala Native.
Bazel makes this process simple and straightforward by providing rules for creating libraries in different languages and using them in other languages.
