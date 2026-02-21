"""scala_native_library rule for compiling Scala to NIR.

The nscplugin compiler plugin is injected via the scala_native_library macro,
which appends it to the user-provided `plugins` list. This ensures NIR
generation happens during Scala compilation without requiring upstream changes
to rules_scala.
"""

load(
  "@rules_java//java/common:java_info.bzl",
  "JavaInfo",
)
load(
  "@rules_scala//scala:scala_cross_version.bzl",
  "scala_version_transition",
  "toolchain_transition_attr",
)
load(
    "@rules_scala//scala/private:common_attributes.bzl",
    "common_attrs",
    "implicit_deps",
    "resolve_deps",
)
load(
  "@rules_scala//scala/private:common_outputs.bzl",
  "common_outputs",
)
load(
    "@rules_scala//scala/private:coverage_replacements_provider.bzl",
    _coverage_replacements_provider = "coverage_replacements_provider",
)
load(
    "@rules_scala//scala/private:phases/phases.bzl",
    "extras_phases",
    "phase_collect_exports_jars",
    "phase_collect_srcjars",
    "phase_compile_library",
    "phase_coverage_library",
    "phase_default_info",
    "phase_dependency_common",
    "phase_merge_jars",
    "phase_runfiles_library",
    "phase_scalac_provider",
    "phase_scalacopts",
    "phase_scalainfo_provider_non_macro",
    "phase_write_manifest",
    "run_phases",
)
load(
    "@rules_scala//scala/private:common.bzl",
    "collect_jars",
)
load(
  "//scala_native:providers.bzl",
  "ScalaNativeInfo",
)

def phase_collect_jars_native(ctx, p):
    """Collect jars phase for Scala Native library.
    
    This phase adds Scala Native runtime libraries to the compilation classpath.
    """
    # Get the Scala Native toolchain
    scala_native_toolchain = ctx.toolchains["//scala_native:toolchain_type"]
    
    # Build the list of dependencies including Scala Native runtime libraries from toolchain
    all_deps = ctx.attr.deps + [
        scala_native_toolchain.nativelib,
        scala_native_toolchain.javalib,
        scala_native_toolchain.auxlib,
    ] + p.scalac_provider.default_classpath
    
    deps_jars = collect_jars(
        all_deps,
        p.dependency.dependency_mode,
        p.dependency.need_direct_info,
        p.dependency.need_indirect_info,
    )
    
    # Collect runtime jars
    transitive_runtime_jars = [dep_target[JavaInfo].transitive_runtime_jars 
                                for dep_target in ctx.attr.runtime_deps]
    
    transitive_rjars = depset(
        transitive = [deps_jars.transitive_runtime_jars] + transitive_runtime_jars,
    )
    
    return struct(
        compile_jars = deps_jars.compile_jars,
        jars2labels = deps_jars.jars2labels,
        transitive_compile_jars = deps_jars.transitive_compile_jars,
        transitive_runtime_jars = transitive_rjars,
        deps_providers = deps_jars.deps_providers,
        external_providers = {"JarsToLabelsInfo": deps_jars.jars2labels},
    )



def _scala_native_library_impl(ctx):
    """Implementation of scala_native_library rule.

    The nscplugin is included in ctx.attr.plugins by the macro wrapper,
    so phase_compile picks it up automatically from the plugins attribute.
    """
    return run_phases(
        ctx,
        [
            ("scalac_provider", phase_scalac_provider),
            ("scalainfo_provider", phase_scalainfo_provider_non_macro),
            ("collect_srcjars", phase_collect_srcjars),
            ("write_manifest", phase_write_manifest),
            ("dependency", phase_dependency_common),
            ("collect_jars", phase_collect_jars_native),
            ("scalacopts", phase_scalacopts),
            ("compile", phase_compile_library),
            ("coverage", phase_coverage_library),
            ("merge_jars", phase_merge_jars),
            ("runfiles", phase_runfiles_library),
            ("collect_exports_jars", phase_collect_exports_jars),
            ("scala_native_info", _phase_scala_native_info),
            ("default_info", phase_default_info),
        ],
    )

def _phase_scala_native_info(ctx, p):
    """Phase that produces ScalaNativeInfo provider."""
    
    # The output JAR contains both .class and .nir files
    # Collect transitive NIR jars from dependencies
    transitive_nirs = [dep[ScalaNativeInfo].transitive_nir_jars for dep in ctx.attr.deps if ScalaNativeInfo in dep]

    
    return struct(
        external_providers = {
            "ScalaNativeInfo": ScalaNativeInfo(
                nir_jar = ctx.outputs.jar,
                transitive_nir_jars = depset(
                    direct = [ctx.outputs.jar],
                    transitive = transitive_nirs,
                ),
            )
        },
    )

_scala_native_library_attrs = {}

_scala_native_library_attrs.update(implicit_deps)

_scala_native_library_attrs.update({
    "build_ijar": attr.bool(default = False),
})

_scala_native_library_attrs.update(common_attrs)

_scala_native_library_attrs.update({
    "main_class": attr.string(),
    "exports": attr.label_list(
        allow_files = False,
        aspects = [_coverage_replacements_provider.aspect],
    ),
})

_scala_native_library_attrs.update(resolve_deps)

_scala_native_library_attrs.update(toolchain_transition_attr)

_scala_native_library_attrs.update(extras_phases([]))



_scala_native_base_library = rule(
    attrs = _scala_native_library_attrs,
    fragments = ["java"],
    outputs = common_outputs,
    toolchains = [
        "@rules_scala//scala:toolchain_type",
        "//scala_native:toolchain_type",
        "@bazel_tools//tools/jdk:toolchain_type",
    ],
    cfg = scala_version_transition,
    provides = [JavaInfo, ScalaNativeInfo],
    implementation = _scala_native_library_impl,
)

def scala_native_library(name, plugins = [], **kwargs):
    """Compiles Scala sources to class files, tasty files, and NIR.

    This macro wraps the underlying rule and ensures the nscplugin compiler
    plugin is always included for NIR generation via the default plugins attr.

    Args:
        name: Target name.
        plugins: Additional Scala compiler plugins. The nscplugin is always
            included automatically.
        **kwargs: All other arguments are passed to the underlying rule.
    """
    _scala_native_base_library(
        name = name,
        plugins = plugins + [Label("@org_scala_native_nscplugin//jar")],
        **kwargs
    )
