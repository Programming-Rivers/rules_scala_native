package examples

import scala.scalanative.unsafe.*

@extern
object ZigAdder:
    def add(a: CInt, b: CInt): CInt = extern

@main
def add(): Unit =
    val result = ZigAdder.add(15, 27)
    println(s"Result of Zig add(15, 27): $result")
