load("@bazel_tools//tools/cpp:toolchain_utils.bzl",
  "find_cpp_toolchain",
)
load(
    "@rules_cc//cc:defs.bzl",
    "cc_common",
    "CcInfo",
)
load(
  "@rules_java//java/common:java_info.bzl",
  "JavaInfo",
)
load(
    "@rules_java//java/common:java_common.bzl",
    "java_common",
)

load(
    "@rules_scala//scala:scala_cross_version.bzl",
    "scala_version_transition",
    "toolchain_transition_attr",
)
load(
    "//scala_native:providers.bzl",
    "ScalaNativeInfo",
)

def _scala_native_binary_impl(ctx):
    # Get the Scala Native toolchain
    scala_native_toolchain = ctx.toolchains["//scala_native:toolchain_type"]
    
    # Get C++ toolchain for hermetic clang
    cc_toolchain = find_cpp_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )
    clang_path = cc_common.get_tool_for_action(
        feature_configuration = feature_configuration,
        action_name = "c-compile",
    )
    clang_pp_path = cc_common.get_tool_for_action(
        feature_configuration = feature_configuration,
        action_name = "c++-compile",
    )

    # Collect native lib jars and user deps using java_common.merge
    all_java_deps = [
        scala_native_toolchain.nativelib,
        scala_native_toolchain.javalib,
        scala_native_toolchain.auxlib,
        scala_native_toolchain.scalalib,
    ] + ctx.attr.deps
    
    java_infos = [dep[JavaInfo] for dep in all_java_deps if JavaInfo in dep]
    merged_java_info = java_common.merge(java_infos)
    classpath = merged_java_info.transitive_runtime_jars

    
    main_class = ctx.attr.main_class
    module_name = ctx.label.name
    
    native_lib = ctx.actions.declare_file("lib" + ctx.label.name + ".a")
    output_dir = native_lib.dirname
    
    worker = scala_native_toolchain.linker_binary[DefaultInfo].files_to_run
    
    # Arguments
    args = ctx.actions.args()
    args.add("--main", main_class)
    args.add("--outpath", native_lib)
    args.add("--output", output_dir)
    args.add("--module_name", module_name)
    args.add("--workdir", output_dir + "/_native_work")
    args.add("--clang", clang_path)
    args.add("--clang++", clang_pp_path)
    args.add("--build_target", "libraryStatic")
    args.add("--gc", ctx.attr.gc)
    args.add("--mode", ctx.attr.mode)
    args.add("--lto", ctx.attr.lto)
    # Flatten the classpath elements into a single string with the path separator
    args.add_joined("--cp", classpath, join_with=ctx.configuration.host_path_separator)

    ctx.actions.run(
        outputs = [native_lib],
        inputs = depset(transitive = [
            scala_native_toolchain.linker_binary[DefaultInfo].files,
            classpath,
            cc_toolchain.all_files,
        ]),
        executable = worker, 
        arguments = [args],
        mnemonic = "ScalaNativeLink",
        progress_message = "Generating native objects for %s" % module_name,
        toolchain = "//scala_native:toolchain_type",
        env = {
            "PATH": clang_path.rpartition("/")[0] + ":/usr/bin:/bin",
        },
    )
    
    # Now use cc_common.link to produce the final executable
    library_to_link = cc_common.create_library_to_link(
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        static_library = native_lib,
    )
    linker_input = cc_common.create_linker_input(
        owner = ctx.label,
        libraries = depset([library_to_link]),
    )
    linking_context = cc_common.create_linking_context(
        linker_inputs = depset([linker_input]),
    )
    
    user_linking_contexts = []
    for dep in ctx.attr.deps:
        if CcInfo in dep:
            user_linking_contexts.append(dep[CcInfo].linking_context)
            
    linking_outputs = cc_common.link(
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        name = ctx.label.name,
        linking_contexts = [linking_context] + user_linking_contexts,
        user_link_flags = ["-pthread", "-ldl", "-lm"],
    )

    output_executable = linking_outputs.executable
    
    return [
        DefaultInfo(
            executable = output_executable,
            files = depset([output_executable]),
        )
    ]

_scala_native_binary_attrs = {
    "main_class": attr.string(mandatory = True),
    "deps": attr.label_list(),
    "gc": attr.string(
        default = "immix",
        values = ["immix", "commix", "boehm", "none"],
        doc = "Garbage collector to use. Default: immix.",
    ),
    "mode": attr.string(
        default = "debug",
        values = ["debug", "releaseFast", "releaseFull", "releaseSize"],
        doc = "Build mode. Default: debug.",
    ),
    "lto": attr.string(
        default = "none",
        values = ["none", "thin", "full"],
        doc = "Link-Time Optimization mode. Default: none.",
    ),
    "_cc_toolchain": attr.label(
        default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
    ),
}

_scala_native_binary_attrs.update(toolchain_transition_attr)

scala_native_binary = rule(
    implementation = _scala_native_binary_impl,
    attrs = _scala_native_binary_attrs,
    executable = True,
    toolchains = [
        "//scala_native:toolchain_type", 
        "@bazel_tools//tools/cpp:toolchain_type"
    ],
    fragments = ["cpp"],
    cfg = scala_version_transition,
)
