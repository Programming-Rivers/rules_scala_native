"""Analysis tests for the ScalaNativeInfo provider.

These tests use bazel_skylib's analysistest framework to verify that
ScalaNativeInfo is correctly structured. Because scala_native_library
requires the full Scala Native toolchain, we use a lightweight stub
rule that returns ScalaNativeInfo with controlled values.
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "analysistest")
load("//scala_native:providers.bzl", "ScalaNativeInfo")

# ===========================================================================
# Stub rule that returns ScalaNativeInfo — no toolchain needed
# ===========================================================================

def _nir_stub_impl(ctx):
    """Stub rule that returns a predictable ScalaNativeInfo for testing."""
    nir_jar = ctx.actions.declare_file(ctx.label.name + ".jar")
    ctx.actions.write(nir_jar, "fake nir content")

    dep_nir_jars = []
    for dep in ctx.attr.deps:
        if ScalaNativeInfo in dep:
            dep_nir_jars.append(dep[ScalaNativeInfo].transitive_nir_jars)

    return [
        DefaultInfo(files = depset([nir_jar])),
        ScalaNativeInfo(
            nir_jar = nir_jar,
            transitive_nir_jars = depset(
                direct = [nir_jar],
                transitive = dep_nir_jars,
            ),
        ),
    ]

_nir_stub = rule(
    implementation = _nir_stub_impl,
    attrs = {
        "deps": attr.label_list(providers = [ScalaNativeInfo]),
    },
)

# ===========================================================================
# Test: ScalaNativeInfo has nir_jar field
# ===========================================================================

def _provider_has_nir_jar_test_impl(ctx):
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    asserts.true(
        env,
        ScalaNativeInfo in target,
        "Expected target to provide ScalaNativeInfo",
    )

    info = target[ScalaNativeInfo]
    asserts.true(
        env,
        info.nir_jar != None,
        "Expected ScalaNativeInfo.nir_jar to be set (non-None)",
    )
    asserts.true(
        env,
        info.nir_jar.basename.endswith(".jar"),
        "Expected nir_jar to be a .jar file, got: " + info.nir_jar.basename,
    )
    return analysistest.end(env)

_provider_has_nir_jar_test = analysistest.make(
    _provider_has_nir_jar_test_impl,
)

def _test_provider_has_nir_jar():
    _nir_stub(name = "nir_jar_subject", tags = ["manual"])
    _provider_has_nir_jar_test(
        name = "provider_has_nir_jar_test",
        target_under_test = ":nir_jar_subject",
    )

# ===========================================================================
# Test: ScalaNativeInfo has transitive_nir_jars as a depset
# ===========================================================================

def _provider_has_transitive_nir_jars_test_impl(ctx):
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    info = target[ScalaNativeInfo]

    # transitive_nir_jars must be a depset (has .to_list())
    jars_list = info.transitive_nir_jars.to_list()
    asserts.true(
        env,
        len(jars_list) > 0,
        "Expected transitive_nir_jars to be non-empty",
    )
    for jar in jars_list:
        asserts.true(
            env,
            jar.basename.endswith(".jar"),
            "Expected all transitive NIR jars to be .jar files, got: " + jar.basename,
        )
    return analysistest.end(env)

_provider_has_transitive_nir_jars_test = analysistest.make(
    _provider_has_transitive_nir_jars_test_impl,
)

def _test_provider_has_transitive_nir_jars():
    _nir_stub(name = "transitive_nir_subject", tags = ["manual"])
    _provider_has_transitive_nir_jars_test(
        name = "provider_has_transitive_nir_jars_test",
        target_under_test = ":transitive_nir_subject",
    )

# ===========================================================================
# Test: ScalaNativeInfo.nir_jar is included in transitive_nir_jars
# ===========================================================================

def _nir_jar_in_transitive_set_test_impl(ctx):
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    info = target[ScalaNativeInfo]
    jar_basenames = [j.basename for j in info.transitive_nir_jars.to_list()]

    asserts.true(
        env,
        info.nir_jar.basename in jar_basenames,
        "Expected nir_jar '{}' to appear in transitive_nir_jars: {}".format(
            info.nir_jar.basename,
            jar_basenames,
        ),
    )
    return analysistest.end(env)

_nir_jar_in_transitive_set_test = analysistest.make(
    _nir_jar_in_transitive_set_test_impl,
)

def _test_nir_jar_in_transitive_set():
    _nir_stub(name = "nir_in_transitive_subject", tags = ["manual"])
    _nir_jar_in_transitive_set_test(
        name = "nir_jar_in_transitive_set_test",
        target_under_test = ":nir_in_transitive_subject",
    )

# ===========================================================================
# Test: transitive_nir_jars accumulates jars from deps
# ===========================================================================

def _transitive_nir_accumulation_test_impl(ctx):
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    info = target[ScalaNativeInfo]
    jar_basenames = [j.basename for j in info.transitive_nir_jars.to_list()]

    # The parent has its own jar plus the dep's jar → at least 2 jars
    asserts.true(
        env,
        len(jar_basenames) >= 2,
        "Expected transitive NIR jars to include jars from deps, got: {}".format(jar_basenames),
    )
    return analysistest.end(env)

_transitive_nir_accumulation_test = analysistest.make(
    _transitive_nir_accumulation_test_impl,
)

def _test_transitive_nir_accumulation():
    _nir_stub(name = "nir_dep_lib", tags = ["manual"])
    _nir_stub(
        name = "nir_transitive_parent",
        deps = [":nir_dep_lib"],
        tags = ["manual"],
    )
    _transitive_nir_accumulation_test(
        name = "transitive_nir_accumulation_test",
        target_under_test = ":nir_transitive_parent",
    )

# ===========================================================================
# Test suite entry point
# ===========================================================================

def providers_test_suite(name):
    """Declares all provider analysis tests and wraps them in a test_suite."""
    _test_provider_has_nir_jar()
    _test_provider_has_transitive_nir_jars()
    _test_nir_jar_in_transitive_set()
    _test_transitive_nir_accumulation()

    native.test_suite(
        name = name,
        tests = [
            ":provider_has_nir_jar_test",
            ":provider_has_transitive_nir_jars_test",
            ":nir_jar_in_transitive_set_test",
            ":transitive_nir_accumulation_test",
        ],
    )
