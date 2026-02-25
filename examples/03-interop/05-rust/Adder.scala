package examples

import scala.scalanative.unsafe.*

@extern
object RustAdder:
    def add(a: CInt, b: CInt): CInt = extern

@main
def rustInterop(): Unit =
  println("Starting Rust Interop Example...")
  val result = RustAdder.add(10, 32)
  println(s"Result from Rust: $result")
  println("--- Done ---")
