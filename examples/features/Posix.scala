package examples.features

import scala.scalanative.unsafe.*
import scala.scalanative.unsigned.*

@extern
object unistd:
  def getpid(): CInt = extern
  def getcwd(buf: CString, size: CSize): CString = extern

@main
def posixExample(): Unit =
  println("Making direct POSIX system calls from Scala Native via @extern...")
  
  // Directly call the POSIX getpid() function
  val pid = unistd.getpid()
  println(s"The current process ID is: $pid")
  
  Zone:
    val buffer = alloc[CChar](1024)
    // Directly call the POSIX getcwd() function
    val cwdPtr = unistd.getcwd(buffer, 1024.toCSize)
    if cwdPtr != null then
      val cwdStr = fromCString(cwdPtr)
      println(s"Current working directory: $cwdStr")
    else
      println("Failed to get current working directory.")
