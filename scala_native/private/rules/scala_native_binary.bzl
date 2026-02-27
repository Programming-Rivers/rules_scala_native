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


    c_compile_variables = cc_common.create_compile_variables(
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        user_compile_flags = ctx.fragments.cpp.copts + ctx.fragments.cpp.conlyopts,
    )
    c_compile_options = cc_common.get_memory_inefficient_command_line(
        feature_configuration = feature_configuration,
        action_name = "c-compile",
        variables = c_compile_variables,
    )

    target_triple = getattr(scala_native_toolchain, "target_triple", "")
    if not target_triple:
        target_triple = _get_target_triple(cc_toolchain, c_compile_options)
    
    _validate_target(target_triple)

    # Extract C++ compile options (may include additional include paths for C++ headers like <exception>)
    cpp_compile_variables = cc_common.create_compile_variables(
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        user_compile_flags = ctx.fragments.cpp.copts + ctx.fragments.cpp.cxxopts,
    )
    cpp_compile_options = cc_common.get_memory_inefficient_command_line(
        feature_configuration = feature_configuration,
        action_name = "c++-compile",
        variables = cpp_compile_variables,
    )
    # Compute extra C++ options that are not already in the C compile options,
    # being careful to preserve paired arguments like -isystem <path>.
    c_opts_set = {opt: True for opt in c_compile_options}
    extra_cpp_options = []
    skip_next = False
    for i in range(len(cpp_compile_options)):
        if skip_next:
            skip_next = False
            continue
        opt = cpp_compile_options[i]
        if opt in ("-isystem", "-I", "-iquote") and i + 1 < len(cpp_compile_options):
            val = cpp_compile_options[i+1]
            if val not in c_opts_set:
                extra_cpp_options.extend([opt, val])
            skip_next = True
        else:
            if opt not in c_opts_set:
                extra_cpp_options.append(opt)

    link_variables = cc_common.create_link_variables(
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        is_linking_dynamic_library = False,
    )
    link_options = cc_common.get_memory_inefficient_command_line(
        feature_configuration = feature_configuration,
        action_name = "c++-link-executable",
        variables = link_variables,
    )

    # Collect native lib jars and user deps using java_common.merge
    all_java_deps = [
        scala_native_toolchain.nativelib,
        scala_native_toolchain.javalib,
        scala_native_toolchain.auxlib,
        scala_native_toolchain.scalalib,
    ] + ctx.attr.deps

    # Include windowslib when cross-compiling to Windows
    if target_triple and "windows" in target_triple and scala_native_toolchain.windowslib:
        all_java_deps = all_java_deps + [scala_native_toolchain.windowslib]
    
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
    if target_triple:
        args.add("--target_triple", target_triple)
    # Flatten the classpath elements into a single string with the path separator
    args.add_joined("--cp", classpath, join_with=ctx.configuration.host_path_separator)
    for opt in c_compile_options:
        args.add("--compile_option", opt)
    for opt in extra_cpp_options:
        args.add("--cpp_option", opt)
    for opt in link_options:
        args.add("--linking_option", opt)

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
            
    # Platform-specific link flags: POSIX systems need pthread, dl, m;
    # Windows (MinGW) does not, but needs dbghelp, userenv, etc.
    if target_triple and "windows" in target_triple:
        platform_link_flags = ["-luserenv", "-ldbghelp", "-lws2_32", "-lbcrypt", "-lcrypt32"]
    else:
        platform_link_flags = ["-pthread", "-ldl", "-lm"]

    linking_outputs = cc_common.link(
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        name = ctx.label.name,
        linking_contexts = [linking_context] + user_linking_contexts,
        user_link_flags = platform_link_flags,
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

# Map CC toolchain target_cpu values to LLVM target triples.
# The CC toolchain's target_cpu reflects the platform constraint values.
# Note: llvm uses "win64" for Windows x86_64.
_TARGET_CPU_TO_TRIPLE = {
    # Linux
    "k8": None,  # Native x86_64 Linux — no cross-compilation needed
    "aarch64": "aarch64-unknown-linux-gnu",
    # macOS
    "darwin_x86_64": "x86_64-apple-darwin",
    "darwin_arm64": "aarch64-apple-darwin",
    "darwin": "aarch64-apple-darwin",
    # Windows (MinGW) — llvm uses "win64"
    "x64_windows": "x86_64-w64-windows-gnu",
    "win64": "x86_64-w64-windows-gnu",
    "aarch64_windows": "aarch64-w64-windows-gnu",
}

_UNSUPPORTED_TARGET_PATTERNS = ["wasm32", "wasm64"]

def _validate_target(target_triple):
    """Fail fast for platforms Scala Native cannot target."""
    if target_triple:
        for pattern in _UNSUPPORTED_TARGET_PATTERNS:
            if pattern in target_triple:
                fail(
                    "Scala Native does not support target '{}'. ".format(target_triple) +
                    "Supported targets: Linux (x86_64, aarch64), macOS (x86_64, aarch64), " +
                    "Windows (x86_64, aarch64)."
                )

def _get_target_triple(cc_toolchain, c_compile_options):
    """Derive the LLVM target triple from the CC toolchain's compile options or fallback to CPU map."""
    if hasattr(cc_toolchain, "target_gnu_system_name") and cc_toolchain.target_gnu_system_name:
        return cc_toolchain.target_gnu_system_name

    for i in range(len(c_compile_options)):
        opt = c_compile_options[i]
        if opt == "-target" and i + 1 < len(c_compile_options):
            return c_compile_options[i+1]
        elif opt.startswith("--target="):
            return opt[len("--target="):]

    target_cpu = cc_toolchain.cpu
    return _TARGET_CPU_TO_TRIPLE.get(target_cpu, None)

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

scala_native_internal_test = rule(
    implementation = _scala_native_binary_impl,
    attrs = _scala_native_binary_attrs,
    test = True,
    toolchains = [
        "//scala_native:toolchain_type", 
        "@bazel_tools//tools/cpp:toolchain_type"
    ],
    fragments = ["cpp"],
    cfg = scala_version_transition,
)
