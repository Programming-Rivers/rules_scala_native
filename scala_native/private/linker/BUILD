load("@rules_scala//scala:scala.bzl", "scala_binary")

# A single native_linker target that uses the alias (unsuffixed) repos.
scala_binary(
    name = "native_linker",
    srcs = ["NativeLinker.scala"],
    main_class = "scala.scalanative.bazel.NativeLinker",
    deps = [
        "@org_scala_native_tools//jar",
        "@org_scala_native_nativelib//jar",
        "@org_scala_native_javalib//jar",
        "@org_scala_native_scalalib//jar",
        "@org_scala_native_auxlib//jar",
        "@org_scala_native_util//jar",
        "@org_scala_native_nir//jar",
    ],
    visibility = ["//visibility:public"],
)
