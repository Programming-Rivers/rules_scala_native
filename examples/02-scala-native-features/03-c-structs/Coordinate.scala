package examples

import scala.scalanative.unsafe.*

// Define a C-compatible struct entirely in Scala Native.
// This is equivalent to: struct Point { int x; int y; }
type Coordinate = CStruct2[CInt, CInt]

@main
def createCoordinate(): Unit =
  Zone:
    val location = alloc[Coordinate]()
    
    location._1 = 10
    location._2 = 20
    
    println(s"Location coordinates: x=${location._1}, y=${location._2}")

