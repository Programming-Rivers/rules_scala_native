package examples.native

import scala.scalanative.unsafe._

@extern
object CGreetings {
  def c_greeting_function(): Unit = extern
}

@main
def sayHello(name: String): Unit =
    println(s"Hello from Scala Native to $name")
    CGreetings.c_greeting_function()
