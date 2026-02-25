package examples

@main
def intrinsicsExample(): Unit =
    val a: Int = -10
    val b: Int = 3
    
    // Standard division (signed)
    println(s"Signed division: $a / $b = ${a / b}")
    
    // Unsigned division (intrinsic-like behavior)
    // -10 as unsigned is a very large number
    val ua = a.toLong & 0xFFFFFFFFL
    val ub = b.toLong & 0xFFFFFFFFL
    println(s"Unsigned division (simulated): $ua / $ub = ${ua / ub}")
    
    // In Scala Native, one can use unsigned types directly
    import scala.scalanative.unsigned.*
    val u1: UInt = 10.toUInt
    val u2: UInt = 3.toUInt
    println(s"Unsigned UInt division: $u1 / $u2 = ${u1 / u2}")
