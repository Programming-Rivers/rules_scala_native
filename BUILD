# Root BUILD file for rules_scala_native

filegroup(
    name = "local_repository_files",
    srcs = glob(
        ["**"],
        exclude = [
            "**/bazel-*/**",
            "**/.git/**",
        ],
    ) + [
        "//scala_native:all_files",
        "//scala_native/private:all_files",
        "//scala_native/private/linker:all_files",
        "//scala_native/private/rules:all_files",
        "//scala_native/extensions:all_files",
    ],
    visibility = ["//visibility:public"],
)
