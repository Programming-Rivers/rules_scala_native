package examples

import scala.scalanative.unsafe.*

type Point = CStruct2[CInt, CInt]

@extern
object CGreeter:
  def greet(name: CString, p: Ptr[Point]): Unit = extern

@main
def interopExample(): Unit =
  Zone:
    val p = alloc[Point]()
    p._1 = 15
    p._2 = 30
    
    val name = toCString("Scala Native Learner")
    CGreeter.greet(name, p)
