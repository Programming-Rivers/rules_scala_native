package examples

import org.junit.Test
import org.junit.Assert.*

class StringTest:
  @Test
  def testReverse(): Unit =
    assertFalse("abc is NOT a palindrome", isPalindrome("abc"))
    assertTrue("kayak is a palindrome", isPalindrome("kayak"))
    assertTrue("racecar is a palindrome", isPalindrome("racecar"))
