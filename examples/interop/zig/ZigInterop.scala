package examples.interop.zig

import scala.scalanative.unsafe.*

@extern
object ZigAdder:
  @name("add")
  def add(a: CInt, b: CInt): CInt = extern

object ZigInteropExample:
  def main(args: Array[String]): Unit =
    val a: CInt = 15
    val b: CInt = 27
    val result = ZigAdder.add(a, b)
    println(s"Using Zig: $a + $b = $result")
