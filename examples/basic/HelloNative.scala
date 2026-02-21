package examples.native

import scala.scalanative.unsafe._

@extern
object CGreetings:
  def c_greeting_function(): Unit = extern

@main
def sayHello: Unit =
    println(s"Hello from Scala Native to the World!")
    CGreetings.c_greeting_function()
