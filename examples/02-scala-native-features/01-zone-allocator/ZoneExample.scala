package examples

import scala.scalanative.unsafe.*

@main
def zone(): Unit =
    // Zones provide a way to manage lifetimes of allocated memory.
    // All memory allocated within a zone is freed when the zone is closed.
    Zone:
      println("Inside the zone. Allocating memory for a CString using the implicit zone...")
      val cStr = toCString("Hello world!")  // toCString requires a zone allocator
      println("Inside the zone. Allocating memory for a CString...")
      val cStr2 = toCString("Hello world again!")(using summon[Zone])  // explicitly passing the zone to toCString
      println(s"Value in zone-allocated memory: ${fromCString(cStr2)}")

    // Memory pointed to by 'ptr' is now invalid/freed.
    println("Zone closed. Memory has been freed.")
