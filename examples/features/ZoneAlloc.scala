package examples.features

import scala.scalanative.unsafe.*

@main
def zoneAllocExample(): Unit =
  println("Demonstrating Zone Allocation for safe, deterministic memory management.")
  
  Zone:
    // Allocate an array of 5 integers.
    // The memory will be automatically freed when exiting the Zone.
    val numElements = 5
    val arrayPtr = alloc[CInt](numElements)
    
    for i <- 0 until numElements do
      // Pointer arithmetic: write squares to the array
      !(arrayPtr + i) = i * i

    print("Squares stored in unmanaged memory: ")
    for i <- 0 until numElements do
      print(s"${!(arrayPtr + i)} ")
    println()

  println("Left Zone. Memory has been freed.")
