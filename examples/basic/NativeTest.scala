package examples.basic

import org.junit.Test
import org.junit.Assert.*

class NativeTest:
  @Test
  def testMath(): Unit =
    assertEquals("Basic arithmetic should work", 4, 2 + 2)
