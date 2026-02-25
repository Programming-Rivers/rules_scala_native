package examples
import scala.scalanative.unsafe.*

@extern
object CppGreeter:
    @name("greeter_new")
    def greeter_new(name: CString): Ptr[Byte] = extern
    @name("greeter_greet")
    def greeter_greet(greeter: Ptr[Byte]): Unit = extern
    @name("greeter_delete")
    def greeter_delete(greeter: Ptr[Byte]): Unit = extern

@main
def cppInteropExample(): Unit =
  println("Starting C++ Interop Example...")
  println("Scala says: Creating C++ object via C wrapper...")
  Zone:
    val name = toCString("Scala Native User")
    
    println("Creating C++ object...")
    val greeter = CppGreeter.greeter_new(name)
    
    println("Calling C++ method...")
    CppGreeter.greeter_greet(greeter)
    
    println("Deleting C++ object...")
    CppGreeter.greeter_delete(greeter)

  println("--- Done ---")
