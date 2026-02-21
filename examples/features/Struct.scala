package examples.features

import scala.scalanative.unsafe.*

// Define a C-compatible struct entirely in Scala Native.
// This is exactly equivalent to: struct Vector3 { double x; double y; double z; }
type Vector3 = CStruct3[CDouble, CDouble, CDouble]

@main
def structExample(): Unit =
  Zone:
    println("Creating a Scala-defined C Struct...")
    val vec = alloc[Vector3]()
    
    // Using explicit field accessors
    !(vec.at1) = 1.0
    !(vec.at2) = 2.5
    !(vec.at3) = 3.14
    
    val magnitude = math.sqrt(
      !(vec.at1) * !(vec.at1) + 
      !(vec.at2) * !(vec.at2) + 
      !(vec.at3) * !(vec.at3)
    )
    
    println(f"Vector(${!(vec.at1)}, ${!(vec.at2)}, ${!(vec.at3)}) has magnitude $magnitude%.2f")
