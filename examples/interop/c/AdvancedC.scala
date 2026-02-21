package examples.interop.c

import scala.scalanative.unsafe.*

type Person = CStruct2[CString, CInt]

@extern
object AdvancedCLib:
  def print_person(p: Ptr[Person]): Unit = extern
  def have_birthday(p: Ptr[Person]): Unit = extern

@main
def advancedCExample(): Unit =
  Zone:
    val personPtr = alloc[Person]()
    
    // Initialize the struct fields
    !(personPtr.at1) = toCString("Scala Native Hero")
    !(personPtr.at2) = 30
    
    println("Scala says: passing struct to C...")
    AdvancedCLib.print_person(personPtr)
    AdvancedCLib.have_birthday(personPtr)
    
    val updatedAge = !(personPtr.at2)
    println(s"Scala says: reading back updated age from C: $updatedAge")

