package examples

import scala.scalanative.unsafe.*

@main
def pointerExample(): Unit =
    // Allocate an integer on the stack
    val ptr = stackalloc[CInt]()
    
    // Set the value (dereference and assign)
    !ptr = 42
    
    println(s"Value at pointer: ${!ptr}")
    
    // Pointer arithmetic (moving to the "next" int position)
    val nextPtr = ptr + 1
    !nextPtr = 100
    
    println(s"Value at next pointer: ${!nextPtr}")
