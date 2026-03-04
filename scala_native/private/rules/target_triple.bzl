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

def get_linking_path(host_path_separator, clang_path):
    """Constructs the PATH environment variable for the Scala Native linker.

    The Scala Native linker binary discovers `llvm-ar` at runtime by searching
    PATH (or the LLVM_BIN env var). Since the @llvm hermetic toolchain always
    places `llvm-ar` alongside `clang` in the same bin directory, putting the
    clang directory in PATH is sufficient for the linker to find all LLVM tools.

    Bazel guarantees forward-slash paths on all platforms (including Windows),
    so `rpartition("/")` is the correct way to extract the directory.

    Args:
        host_path_separator: The path separator for the host platform (':' or ';').
        clang_path: Absolute path to the clang compiler binary.

    Returns:
        A string suitable for use as the PATH environment variable.
    """
    clang_bin_dir = clang_path.rpartition("/")[0]

    # Build the path list, deduplicating while preserving insertion order.
    seen = {}
    paths = []

    def _add(p):
        if p not in seen:
            seen[p] = True
            paths.append(p)

    _add(clang_bin_dir)

    # On POSIX, also include standard system directories so that any system
    # tools invoked transitively by the linker (e.g. shell utilities) can be
    # found. These are not needed on Windows because the Windows system32 dir
    # is already on PATH by default in the execution environment.
    if host_path_separator == ":":
        _add("/usr/bin")
        _add("/bin")

    return host_path_separator.join(paths)
