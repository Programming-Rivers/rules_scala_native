"""Pure helper functions for deriving and validating LLVM target triples.

These functions are extracted from scala_native_binary.bzl so they can be
imported by both the rule implementation and unit tests.
"""

# Map CC toolchain target_cpu values to LLVM target triples.
# The CC toolchain's target_cpu reflects the platform constraint values.
# Note: llvm uses "win64" for Windows x86_64.
TARGET_CPU_TO_TRIPLE = {
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

UNSUPPORTED_TARGET_PATTERNS = ["wasm32", "wasm64"]

def validate_target_triple(target_triple):
    """Fail fast for platforms Scala Native cannot target.

    Args:
        target_triple: The LLVM target triple string, or empty string / None.

    Raises:
        A Bazel `fail()` if the target is unsupported (e.g. wasm32, wasm64).
    """
    if target_triple:
        for pattern in UNSUPPORTED_TARGET_PATTERNS:
            if pattern in target_triple:
                fail(
                    "Scala Native does not support target '{}'. ".format(target_triple) +
                    "Supported targets: Linux (x86_64, aarch64), macOS (x86_64, aarch64), " +
                    "Windows (x86_64, aarch64).",
                )

def get_target_triple_from_options(c_compile_options):
    """Derive the LLVM target triple from a list of compiler flags.

    Looks for `-target <triple>` or `--target=<triple>` in the compile options.

    Args:
        c_compile_options: List of string compile flags.

    Returns:
        The target triple string if found, or None.
    """
    for i in range(len(c_compile_options)):
        opt = c_compile_options[i]
        if opt == "-target" and i + 1 < len(c_compile_options):
            return c_compile_options[i + 1]
        elif opt.startswith("--target="):
            return opt[len("--target="):]
    return None

def get_target_triple_from_cpu(cpu):
    """Map a Bazel CC toolchain CPU name to an LLVM target triple.

    Args:
        cpu: The CC toolchain's cpu string (e.g. "k8", "aarch64", "darwin_arm64").

    Returns:
        The LLVM target triple string, or None if native / unknown.
    """
    return TARGET_CPU_TO_TRIPLE.get(cpu, None)

def get_platform_link_flags(target_triple):
    """Return platform-appropriate linker flags for Scala Native executables.

    POSIX systems need pthread, dl, m; Windows (MinGW) does not, but needs
    dbghelp, userenv, etc.

    Args:
        target_triple: The LLVM target triple string, or empty string / None.

    Returns:
        A list of linker flag strings.
    """
    if target_triple and "windows" in target_triple:
        return ["-luserenv", "-ldbghelp", "-lws2_32", "-lbcrypt", "-lcrypt32"]
    else:
        return ["-pthread", "-ldl", "-lm"]
def get_linking_path(host_path_separator, clang_path, ar_path):
    """Constructs the PATH environment variable for the Scala Native linker.

    Args:
        host_path_separator: The path separator for the host platform (':' or ';').
        clang_path: Absolute path to the clang compiler.
        ar_path: Absolute path to the archiver (ar / llvm-ar).

    Returns:
        A string containing the PATH environment variable.
    """
    paths = [
        clang_path.rpartition("/")[0],
        ar_path.rpartition("/")[0],
    ]

    # Add standard paths on POSIX for tools that might be needed by the linker
    # discovery but are not part of the hermetic toolchain (e.g. system libs)
    if host_path_separator == ":":
        paths.extend(["/usr/bin", "/bin"])

    return host_path_separator.join(paths)
