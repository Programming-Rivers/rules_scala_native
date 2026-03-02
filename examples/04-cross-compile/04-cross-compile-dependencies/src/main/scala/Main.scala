package examples

import wiringpi.all.*
import scala.scalanative.unsafe.*

@main
def main: Unit =
  println("Initializing WiringPi...")
  
  // Call wiringPiSetup() from the bindings
  val status = wiringPiSetup()
  
  if (status == -1) {
    println("Failed to initialize WiringPi")
    System.exit(1)
  }
  
  println("WiringPi initialized successfully!")
  println("This program was successfully cross-compiled and dynamically linked against libwiringPi.so")
  
  // Get the board rev just to test another function
  val rev = piBoardRev()
  println(s"Board revision (or equivalent): $rev")
