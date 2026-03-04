"""Unit tests for target triple helper functions.

Tests the pure helper functions in target_triple.bzl using
bazel_skylib's unittest framework (no rule context needed).
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load(
    "//scala_native/private/rules:target_triple.bzl",
    "TARGET_CPU_TO_TRIPLE",
    "get_linking_path",
    "get_platform_link_flags",
    "get_target_triple_from_cpu",
    "get_target_triple_from_options",
    "validate_target_triple",
)

# ===========================================================================
# Tests for get_target_triple_from_options
# ===========================================================================

def _target_from_options_dash_target_test_impl(ctx):
    env = unittest.begin(ctx)
    result = get_target_triple_from_options([
        "-O2",
        "-target",
        "x86_64-linux-gnu",
        "-fPIC",
    ])
    asserts.equals(env, "x86_64-linux-gnu", result)
    return unittest.end(env)

_target_from_options_dash_target_test = unittest.make(
    _target_from_options_dash_target_test_impl,
)

def _target_from_options_double_dash_equals_test_impl(ctx):
    env = unittest.begin(ctx)
    result = get_target_triple_from_options([
        "-O2",
        "--target=aarch64-apple-darwin",
        "-fPIC",
    ])
    asserts.equals(env, "aarch64-apple-darwin", result)
    return unittest.end(env)

_target_from_options_double_dash_equals_test = unittest.make(
    _target_from_options_double_dash_equals_test_impl,
)

def _target_from_options_not_present_test_impl(ctx):
    env = unittest.begin(ctx)
    result = get_target_triple_from_options(["-O2", "-fPIC", "-Wall"])
    asserts.equals(env, None, result)
    return unittest.end(env)

_target_from_options_not_present_test = unittest.make(
    _target_from_options_not_present_test_impl,
)

def _target_from_options_empty_list_test_impl(ctx):
    env = unittest.begin(ctx)
    result = get_target_triple_from_options([])
    asserts.equals(env, None, result)
    return unittest.end(env)

_target_from_options_empty_list_test = unittest.make(
    _target_from_options_empty_list_test_impl,
)

def _target_from_options_dangling_target_flag_test_impl(ctx):
    env = unittest.begin(ctx)
    # -target at end of list with no following value should return None
    result = get_target_triple_from_options(["-O2", "-target"])
    asserts.equals(env, None, result)
    return unittest.end(env)

_target_from_options_dangling_target_flag_test = unittest.make(
    _target_from_options_dangling_target_flag_test_impl,
)

# ===========================================================================
# Tests for get_target_triple_from_cpu
# ===========================================================================

def _cpu_to_triple_native_linux_test_impl(ctx):
    env = unittest.begin(ctx)
    # k8 = native x86_64 Linux, no cross-compilation triple needed
    result = get_target_triple_from_cpu("k8")
    asserts.equals(env, None, result)
    return unittest.end(env)

_cpu_to_triple_native_linux_test = unittest.make(
    _cpu_to_triple_native_linux_test_impl,
)

def _cpu_to_triple_linux_aarch64_test_impl(ctx):
    env = unittest.begin(ctx)
    result = get_target_triple_from_cpu("aarch64")
    asserts.equals(env, "aarch64-unknown-linux-gnu", result)
    return unittest.end(env)

_cpu_to_triple_linux_aarch64_test = unittest.make(
    _cpu_to_triple_linux_aarch64_test_impl,
)

def _cpu_to_triple_darwin_arm64_test_impl(ctx):
    env = unittest.begin(ctx)
    result = get_target_triple_from_cpu("darwin_arm64")
    asserts.equals(env, "aarch64-apple-darwin", result)
    return unittest.end(env)

_cpu_to_triple_darwin_arm64_test = unittest.make(
    _cpu_to_triple_darwin_arm64_test_impl,
)

def _cpu_to_triple_darwin_x86_64_test_impl(ctx):
    env = unittest.begin(ctx)
    result = get_target_triple_from_cpu("darwin_x86_64")
    asserts.equals(env, "x86_64-apple-darwin", result)
    return unittest.end(env)

_cpu_to_triple_darwin_x86_64_test = unittest.make(
    _cpu_to_triple_darwin_x86_64_test_impl,
)

def _cpu_to_triple_windows_x64_test_impl(ctx):
    env = unittest.begin(ctx)
    result = get_target_triple_from_cpu("x64_windows")
    asserts.equals(env, "x86_64-w64-windows-gnu", result)
    return unittest.end(env)

_cpu_to_triple_windows_x64_test = unittest.make(
    _cpu_to_triple_windows_x64_test_impl,
)

def _cpu_to_triple_windows_win64_test_impl(ctx):
    env = unittest.begin(ctx)
    result = get_target_triple_from_cpu("win64")
    asserts.equals(env, "x86_64-w64-windows-gnu", result)
    return unittest.end(env)

_cpu_to_triple_windows_win64_test = unittest.make(
    _cpu_to_triple_windows_win64_test_impl,
)

def _cpu_to_triple_windows_aarch64_test_impl(ctx):
    env = unittest.begin(ctx)
    result = get_target_triple_from_cpu("aarch64_windows")
    asserts.equals(env, "aarch64-w64-windows-gnu", result)
    return unittest.end(env)

_cpu_to_triple_windows_aarch64_test = unittest.make(
    _cpu_to_triple_windows_aarch64_test_impl,
)

def _cpu_to_triple_unknown_returns_none_test_impl(ctx):
    env = unittest.begin(ctx)
    result = get_target_triple_from_cpu("some_unknown_cpu")
    asserts.equals(env, None, result)
    return unittest.end(env)

_cpu_to_triple_unknown_returns_none_test = unittest.make(
    _cpu_to_triple_unknown_returns_none_test_impl,
)

# ===========================================================================
# Tests for TARGET_CPU_TO_TRIPLE map completeness
# ===========================================================================

def _cpu_map_contains_expected_keys_test_impl(ctx):
    env = unittest.begin(ctx)
    expected_keys = [
        "k8",
        "aarch64",
        "darwin_x86_64",
        "darwin_arm64",
        "darwin",
        "x64_windows",
        "win64",
        "aarch64_windows",
    ]
    for key in expected_keys:
        asserts.true(
            env,
            key in TARGET_CPU_TO_TRIPLE,
            "Expected key '{}' to be in TARGET_CPU_TO_TRIPLE".format(key),
        )
    return unittest.end(env)

_cpu_map_contains_expected_keys_test = unittest.make(
    _cpu_map_contains_expected_keys_test_impl,
)

# ===========================================================================
# Tests for validate_target_triple (non-failing cases)
# ===========================================================================

def _validate_target_empty_string_ok_test_impl(ctx):
    env = unittest.begin(ctx)
    # Should not fail — empty string means native target
    validate_target_triple("")
    asserts.true(env, True, "validate_target_triple(\"\") should not fail")
    return unittest.end(env)

_validate_target_empty_string_ok_test = unittest.make(
    _validate_target_empty_string_ok_test_impl,
)

def _validate_target_none_ok_test_impl(ctx):
    env = unittest.begin(ctx)
    # Should not fail — None means native target
    validate_target_triple(None)
    asserts.true(env, True, "validate_target_triple(None) should not fail")
    return unittest.end(env)

_validate_target_none_ok_test = unittest.make(
    _validate_target_none_ok_test_impl,
)

def _validate_target_linux_ok_test_impl(ctx):
    env = unittest.begin(ctx)
    validate_target_triple("x86_64-unknown-linux-gnu")
    asserts.true(env, True, "Linux triple should be valid")
    return unittest.end(env)

_validate_target_linux_ok_test = unittest.make(
    _validate_target_linux_ok_test_impl,
)

def _validate_target_darwin_ok_test_impl(ctx):
    env = unittest.begin(ctx)
    validate_target_triple("aarch64-apple-darwin")
    asserts.true(env, True, "Darwin triple should be valid")
    return unittest.end(env)

_validate_target_darwin_ok_test = unittest.make(
    _validate_target_darwin_ok_test_impl,
)

def _validate_target_windows_ok_test_impl(ctx):
    env = unittest.begin(ctx)
    validate_target_triple("x86_64-w64-windows-gnu")
    asserts.true(env, True, "Windows triple should be valid")
    return unittest.end(env)

_validate_target_windows_ok_test = unittest.make(
    _validate_target_windows_ok_test_impl,
)

# ===========================================================================
# Tests for get_platform_link_flags
# ===========================================================================

def _platform_flags_linux_test_impl(ctx):
    env = unittest.begin(ctx)
    flags = get_platform_link_flags("x86_64-unknown-linux-gnu")
    asserts.equals(env, ["-pthread", "-ldl", "-lm"], flags)
    return unittest.end(env)

_platform_flags_linux_test = unittest.make(
    _platform_flags_linux_test_impl,
)

def _platform_flags_darwin_test_impl(ctx):
    env = unittest.begin(ctx)
    flags = get_platform_link_flags("aarch64-apple-darwin")
    asserts.equals(env, ["-pthread", "-ldl", "-lm"], flags)
    return unittest.end(env)

_platform_flags_darwin_test = unittest.make(
    _platform_flags_darwin_test_impl,
)

def _platform_flags_windows_gnu_test_impl(ctx):
    env = unittest.begin(ctx)
    flags = get_platform_link_flags("x86_64-w64-windows-gnu")
    asserts.equals(env, ["-luserenv", "-ldbghelp", "-lws2_32", "-lbcrypt", "-lcrypt32"], flags)
    return unittest.end(env)

_platform_flags_windows_gnu_test = unittest.make(
    _platform_flags_windows_gnu_test_impl,
)

def _platform_flags_windows_aarch64_test_impl(ctx):
    env = unittest.begin(ctx)
    flags = get_platform_link_flags("aarch64-w64-windows-gnu")
    asserts.equals(env, ["-luserenv", "-ldbghelp", "-lws2_32", "-lbcrypt", "-lcrypt32"], flags)
    return unittest.end(env)

_platform_flags_windows_aarch64_test = unittest.make(
    _platform_flags_windows_aarch64_test_impl,
)

def _platform_flags_empty_triple_test_impl(ctx):
    env = unittest.begin(ctx)
    # Empty triple → POSIX defaults
    flags = get_platform_link_flags("")
    asserts.equals(env, ["-pthread", "-ldl", "-lm"], flags)
    return unittest.end(env)

_platform_flags_empty_triple_test = unittest.make(
    _platform_flags_empty_triple_test_impl,
)

def _platform_flags_none_triple_test_impl(ctx):
    env = unittest.begin(ctx)
    # None triple → POSIX defaults
    flags = get_platform_link_flags(None)
    asserts.equals(env, ["-pthread", "-ldl", "-lm"], flags)
    return unittest.end(env)

_platform_flags_none_triple_test = unittest.make(
    _platform_flags_none_triple_test_impl,
)

# ===========================================================================
# Tests for get_linking_path
# ===========================================================================

def _linking_path_posix_test_impl(ctx):
    env = unittest.begin(ctx)
    # POSIX uses ':' and includes /usr/bin, /bin. It should also deduplicate.
    result = get_linking_path(
        ":",
        "/path/to/llvm/bin/clang",
        "/path/to/llvm/bin/ar",
    )
    asserts.equals(env, "/path/to/llvm/bin:/usr/bin:/bin", result)
    return unittest.end(env)

_linking_path_posix_test = unittest.make(
    _linking_path_posix_test_impl,
)

def _linking_path_windows_test_impl(ctx):
    env = unittest.begin(ctx)
    # Windows uses ';' and should include System32, and deduplicate.
    result = get_linking_path(
        ";",
        "C:/llvm/bin/clang.exe",
        "C:/llvm/bin/llvm-ar.exe",
    )
    asserts.equals(env, "C:/llvm/bin;C:\\Windows\\System32;C:\\Windows", result)
    return unittest.end(env)

_linking_path_windows_test = unittest.make(
    _linking_path_windows_test_impl,
)

def _linking_path_different_dirs_test_impl(ctx):
    env = unittest.begin(ctx)
    result = get_linking_path(
        ":",
        "/usr/local/bin/clang",
        "/opt/llvm/bin/ar",
    )
    asserts.equals(env, "/usr/local/bin:/opt/llvm/bin:/usr/bin:/bin", result)
    return unittest.end(env)

_linking_path_different_dirs_test = unittest.make(
    _linking_path_different_dirs_test_impl,
)

def _linking_path_dedup_test_impl(ctx):
    env = unittest.begin(ctx)
    # Test that duplicate paths are removed even if they come from different sources
    result = get_linking_path(
        ":",
        "/usr/bin/clang",
        "/usr/bin/ar",
    )
    # /usr/bin is added by clang/ar paths AND by default POSIX paths, should only appear once.
    asserts.equals(env, "/usr/bin:/bin", result)
    return unittest.end(env)

_linking_path_dedup_test = unittest.make(
    _linking_path_dedup_test_impl,
)

# ===========================================================================
# Test suite entry point
# ===========================================================================

def target_triple_test_suite(name):
    """Declares all target triple unit tests and wraps them in a test_suite."""
    unittest.suite(
        name,
        # get_target_triple_from_options tests
        _target_from_options_dash_target_test,
        _target_from_options_double_dash_equals_test,
        _target_from_options_not_present_test,
        _target_from_options_empty_list_test,
        _target_from_options_dangling_target_flag_test,
        # get_target_triple_from_cpu tests
        _cpu_to_triple_native_linux_test,
        _cpu_to_triple_linux_aarch64_test,
        _cpu_to_triple_darwin_arm64_test,
        _cpu_to_triple_darwin_x86_64_test,
        _cpu_to_triple_windows_x64_test,
        _cpu_to_triple_windows_win64_test,
        _cpu_to_triple_windows_aarch64_test,
        _cpu_to_triple_unknown_returns_none_test,
        # TARGET_CPU_TO_TRIPLE map tests
        _cpu_map_contains_expected_keys_test,
        # validate_target_triple (success cases)
        _validate_target_empty_string_ok_test,
        _validate_target_none_ok_test,
        _validate_target_linux_ok_test,
        _validate_target_darwin_ok_test,
        _validate_target_windows_ok_test,
        # get_platform_link_flags tests
        _platform_flags_linux_test,
        _platform_flags_darwin_test,
        _platform_flags_windows_gnu_test,
        _platform_flags_windows_aarch64_test,
        _platform_flags_empty_triple_test,
        _platform_flags_none_triple_test,
        # get_linking_path tests
        _linking_path_posix_test,
        _linking_path_windows_test,
        _linking_path_different_dirs_test,
        _linking_path_dedup_test,
    )
