package examples

import scala.scalanative.unsafe.*

@extern
object CAdd:
    def add(a: CInt, b: CInt): CInt = extern

@main
def add(): Unit =
    val result = CAdd.add(5, 7)
    println(s"Result of C add(5, 7): $result")
