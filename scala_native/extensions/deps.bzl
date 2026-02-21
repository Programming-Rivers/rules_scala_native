"""Module extension that downloads Scala Native Maven artifacts.

This extension fetches all the Scala Native jars needed by rules_scala_native.
It uses rules_scala's scala_maven_import_external to download the jars from Maven.

Note: Cross-extension deps (e.g. @io_bazel_rules_scala_scala_library) are
omitted from the artifact deps because bzlmod does not allow repo visibility
across extensions. The actual dependency wiring is handled by the toolchain
and the scala_native_library / scala_native_binary rules.
"""

load(
    "@rules_scala//scala:scala_maven_import_external.bzl",
    "scala_maven_import_external",
)
load(
    "@rules_scala//scala:scala_cross_version.bzl",
    "default_maven_server_urls",
)

# Scala Native artifacts by version
#
# Cross-extension deps (those starting with @io_bazel_rules_scala_) are
# stripped because they are created by the separate scala_deps extension
# and are not visible to repos created by this extension under bzlmod.
# Intra-extension deps (those starting with @org_scala_native_) are kept.
_SCALA_NATIVE_ARTIFACTS = {
    "0.5.10": {
        "org_junit_junit": {
            "artifact": "junit:junit:4.12",
            "sha256": "59721f0805e223d84b90677887d9ff567dc534d7c502ca903c0c2b17f05c116a",
            "deps": [],
        },
        "org_scala_native_nscplugin": {
            "artifact": "org.scala-native:nscplugin_3.8.1:0.5.10",
            "sha256": "ebf7273178daf2b0ab3cacedf208fddb935badd806d8df782a00fa1b3cc38395",
            "deps": [],
        },
        "org_scala_native_scalalib": {
            "artifact": "org.scala-native:scalalib_native0.5_3:jar:3.8.1+0.5.10",
            "sha256": "3535281e6ea25df78a9bc6663ed5771c850b65f9e431a4204a576af29afae1cd",
            "deps": [],
        },
        "org_scala_native_nativelib": {
            "artifact": "org.scala-native:nativelib_native0.5_3:0.5.10",
            "sha256": "662a81aabf543ae956dff6257369f673d62571354388be7e490e565c1c42dbb6",
            "deps": [],
        },
        "org_scala_native_nir": {
            "artifact": "org.scala-native:nir_3:0.5.10",
            "sha256": "153d1517b655d3ed2ce6b89db00ac39072c5c119cc8699947675a6110ee2afd2",
            "deps": [
                "@org_scala_native_util",
            ],
        },
        "org_scala_native_clib": {
            "artifact": "org.scala-native:clib_native0.5_3:0.5.10",
            "sha256": "293fd45e8efdeba045dd63fd265e32aa9293fb586e8f101c1f84b9041770234e",
            "deps": [],
        },
        "org_scala_native_posixlib": {
            "artifact": "org.scala-native:posixlib_native0.5_3:0.5.10",
            "sha256": "da77ed163d42acdc251eb92b2f13d61aa8126404d6d7d51fa5b8de88ccec02e9",
            "deps": [],
        },
        "org_scala_native_javalib": {
            "artifact": "org.scala-native:javalib_native0.5_3:0.5.10",
            "sha256": "7510518f65743b0c19534b6328ff97f323f49e4fc7415cdf333a6df9bdd85a6a",
            "deps": [
                "@org_scala_native_clib",
                "@org_scala_native_posixlib",
            ],
        },
        "org_scala_native_auxlib": {
            "artifact": "org.scala-native:auxlib_native0.5_3:0.5.10",
            "sha256": "899f54289317f71de072fd64823e39de16a4451ce6bc93ae33023eb0b762ca6d",
            "deps": [],
        },
        "org_scala_native_tools": {
            "artifact": "org.scala-native:tools_3:0.5.10",
            "sha256": "01f18ceb8e4e315cd765f837a837bec7919a315423265f9012a70b2e7de5ef05",
            "deps": [
                "@org_scala_native_nativelib",
                "@org_scala_native_javalib",
                "@org_scala_native_scalalib",
            ],
        },
        "org_scala_native_util": {
            "artifact": "org.scala-native:util_3:0.5.10",
            "sha256": "74f1071e32cfb1a12bfa49c8ab7ed249a5a1cf94620140c8aaf57840aaf04794",
            "deps": [],
        },
        "org_scala_native_test_interface_sbt_defs": {
            "artifact": "org.scala-native:test-interface-sbt-defs_native0.5_3:0.5.10",
            "sha256": "5575c9022c5fa268adb8ec3d8ae10fd753a3548133a4fdd3bbf1676047057f7b",
            "deps": [],
        },
        "org_scala_native_test_interface": {
            "artifact": "org.scala-native:test-interface_native0.5_3:0.5.10",
            "sha256": "8249c999244c30be1a1c22de2789120d973628421ec97227d16172ee5b35e9a9",
            "deps": [
                "@org_scala_native_nativelib",
                "@org_scala_native_javalib",
                "@org_scala_native_scalalib",
                "@org_scala_native_test_interface_sbt_defs",
            ],
        },
        "org_scala_native_junit_runtime": {
            "artifact": "org.scala-native:junit-runtime_native0.5_3:0.5.10",
            "sha256": "92cbfeb08127a2700d071bfe682e9670af0488ae91c5580538aa04bfdcbcac2b",
            "deps": [
                "@org_scala_native_nativelib",
                "@org_scala_native_javalib",
                "@org_scala_native_scalalib",
                "@org_junit_junit",
                "@org_scala_native_test_interface",
            ],
        },
        "org_scala_native_junit_plugin": {
            "artifact": "org.scala-native:junit-plugin_3.8.1:0.5.10",
            "sha256": "76524f752c64fc2e6e6aa2439e793c2d62fcdeb6398cd0011735ac0fefe06abf",
            "deps": [],
        },
    },
}

_toolchain_tag = tag_class(
    attrs = {
        "scala_native_version": attr.string(
            default = "0.5.10",
            doc = "The version of Scala Native to use. Default is 0.5.10.",
        ),
    },
)

def _scala_native_deps_impl(module_ctx):
    maven_servers = default_maven_server_urls()

    scala_native_version = "0.5.10"
    for mod in module_ctx.modules:
        for toolchain in mod.tags.toolchain:
            # Last one wins for now
            scala_native_version = toolchain.scala_native_version

    if scala_native_version not in _SCALA_NATIVE_ARTIFACTS:
        fail("Unsupported Scala Native version: {}. Supported versions: {}".format(
            scala_native_version,
            _SCALA_NATIVE_ARTIFACTS.keys(),
        ))

    artifacts = _SCALA_NATIVE_ARTIFACTS[scala_native_version]

    for name, artifact_info in artifacts.items():
        scala_maven_import_external(
            name = name,
            artifact = artifact_info["artifact"],
            artifact_sha256 = artifact_info["sha256"],
            licenses = ["notice"],
            server_urls = maven_servers,
            deps = artifact_info.get("deps", []),
            fetch_sources = False,
        )

    return module_ctx.extension_metadata(
        reproducible = True,
    )

scala_native_deps = module_extension(
    implementation = _scala_native_deps_impl,
    tag_classes = {"toolchain": _toolchain_tag},
    doc = """Downloads Scala Native Maven artifacts.

This extension downloads all the Scala Native jars needed by the
rules_scala_native rulesets. The artifacts are parameterized by
the `scala_native_version` tag attribute.
""",
)
