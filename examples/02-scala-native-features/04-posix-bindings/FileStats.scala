package examples

import scala.scalanative.unsafe.*
import scala.scalanative.unsigned.*
import scala.scalanative.posix.unistd

@main
def posixExample(): Unit =
  println("Making direct POSIX system calls from Scala Native...")

  // Get current process ID
  val pid = unistd.getpid()
  println(s"The current process ID is: $pid")

  Zone:
    val buffer = alloc[CChar](1024)
    // Get current working directory
    unistd.getcwd(buffer, 1024.toCSize) match
      case null => 
        println("Failed to get current working directory.")
      case cwdPtr =>
        println(s"Current working directory: ${fromCString(cwdPtr)}")
