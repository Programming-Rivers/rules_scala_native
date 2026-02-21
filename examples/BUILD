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
    srcs = ["basic/Greetings.scala"],
)

scala_native_library(
    name = "hello_native",
    srcs = [
        "basic/HelloNative.scala",
    ],
    deps = [
        ":greetings",
    ],
)

scala_native_library(
    name = "intrinsics",
    srcs = [
        "features/Intrinsics.scala",
    ],
)

cc_library(
    name = "c_greetings",
    srcs = ["basic/c_greetings.c"],
)

scala_native_binary(
    name = "hello_native_bin",
    main_class = "examples.native.sayHello",
    deps = [
        ":hello_native",
        ":c_greetings",
    ],
)

cc_library(
    name = "advanced_c_lib",
    srcs = ["interop/c/advanced_c.c"],
)

scala_native_library(
    name = "advanced_c_scala",
    srcs = ["interop/c/AdvancedC.scala"],
)

scala_native_binary(
    name = "advanced_c_bin",
    main_class = "examples.interop.c.advancedCExample",
    deps = [
        ":advanced_c_scala",
        ":advanced_c_lib",
    ],
)

cc_library(
    name = "cpp_greeter_lib",
    srcs = ["interop/cpp/cpp_greeter.cpp"],
)

scala_native_library(
    name = "cpp_interop_scala",
    srcs = ["interop/cpp/CppInterop.scala"],
)

scala_native_binary(
    name = "cpp_interop_bin",
    main_class = "examples.interop.cpp.cppInteropExample",
    deps = [
        ":cpp_interop_scala",
        ":cpp_greeter_lib",
    ],
)
