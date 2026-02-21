package examples.interop.rust

import scala.scalanative.unsafe.*

@extern
object RustAdder {
  @name("add")
  def add(a: CInt, b: CInt): CInt = extern
}

object RustInteropExample {
  def main(args: Array[String]): Unit = {
    val a: CInt = 15
    val b: CInt = 27
    val result = RustAdder.add(a, b)
    println(s"Using Rust: $a + $b = $result")
  }
}
