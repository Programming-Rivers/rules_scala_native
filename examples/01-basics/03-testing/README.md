# 03 Unit Testing

> **Prerequisites:** [02-transitive-dependencies](../02-transitive-dependencies/) (Dependency management and multi-library projects)

## Goal

Learn how to write and run unit tests for Scala Native code using `scala_native_test` and the JUnit framework.

## Description

Testing is a first-class citizen in Bazel. Scala Native uses the `scala_native_test` rule, which integrates with the JUnit testing framework. This allows you to write tests using annotations like `@Test` and standard assertions.

In this example, we have:
1.  **`palindrome`** (Library): A simple library that provides a `isPalindrome` function.
2.  **`palindrome_test`** (Test): A test target that verifies the logic of the `palindrome` library.

When you run `bazel test`, Bazel:
1.  Identifies all test targets.
2.  Builds the necessary libraries and the test runner.
3.  Executes the tests in an isolated environment.
4.  Reports the results (PASS/FAIL) and provides logs for failed tests.

## Build & Run

To run the tests:
```bash
$ cd examples/01-basics/03-testing
$ bazel test //:palindrome_test
```

If a test fails, Bazel will provide a path to the test log:
```bash
$ cat bazel-testlogs/palindrome_test/test.log
```

## Key Concepts

- **`scala_native_test` rule**: A Bazel rule that compiles and runs Scala Native tests. It behaves similarly to `scala_native_binary` but is specifically designed for test execution.
- **`suites` attribute**: **Crucial.** Unlike standard JVM `rules_scala`, `scala_native_test` currently requires an explicit list of fully qualified test class names in the `suites` attribute. Without this, no tests will be discovered.
- **JUnit Integration**: `rules_scala_native` supports the JUnit testing framework. You can use `@Test`, `@Before`, `@After`, etc.
- **Test Isolation**: Each test runs in its own sandbox, ensuring that tests don't interfere with each other or the host system.
- **Caching**: Bazel only re-runs tests if the source code or dependencies have changed, significantly speeding up development.

## Code Highlights

### `BUILD.bazel`

Note how the test target depends on the library being tested.

```python
# BUILD.bazel

load(
    "@rules_scala_native//scala_native:scala_native_library.bzl",
    "scala_native_library",
)
load(
    "@rules_scala_native//scala_native:scala_native_test.bzl",
    "scala_native_test",
)

scala_native_library(
    name = "palindrome",
    srcs = ["Palindrome.scala"],
)

scala_native_test(
    name = "palindrome_test",
    srcs = ["PalindromeTest.scala"],
    deps = [":palindrome"],
    suites = ["examples.StringTest"],   # test suites must be explicitly listed
)
```
> Note: Bazel rule `scala_native_test` does not support automatic test discovery.
  Test suites must be explicitly listed in the `suites` attribute.
  In the future we should consider options to discover the tests automatically
  and remove the `suites` attribute from scala_native_tests.

### `PalindromeTest.scala`

The test uses standard JUnit annotations and assertions.

```scala
// PalindromeTest.scala
package examples

import org.junit.Test
import org.junit.Assert.*

class StringTest:
  @Test
  def testReverse(): Unit =
    assertFalse("abc is NOT a palindrome", isPalindrome("abc"))
    assertTrue("kayak is a palindrome", isPalindrome("kayak"))
    assertTrue("racecar is a palindrome", isPalindrome("racecar"))
```

## Next Steps

Now that you know how to test your code, let's explore how to interact with the underlying operating system and C libraries.

→ [04-static-and-dynamic-libraries](../04-static-and-dynamic-libraries/): Linking with native C/C++ libraries.
