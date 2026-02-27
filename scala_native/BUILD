package(default_visibility = ["//visibility:public"])

exports_files(["*.bzl"])

# Scala Native toolchain type
toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

load(":scala_native_toolchain.bzl", "scala_native_toolchain")

scala_native_toolchain(
    name = "default_scala_native_toolchain",
    nscplugin = "@org_scala_native_nscplugin//jar",
    scalalib = "@org_scala_native_scalalib//jar",
    nativelib = "@org_scala_native_nativelib//jar",
    javalib = "@org_scala_native_javalib//jar",
    auxlib = "@org_scala_native_auxlib//jar",
    linker = "@org_scala_native_tools//jar",
    linker_binary = "//scala_native/private/linker:native_linker",
    test_interface = "@org_scala_native_test_interface//jar",
    junit_runtime = "@org_scala_native_junit_runtime//jar",
    windowslib = "@org_scala_native_windowslib//jar",
    scala_native_version = "0.5.10",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "scala_native_toolchain",
    toolchain = ":default_scala_native_toolchain",
    toolchain_type = ":toolchain_type",
    visibility = ["//visibility:public"],
)

filegroup(
    name = "all_files",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)
