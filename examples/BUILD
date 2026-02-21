"""
A simple hello world library in Scala Native built with Bazel.
"""
load(
    "@rules_scala_native//scala_native:scala_native_library.bzl",
    "scala_native_library",
)
load(
    "@rules_scala_native//scala_native:scala_native_binary.bzl",
    "scala_native_binary",
)
load(
    "@rules_cc//cc:defs.bzl",
    "cc_library",
)

scala_native_library(
    name = "greetings",
    srcs = ["Greetings.scala"],
)

scala_native_library(
    name = "hello_native",
    srcs = [
        "HelloNative.scala",
    ],
    deps = [
        ":greetings",
    ],
)

scala_native_library(
    name = "intrinsics",
    srcs = [
        "Intrinsics.scala",
    ],
)

cc_library(
    name = "c_greetings",
    srcs = ["c_greetings.c"],
)

scala_native_binary(
    name = "hello_native_bin",
    main_class = "examples.native.sayHello",
    deps = [
        ":hello_native",
        ":c_greetings",
    ],
)
