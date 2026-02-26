"""Public API for scala_native_test rule."""

load("//scala_native:scala_native_library.bzl", "scala_native_library")
load("//scala_native/private/rules:scala_native_binary.bzl", "scala_native_internal_test")

def scala_native_test(name, srcs = [], deps = [], suites = [], scalacopts = [], **kwargs):
    """Macro to run Scala Native tests using JUnit."""
    if not suites:
        fail("scala_native_test '{}' requires a non-empty 'suites' list. ".format(name) +
             "Specify fully qualified test class names, e.g. suites = [\"com.example.MyTest\"]")
    main_name = name + "_TestMain"
    main_file = name + "_TestMain.scala"

    native.genrule(
        name = main_name + "_gen",
        outs = [main_file],
        cmd = """
cat << 'EOF' > $@
package bazel.native.test

import scala.scalanative.junit.JUnitFramework
import sbt.testing._

object TestMain {
  def main(args: Array[String]): Unit = {
    val fw = new JUnitFramework()
    val runner = fw.runner(args, Array.empty, getClass.getClassLoader)
    val suitesStr = "%s"
    val suites = if (suitesStr.isEmpty) Array.empty[String] else suitesStr.split(",")
    val taskDefs = suites.map(clsName => new TaskDef(clsName, fw.fingerprints().head, true, Array(new SuiteSelector())))
    val tasks = runner.tasks(taskDefs)
    
    val reporter = new Reporter()
    tasks.foreach(task => task.execute(reporter, Array.empty))
    if (reporter.failed) sys.exit(1)
  }
}

class Reporter extends EventHandler with Logger {
  var failed = false
  def handle(event: Event): Unit = {
    if (event.status() == Status.Failure || event.status() == Status.Error) failed = true
    println(s"[$${event.status()}] $${event.fullyQualifiedName()} - $${event.status()}")
    if (event.throwable().isDefined()) {
      trace(event.throwable().get())
    }
  }
  def ansiCodesSupported(): Boolean = false
  def error(msg: String): Unit = println(s"ERROR: $${msg}")
  def warn(msg: String): Unit = println(s"WARN: $${msg}")
  def info(msg: String): Unit = println(s"INFO: $${msg}")
  def debug(msg: String): Unit = println(s"DEBUG: $${msg}")
  def trace(t: Throwable): Unit = t.printStackTrace()
}
EOF
""" % (",".join(suites)),
    )

    lib_name = name + "_lib"
    
    # Compile the generated main class and any user sources
    scala_native_library(
        name = lib_name,
        srcs = srcs + [main_file],
        scalacopts = scalacopts,
        deps = deps + [
            "@org_scala_native_test_interface//jar",
            "@org_scala_native_test_interface_sbt_defs//jar",
            "@org_scala_native_junit_runtime//jar",
            "@org_junit_junit//jar",
        ],
    )

    # Link everything into an executable test target
    scala_native_internal_test(
        name = name,
        main_class = "bazel.native.test.TestMain",
        deps = [":" + lib_name],
        **kwargs
    )
