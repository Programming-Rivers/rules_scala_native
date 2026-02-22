# Comprehensive Testing Strategy: `rules_scala_native`

Evaluating a cross-compiled, multi-language Bazel toolchain requires more than standard test execution; it mandates verifying the *construction* of the action graph, the *flags* passed to backend compilers, and the *runtime correctness* across varying architectures. 

This document outlines a structured testing pyramid specifically tailored for `rules_scala_native`.

---

## 1. The Strategy Pyramid

Testing this ruleset breaks down into four primary layers:
1. **Starlark Unit Tests:** Verify macro logic, rule attributes, and provider generation.
2. **Analysis-Phase Integration Tests:** Assert that Bazel constructs the correct actions, toolchains, and `CcInfo` structures without executing the compiler.
3. **Execution-Phase E2E Tests:** Compile actual minimal examples and observe linker and compilation success.
4. **Runtime Functional Tests:** Run the generated native artifacts, asserting correct FFI linkages, stdout, and semantic behaviors.

---

## 2. Layered Testing Plan

### 2.1 Unit Testing: Starlark Build Logic
**Goal:** Ensure rule logic (e.g., `scala_native_binary`, toolchain resolution) behaves correctly given isolated inputs.  
**Tools:** `bazel-skylib` (`unittest.bzl`) or `rules_testing`.

* **What to Test:**
    * **Provider Propagation:** Assert that a `scala_native_library` correctly surfaces a `CcInfo` provider for dependent downstream rules.
    * **Attribute Validation:** Validate that invalid configurations (e.g., conflicting `linkopts`) fail the build intelligently with `fail()`.
    * **Argument Construction:** Mock the toolchain context and verify that the correct sequences of arguments (`-I`, `-L`, `-target`) are appended to the Clang wrapper based on rule attributes.
* **Why here?** These tests run during Bazel's execution phase but do not rely on a real Clang/LLVM toolchain. They are lightning-fast and ensure deterministic rule logic.

### 2.2 Integration Testing: Action Graph & Toolchain
**Goal:** Verify that the registered toolchains and dependency links culminate in the correct command lines and outputs.  
**Tools:** `bazel-skylib` (`analysistest.bzl`), `BuildSetting` mocks.

* **What to Test:**
    * **Action Inspection:** Assert that the registered action to compile Scala Native uses the resolved Clang wrapper and includes paths from dependent C/C++/Rust rules.
    * **Transitive Dependencies:** Ensure that a `rust_library` target in the `deps` correctly propagates its static archives (`.a` / `.lib`) to the final linking action of the `scala_native_binary`.
    * **Target Transitions:** If utilizing configuration transitions (e.g., forcing a cross-compile target), verify that the resulting action uses the mapped CPU configuration/sysroot.

### 2.3 End-to-End (E2E) Functional Testing
**Goal:** Prove that the compilation completes and the binary outputs the expected signals.  
**Tools:** Native `sh_test`, Bazel's `scala_native_test` (if implemented), and `build_test()`.

* **What to Test:**
    * **Multi-language FFI:** Create dedicated, minimal targets in `tests/e2e/`.
        * *Scala ↔ C:* A `scala_native_binary` calling `printf` or a custom C library.
        * *Scala ↔ Rust:* Passing a Scala `CStruct` to a Rust function via C-ABI, mutating it, and asserting the changed value in Scala.
    * **Blackbox Execution:** Use `sh_test` wrapped around the compiled `scala_native_binary` rule to capture STDOUT/STDERR and assert the runtime behavior using basic shell `grep` or assertion scripts.

### 2.4 Feature-Specific Regression
**Goal:** Lock in Scala Native specific language features against compiler/LLVM updates.  
**Tools:** Native test runner (`scala_native_test`) via JUnit/MUnit.

* **What to Test:**
    * **Memory Management:** Tests heavily exercising `Zone` allocation to ensure no segfaults surface during GC updates.
    * **Pointers & Intrinsics:** Verifying bitwise manipulation and pointer arithmetic align with expectations (endianness checks).

---

## 3. Cross-Platform Validation

Validating a cross-compiling matrix (macOS, Linux, Windows × x86_64, aarch64) in Bazel is an architectural challenge.

### 3.1 Emulation & Remote Execution
* **QEMU / Rosetta 2:** Register execution wrappers via toolchains. For instance, testing a `linux-aarch64` target on a `linux-x86_64` host by having the `scala_native_test` run command prefixed with `qemu-aarch64`.
* **Execution Transitions:** Configure Bazel to seamlessly route test actions to platform-specific runners using RBE (Remote Build Execution), or via tags (e.g., `tags = ["requires-macos"]`).

### 3.2 Matrix Slicing
* **Target Configurations:** Define distinct `//platforms:os_cpu` constraints.
* Write a starlark macro `scala_native_test_suite()` that generates a cross-product of tests, disabling invalid matrix pairs via `target_compatible_with`.

---

## 4. CI/CD Integration

To maintain velocity while ensuring stability, segregate the tests into logical CI tiers:

1. **Pre-Submit / PR Checks (Fast):**
    * Run all Starlark Unit and Analysis tests.
    * Run native E2E host tests (compile and run on the runner's native architecture).
    * **Cross-Compile Check:** Use `bazel build //tests/... --platforms=//platforms:windows_x86_64` from a Linux runner to ensure linking and wrapper logic don't throw syntax/resolution errors, even if we bypass the execution phase for those specific targets.
2. **Nightly / Merge-Queue (Comprehensive):**
    * Complete CI matrix utilizing matrix runners (GitHub Actions `macos-latest`, `ubuntu-latest`, `windows-latest`).
    * Execute the generated artifacts directly to catch OS-specific FFI bugs, misaligned pointers, or missing dynamic libraries (`.dll` / `.dylib`).

---

## 5. Next Steps for Implementation

1. **Establish `tests/` Directory:** Create isolated folders for `unit/`, `integration/`, and `e2e/`.
2. **Setup `rules_testing`:** Import Bazel's standard testing framework to begin writing Starlark validations.
3. **Migrate Existing Examples:** Transition the current PoCs (Rust, Zig, C++ interop) into the `e2e/` test suite and wrap them in `sh_test` rules to solidify them as regression tests.
