"""Public API for scala_native_binary rule."""

load(
    "//scala_native/private/rules:scala_native_binary.bzl",
    _scala_native_binary = "scala_native_binary",
)

scala_native_binary = _scala_native_binary
