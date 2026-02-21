package examples.interop.cpp

import scala.scalanative.unsafe.*

@extern
object CppGreeter:
  def greeter_new(name: CString): Ptr[Byte] = extern
  def greeter_greet(greeter: Ptr[Byte]): Unit = extern
  def greeter_delete(greeter: Ptr[Byte]): Unit = extern

@main
def cppInteropExample(): Unit =
  Zone:
    println("Scala says: Creating C++ object via C wrapper...")
    val name = toCString("Scala Native User")
    val greeter = CppGreeter.greeter_new(name)
    
    println("Scala says: Calling C++ method...")
    CppGreeter.greeter_greet(greeter)
    
    println("Scala says: Deleting C++ object...")
    CppGreeter.greeter_delete(greeter)
