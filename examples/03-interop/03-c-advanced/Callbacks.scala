package examples

import scala.scalanative.unsafe.*
import scala.scalanative.unsigned.*

@extern
object CCallbacks:
  // CFuncPtr1[T1, R] is a function pointer that takes T1 and returns R
  def perform_action(value: CInt, cb: CFuncPtr1[CInt, Unit]): Unit = extern

inline def callback(n: CInt): Unit =
  println(s"Scala: Callback received value $n")

@main
def callbacks(): Unit =
  CCallbacks.perform_action(21, callback)
