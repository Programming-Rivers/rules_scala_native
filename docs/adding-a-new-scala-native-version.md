# Adding a New Scala Native Version

This guide outlines the step-by-step process for adding or upgrading a Scala Native version in `rules_scala_native`.

---

## 1. Background & Architecture

`rules_scala_native` manages Scala Native dependencies via the Bzlmod module extension `scala_native_deps` defined in [`scala_native/extensions/deps.bzl`](file:///home/meisam/workspace/rules_scala_native/scala_native/extensions/deps.bzl).

The extension downloads 16 core Maven artifacts from Maven Central:
1. `org_junit_junit`
2. `org_scala_native_nscplugin` (NIR compiler plugin for Dotty / Scalac)
3. `org_scala_native_scalalib` (Scala standard library compiled for Scala Native)
4. `org_scala_native_nativelib` (Core C/C++ runtime & GC implementations)
5. `org_scala_native_nir`
6. `org_scala_native_clib`
7. `org_scala_native_posixlib`
8. `org_scala_native_javalib`
9. `org_scala_native_auxlib`
10. `org_scala_native_tools` (Linker, optimizer, and codegen pipeline)
11. `org_scala_native_util`
12. `org_scala_native_test_interface_sbt_defs`
13. `org_scala_native_test_interface`
14. `org_scala_native_junit_runtime`
15. `org_scala_native_junit_plugin`
16. `org_scala_native_windowslib`

### Important Versioning Gotchas
- **Compiler Plugin Coupling (`nscplugin`, `junit-plugin`)**: Scala 3 compiler plugins depend on internal Dotty compiler APIs. The artifact ID embeds the target Scala compiler version:
  ```text
  org.scala-native:nscplugin_<SCALA_VERSION>:<SCALA_NATIVE_VERSION>
  org.scala-native:junit-plugin_<SCALA_VERSION>:<SCALA_NATIVE_VERSION>
  ```
  *(Example: `nscplugin_3.9.0:0.5.12` for Scala 3.9.0 with Scala Native 0.5.12).*
- **`scalalib` Artifact Coordinate**: `scalalib` uses a compound version string:
  ```text
  org.scala-native:scalalib_native0.5_3:jar:<SCALA_VERSION>+<SCALA_NATIVE_VERSION>
  ```
  *(Example: `scalalib_native0.5_3:jar:3.9.0+0.5.12`).*

---

## 2. Generating the Artifact Map and SHA-256 Checksums

Before editing Starlark files, verify that all artifacts exist on Maven Central and calculate their SHA-256 checksums.

Run the following Python script (adjusting `TARGET_SCALA_VERSION` and `TARGET_NATIVE_VERSION` as needed):

```python
import hashlib
import json
import urllib.request

TARGET_SCALA_VERSION = "3.9.0"
TARGET_NATIVE_VERSION = "0.5.12"

base_url = "https://repo1.maven.org/maven2"

artifacts = {
    "org_junit_junit": ("junit", "junit", "4.12", "junit:junit:4.12", []),
    "org_scala_native_nscplugin": (
        "org/scala-native",
        f"nscplugin_{TARGET_SCALA_VERSION}",
        TARGET_NATIVE_VERSION,
        f"org.scala-native:nscplugin_{TARGET_SCALA_VERSION}:{TARGET_NATIVE_VERSION}",
        [],
    ),
    "org_scala_native_scalalib": (
        "org/scala-native",
        "scalalib_native0.5_3",
        f"{TARGET_SCALA_VERSION}+{TARGET_NATIVE_VERSION}",
        f"org.scala-native:scalalib_native0.5_3:jar:{TARGET_SCALA_VERSION}+{TARGET_NATIVE_VERSION}",
        [],
    ),
    "org_scala_native_nativelib": (
        "org/scala-native",
        "nativelib_native0.5_3",
        TARGET_NATIVE_VERSION,
        f"org.scala-native:nativelib_native0.5_3:{TARGET_NATIVE_VERSION}",
        [],
    ),
    "org_scala_native_nir": (
        "org/scala-native",
        "nir_3",
        TARGET_NATIVE_VERSION,
        f"org.scala-native:nir_3:{TARGET_NATIVE_VERSION}",
        ["@org_scala_native_util"],
    ),
    "org_scala_native_clib": (
        "org/scala-native",
        "clib_native0.5_3",
        TARGET_NATIVE_VERSION,
        f"org.scala-native:clib_native0.5_3:{TARGET_NATIVE_VERSION}",
        [],
    ),
    "org_scala_native_posixlib": (
        "org/scala-native",
        "posixlib_native0.5_3",
        TARGET_NATIVE_VERSION,
        f"org.scala-native:posixlib_native0.5_3:{TARGET_NATIVE_VERSION}",
        [],
    ),
    "org_scala_native_javalib": (
        "org/scala-native",
        "javalib_native0.5_3",
        TARGET_NATIVE_VERSION,
        f"org.scala-native:javalib_native0.5_3:{TARGET_NATIVE_VERSION}",
        ["@org_scala_native_clib", "@org_scala_native_posixlib"],
    ),
    "org_scala_native_auxlib": (
        "org/scala-native",
        "auxlib_native0.5_3",
        TARGET_NATIVE_VERSION,
        f"org.scala-native:auxlib_native0.5_3:{TARGET_NATIVE_VERSION}",
        [],
    ),
    "org_scala_native_tools": (
        "org/scala-native",
        "tools_3",
        TARGET_NATIVE_VERSION,
        f"org.scala-native:tools_3:{TARGET_NATIVE_VERSION}",
        ["@org_scala_native_nativelib", "@org_scala_native_javalib", "@org_scala_native_scalalib"],
    ),
    "org_scala_native_util": (
        "org/scala-native",
        "util_3",
        TARGET_NATIVE_VERSION,
        f"org.scala-native:util_3:{TARGET_NATIVE_VERSION}",
        [],
    ),
    "org_scala_native_test_interface_sbt_defs": (
        "org/scala-native",
        "test-interface-sbt-defs_native0.5_3",
        TARGET_NATIVE_VERSION,
        f"org.scala-native:test-interface-sbt-defs_native0.5_3:{TARGET_NATIVE_VERSION}",
        [],
    ),
    "org_scala_native_test_interface": (
        "org/scala-native",
        "test-interface_native0.5_3",
        TARGET_NATIVE_VERSION,
        f"org.scala-native:test-interface_native0.5_3:{TARGET_NATIVE_VERSION}",
        ["@org_scala_native_nativelib", "@org_scala_native_javalib", "@org_scala_native_scalalib", "@org_scala_native_test_interface_sbt_defs"],
    ),
    "org_scala_native_junit_runtime": (
        "org/scala-native",
        "junit-runtime_native0.5_3",
        TARGET_NATIVE_VERSION,
        f"org.scala-native:junit-runtime_native0.5_3:{TARGET_NATIVE_VERSION}",
        ["@org_scala_native_nativelib", "@org_scala_native_javalib", "@org_scala_native_scalalib", "@org_junit_junit", "@org_scala_native_test_interface"],
    ),
    "org_scala_native_junit_plugin": (
        "org/scala-native",
        f"junit-plugin_{TARGET_SCALA_VERSION}",
        TARGET_NATIVE_VERSION,
        f"org.scala-native:junit-plugin_{TARGET_SCALA_VERSION}:{TARGET_NATIVE_VERSION}",
        [],
    ),
    "org_scala_native_windowslib": (
        "org/scala-native",
        "windowslib_native0.5_3",
        TARGET_NATIVE_VERSION,
        f"org.scala-native:windowslib_native0.5_3:{TARGET_NATIVE_VERSION}",
        ["@org_scala_native_nativelib"],
    ),
}

for name, (group, art, ver, artifact_str, deps) in artifacts.items():
    jar_url = f"{base_url}/{group}/{art}/{ver}/{art}-{ver}.jar"
    sha256_url = f"{jar_url}.sha256"
    sha256 = None
    try:
        with urllib.request.urlopen(sha256_url) as resp:
            sha256 = resp.read().decode("utf-8").strip()
    except Exception:
        with urllib.request.urlopen(jar_url) as resp:
            sha256 = hashlib.sha256(resp.read()).hexdigest()

    deps_str = ', '.join([f'"{d}"' for d in deps])
    print(f'        "{name}": {{')
    print(f'            "artifact": "{artifact_str}",')
    print(f'            "sha256": "{sha256}",')
    print(f'            "deps": [{deps_str}],')
    print(f'        }},')
```

---

## 3. Step-by-Step Code Modifications

### Step 1: Update `scala_native/extensions/deps.bzl`
Add the generated version dictionary to `_SCALA_NATIVE_ARTIFACTS` in [`scala_native/extensions/deps.bzl`](file:///home/meisam/workspace/rules_scala_native/scala_native/extensions/deps.bzl):

```starlark
_SCALA_NATIVE_ARTIFACTS = {
    "0.5.10": { ... },
    "<NEW_VERSION>": {
        "org_junit_junit": { ... },
        ...
    },
}
```

If making `<NEW_VERSION>` the new default:
- Update `_toolchain_tag` default:
  ```starlark
  _toolchain_tag = tag_class(
      attrs = {
          "scala_native_version": attr.string(
              default = "<NEW_VERSION>",
              doc = "The version of Scala Native to use. Default is <NEW_VERSION>.",
          ),
      },
  )
  ```
- Update the default fallback in `_scala_native_deps_impl`:
  ```starlark
  scala_native_version = "<NEW_VERSION>"
  ```

### Step 2: Update Toolchain Defaults (if bumping the default)
Update the default version string in the following files:

1. **[`scala_native/BUILD`](file:///home/meisam/workspace/rules_scala_native/scala_native/BUILD)**:
   ```starlark
   scala_native_toolchain(
       name = "default_scala_native_toolchain",
       ...
       scala_native_version = "<NEW_VERSION>",
   )
   ```

2. **[`scala_native/scala_native_toolchain.bzl`](file:///home/meisam/workspace/rules_scala_native/scala_native/scala_native_toolchain.bzl)**:
   ```starlark
   "scala_native_version": attr.string(
       default = "<NEW_VERSION>",
       doc = "The Scala Native version",
   ),
   ```

3. **[`MODULE.bazel`](file:///home/meisam/workspace/rules_scala_native/MODULE.bazel)**:
   ```starlark
   scala_native_deps.toolchain(scala_native_version = "<NEW_VERSION>")
   ```

### Step 3: Check Linker & Native Toolchain Interaction
When upgrading major or minor Scala Native versions, inspect [`scala_native/private/linker/NativeLinker.scala`](file:///home/meisam/workspace/rules_scala_native/scala_native/private/linker/NativeLinker.scala):
- Check for changes in the `scala.scalanative.build` API (e.g. `NativeConfig`, `Build.buildCachedAwait`).
- Ensure compiler flags containing paths with `=` (e.g. `-resource-dir=...`, `--sysroot=...`) continue to be properly converted to absolute paths by `makeAbsolute`:
  ```scala
  else if (opt.contains("=")) {
    val eqIdx = opt.indexOf('=')
    val prefix = opt.substring(0, eqIdx + 1)
    val path = opt.substring(eqIdx + 1)
    if (!path.startsWith("/") && execRoot.resolve(path).toFile.exists()) {
      prefix + execRoot.resolve(path).toString
    } else {
      opt
    }
  }
  ```

### Step 4: Update Documentation
Update version strings and compatibility notes in:
- [`README.md`](file:///home/meisam/workspace/rules_scala_native/README.md) under `## Requirements` and `## Current Limitations`.

---

## 4. Verification & Testing

Verify that both standard compilation and native linking succeed with the new version:

### 1. Build and Run an Example Target
```bash
cd examples/01-basics/01-hello-world
bazel run //:main
```
Verify the output (e.g., `Hello from Scala Native!`).

### 2. Verify Multi-Package Transitive Dependencies
```bash
cd examples/01-basics/02-transitive-dependencies
bazel run //:main
```

### 3. Run Rule Unit Tests
From the workspace root:
```bash
bazel test //tests/unit/...
```

### 4. Run Integration Tests
```bash
bazel test --config=e2e_throttled //tests/e2e/...
```

---

## 5. Common Troubleshooting

| Error | Root Cause | Solution |
|---|---|---|
| `ClassNotFoundException: dotty.tools.backend.jvm.DottyPrimitives` | The Scala compiler version does not match the Scala compiler version that `nscplugin` was compiled against. | Update `nscplugin` to `nscplugin_<SCALA_VERSION>:<NATIVE_VERSION>`. |
| `fatal error: 'stddef.h' file not found` | Clang's `-resource-dir` was passed as a relative path and could not be resolved when compiling native C files in the sandboxed workdir. | Ensure `makeAbsolute` in `NativeLinker.scala` resolves flags formatted as `key=value` against `execRoot`. |
| `Action declared for non-existent exec group 'scalac'` | `_scala_native_base_library` invokes rules_scala compilation phases without declaring the `scalac` exec group. | Add `exec_groups = {"scalac": exec_group()}` to `_scala_native_base_library` in `scala_native_library.bzl`. |
