package wiringpi

import _root_.scala.scalanative.unsafe.*
import _root_.scala.scalanative.unsigned.*
import _root_.scala.scalanative.libc.*
import _root_.scala.scalanative.*

object predef:
    private[wiringpi] trait _BindgenEnumCInt[T](using eq: T =:= CInt):
      given Tag[T] = Tag.Int.asInstanceOf[Tag[T]]
      extension (inline t: T)
        inline def value: CInt = eq.apply(t)
        inline def int: CInt = eq.apply(t).toInt
    private[wiringpi] trait _BindgenEnumCUnsignedInt[T](using eq: T =:= CUnsignedInt):
      given Tag[T] = Tag.UInt.asInstanceOf[Tag[T]]
      extension (inline t: T)
        inline def value: CUnsignedInt = eq.apply(t)
        inline def int: CInt = eq.apply(t).toInt
        inline def uint: CUnsignedInt = eq.apply(t)

// Defines [Manual]
object definitions:
  // Wiring Pi modes
  final val WPI_MODE_PINS             = 0
  final val WPI_MODE_GPIO             = 1
  final val WPI_MODE_GPIO_SYS         = 2  // deprecated since 3.2
  final val WPI_MODE_PHYS             = 3
  final val WPI_MODE_PIFACE           = 4
  final val WPI_MODE_GPIO_DEVICE_BCM  = 5  // BCM pin numbers like WPI_MODE_GPIO
  final val WPI_MODE_GPIO_DEVICE_WPI  = 6  // WiringPi pin numbers like WPI_MODE_PINS
  final val WPI_MODE_GPIO_DEVICE_PHYS = 7  // Physic pin numbers like WPI_MODE_PHYS
  final val WPI_MODE_UNINITIALISED    = -1

  // Pin modes

  final val INPUT            = 0
  final val OUTPUT           = 1
  final val PWM_OUTPUT       = 2
  final val PWM_MS_OUTPUT    = 8
  final val PWM_BAL_OUTPUT   = 9
  final val GPIO_CLOCK       = 3
  final val SOFT_PWM_OUTPUT  = 4
  final val SOFT_TONE_OUTPUT = 5
  final val PWM_TONE_OUTPUT  = 6
  final val PM_OFF           = 7   // to input / release line

  final val LOW  = 0
  final val HIGH = 1

  // Pull up/down/none

  final val PUD_OFF  = 0
  final val PUD_DOWN = 1
  final val PUD_UP   = 2

  // PWM

  final val PWM_MODE_MS  = 0
  final val PWM_MODE_BAL = 1

  // Interrupt levels

  final val INT_EDGE_SETUP   = 0
  final val INT_EDGE_FALLING = 1
  final val INT_EDGE_RISING  = 2
  final val INT_EDGE_BOTH    = 3

object enumerations:
  import predef.*
  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  opaque type WPIPinAlt = CInt
  object WPIPinAlt extends _BindgenEnumCInt[WPIPinAlt]:
    given _tag: Tag[WPIPinAlt] = Tag.Int
    inline def define(inline a: CInt): WPIPinAlt = a
    val WPI_ALT_UNKNOWN = define(-1)
    val WPI_ALT_INPUT = define(0)
    val WPI_ALT_OUTPUT = define(1)
    val WPI_ALT5 = define(2)
    val WPI_ALT4 = define(3)
    val WPI_ALT0 = define(4)
    val WPI_ALT1 = define(5)
    val WPI_ALT2 = define(6)
    val WPI_ALT3 = define(7)
    val WPI_ALT6 = define(8)
    val WPI_ALT7 = define(9)
    val WPI_ALT8 = define(10)
    val WPI_ALT9 = define(11)
    val WPI_NONE = define(31)
    def getName(value: WPIPinAlt): Option[String] =
      value match
        case `WPI_ALT_UNKNOWN` => Some("WPI_ALT_UNKNOWN")
        case `WPI_ALT_INPUT` => Some("WPI_ALT_INPUT")
        case `WPI_ALT_OUTPUT` => Some("WPI_ALT_OUTPUT")
        case `WPI_ALT5` => Some("WPI_ALT5")
        case `WPI_ALT4` => Some("WPI_ALT4")
        case `WPI_ALT0` => Some("WPI_ALT0")
        case `WPI_ALT1` => Some("WPI_ALT1")
        case `WPI_ALT2` => Some("WPI_ALT2")
        case `WPI_ALT3` => Some("WPI_ALT3")
        case `WPI_ALT6` => Some("WPI_ALT6")
        case `WPI_ALT7` => Some("WPI_ALT7")
        case `WPI_ALT8` => Some("WPI_ALT8")
        case `WPI_ALT9` => Some("WPI_ALT9")
        case `WPI_NONE` => Some("WPI_NONE")
        case _ => _root_.scala.None
    extension (a: WPIPinAlt)
      inline def &(b: WPIPinAlt): WPIPinAlt = a & b
      inline def |(b: WPIPinAlt): WPIPinAlt = a | b
      inline def is(b: WPIPinAlt): Boolean = (a & b) == b

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  opaque type WPIPinType = CUnsignedInt
  object WPIPinType extends _BindgenEnumCUnsignedInt[WPIPinType]:
    given _tag: Tag[WPIPinType] = Tag.UInt
    inline def define(inline a: Long): WPIPinType = a.toUInt
    val WPI_PIN_BCM = define(1)
    val WPI_PIN_WPI = define(2)
    val WPI_PIN_PHYS = define(3)
    def getName(value: WPIPinType): Option[String] =
      value match
        case `WPI_PIN_BCM` => Some("WPI_PIN_BCM")
        case `WPI_PIN_WPI` => Some("WPI_PIN_WPI")
        case `WPI_PIN_PHYS` => Some("WPI_PIN_PHYS")
        case _ => _root_.scala.None
    extension (a: WPIPinType)
      inline def &(b: WPIPinType): WPIPinType = a & b
      inline def |(b: WPIPinType): WPIPinType = a | b
      inline def is(b: WPIPinType): Boolean = (a & b) == b

object structs:
  import _root_.wiringpi.enumerations.*
  import _root_.wiringpi.predef.*
  import _root_.wiringpi.structs.*

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  opaque type WPIWfiStatus = CStruct4[CInt, CUnsignedInt, CInt, CLongLong]
  
  object WPIWfiStatus:
    given _tag: Tag[WPIWfiStatus] = Tag.materializeCStruct4Tag[CInt, CUnsignedInt, CInt, CLongLong]
    
    // Allocates WPIWfiStatus on the heap – fields are not initalised or zeroed out
    def apply()(using Zone): Ptr[WPIWfiStatus] = scala.scalanative.unsafe.alloc[WPIWfiStatus](1)
    def apply(statusOK : CInt, pinBCM : CUnsignedInt, edge : CInt, timeStamp_us : CLongLong)(using Zone): Ptr[WPIWfiStatus] =
      val ____ptr = apply()
      (!____ptr).statusOK = statusOK
      (!____ptr).pinBCM = pinBCM
      (!____ptr).edge = edge
      (!____ptr).timeStamp_us = timeStamp_us
      ____ptr
    
    extension (struct: WPIWfiStatus)
      def statusOK : CInt = struct._1
      def statusOK_=(value: CInt): Unit = !struct.at1 = value
      def pinBCM : CUnsignedInt = struct._2
      def pinBCM_=(value: CUnsignedInt): Unit = !struct.at2 = value
      def edge : CInt = struct._3
      def edge_=(value: CInt): Unit = !struct.at3 = value
      def timeStamp_us : CLongLong = struct._4
      def timeStamp_us_=(value: CLongLong): Unit = !struct.at4 = value
    

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  opaque type wiringPiNodeStruct = CStruct15[CInt, CInt, CInt, CUnsignedInt, CUnsignedInt, CUnsignedInt, CUnsignedInt, CFuncPtr3[Ptr[Byte], CInt, CInt, Unit], CFuncPtr3[Ptr[Byte], CInt, CInt, Unit], CFuncPtr2[Ptr[Byte], CInt, CInt], CFuncPtr3[Ptr[Byte], CInt, CInt, Unit], CFuncPtr3[Ptr[Byte], CInt, CInt, Unit], CFuncPtr2[Ptr[Byte], CInt, CInt], CFuncPtr3[Ptr[Byte], CInt, CInt, Unit], Ptr[Byte]]
  
  object wiringPiNodeStruct:
    given _tag: Tag[wiringPiNodeStruct] = Tag.materializeCStruct15Tag[CInt, CInt, CInt, CUnsignedInt, CUnsignedInt, CUnsignedInt, CUnsignedInt, CFuncPtr3[Ptr[Byte], CInt, CInt, Unit], CFuncPtr3[Ptr[Byte], CInt, CInt, Unit], CFuncPtr2[Ptr[Byte], CInt, CInt], CFuncPtr3[Ptr[Byte], CInt, CInt, Unit], CFuncPtr3[Ptr[Byte], CInt, CInt, Unit], CFuncPtr2[Ptr[Byte], CInt, CInt], CFuncPtr3[Ptr[Byte], CInt, CInt, Unit], Ptr[Byte]]
    
    // Allocates wiringPiNodeStruct on the heap – fields are not initalised or zeroed out
    def apply()(using Zone): Ptr[wiringPiNodeStruct] = scala.scalanative.unsafe.alloc[wiringPiNodeStruct](1)
    def apply(pinBase : CInt, pinMax : CInt, fd : CInt, data0 : CUnsignedInt, data1 : CUnsignedInt, data2 : CUnsignedInt, data3 : CUnsignedInt, pinMode : CFuncPtr3[Ptr[wiringPiNodeStruct], CInt, CInt, Unit], pullUpDnControl : CFuncPtr3[Ptr[wiringPiNodeStruct], CInt, CInt, Unit], digitalRead : CFuncPtr2[Ptr[wiringPiNodeStruct], CInt, CInt], digitalWrite : CFuncPtr3[Ptr[wiringPiNodeStruct], CInt, CInt, Unit], pwmWrite : CFuncPtr3[Ptr[wiringPiNodeStruct], CInt, CInt, Unit], analogRead : CFuncPtr2[Ptr[wiringPiNodeStruct], CInt, CInt], analogWrite : CFuncPtr3[Ptr[wiringPiNodeStruct], CInt, CInt, Unit], next : Ptr[wiringPiNodeStruct])(using Zone): Ptr[wiringPiNodeStruct] =
      val ____ptr = apply()
      (!____ptr).pinBase = pinBase
      (!____ptr).pinMax = pinMax
      (!____ptr).fd = fd
      (!____ptr).data0 = data0
      (!____ptr).data1 = data1
      (!____ptr).data2 = data2
      (!____ptr).data3 = data3
      (!____ptr).pinMode = pinMode
      (!____ptr).pullUpDnControl = pullUpDnControl
      (!____ptr).digitalRead = digitalRead
      (!____ptr).digitalWrite = digitalWrite
      (!____ptr).pwmWrite = pwmWrite
      (!____ptr).analogRead = analogRead
      (!____ptr).analogWrite = analogWrite
      (!____ptr).next = next
      ____ptr
    
    extension (struct: wiringPiNodeStruct)
      def pinBase : CInt = struct._1
      def pinBase_=(value: CInt): Unit = !struct.at1 = value
      def pinMax : CInt = struct._2
      def pinMax_=(value: CInt): Unit = !struct.at2 = value
      def fd : CInt = struct._3
      def fd_=(value: CInt): Unit = !struct.at3 = value
      def data0 : CUnsignedInt = struct._4
      def data0_=(value: CUnsignedInt): Unit = !struct.at4 = value
      def data1 : CUnsignedInt = struct._5
      def data1_=(value: CUnsignedInt): Unit = !struct.at5 = value
      def data2 : CUnsignedInt = struct._6
      def data2_=(value: CUnsignedInt): Unit = !struct.at6 = value
      def data3 : CUnsignedInt = struct._7
      def data3_=(value: CUnsignedInt): Unit = !struct.at7 = value
      def pinMode : CFuncPtr3[Ptr[wiringPiNodeStruct], CInt, CInt, Unit] = struct._8.asInstanceOf[CFuncPtr3[Ptr[wiringPiNodeStruct], CInt, CInt, Unit]]
      def pinMode_=(value: CFuncPtr3[Ptr[wiringPiNodeStruct], CInt, CInt, Unit]): Unit = !struct.at8 = value.asInstanceOf[CFuncPtr3[Ptr[Byte], CInt, CInt, Unit]]
      def pullUpDnControl : CFuncPtr3[Ptr[wiringPiNodeStruct], CInt, CInt, Unit] = struct._9.asInstanceOf[CFuncPtr3[Ptr[wiringPiNodeStruct], CInt, CInt, Unit]]
      def pullUpDnControl_=(value: CFuncPtr3[Ptr[wiringPiNodeStruct], CInt, CInt, Unit]): Unit = !struct.at9 = value.asInstanceOf[CFuncPtr3[Ptr[Byte], CInt, CInt, Unit]]
      def digitalRead : CFuncPtr2[Ptr[wiringPiNodeStruct], CInt, CInt] = struct._10.asInstanceOf[CFuncPtr2[Ptr[wiringPiNodeStruct], CInt, CInt]]
      def digitalRead_=(value: CFuncPtr2[Ptr[wiringPiNodeStruct], CInt, CInt]): Unit = !struct.at10 = value.asInstanceOf[CFuncPtr2[Ptr[Byte], CInt, CInt]]
      def digitalWrite : CFuncPtr3[Ptr[wiringPiNodeStruct], CInt, CInt, Unit] = struct._11.asInstanceOf[CFuncPtr3[Ptr[wiringPiNodeStruct], CInt, CInt, Unit]]
      def digitalWrite_=(value: CFuncPtr3[Ptr[wiringPiNodeStruct], CInt, CInt, Unit]): Unit = !struct.at11 = value.asInstanceOf[CFuncPtr3[Ptr[Byte], CInt, CInt, Unit]]
      def pwmWrite : CFuncPtr3[Ptr[wiringPiNodeStruct], CInt, CInt, Unit] = struct._12.asInstanceOf[CFuncPtr3[Ptr[wiringPiNodeStruct], CInt, CInt, Unit]]
      def pwmWrite_=(value: CFuncPtr3[Ptr[wiringPiNodeStruct], CInt, CInt, Unit]): Unit = !struct.at12 = value.asInstanceOf[CFuncPtr3[Ptr[Byte], CInt, CInt, Unit]]
      def analogRead : CFuncPtr2[Ptr[wiringPiNodeStruct], CInt, CInt] = struct._13.asInstanceOf[CFuncPtr2[Ptr[wiringPiNodeStruct], CInt, CInt]]
      def analogRead_=(value: CFuncPtr2[Ptr[wiringPiNodeStruct], CInt, CInt]): Unit = !struct.at13 = value.asInstanceOf[CFuncPtr2[Ptr[Byte], CInt, CInt]]
      def analogWrite : CFuncPtr3[Ptr[wiringPiNodeStruct], CInt, CInt, Unit] = struct._14.asInstanceOf[CFuncPtr3[Ptr[wiringPiNodeStruct], CInt, CInt, Unit]]
      def analogWrite_=(value: CFuncPtr3[Ptr[wiringPiNodeStruct], CInt, CInt, Unit]): Unit = !struct.at14 = value.asInstanceOf[CFuncPtr3[Ptr[Byte], CInt, CInt, Unit]]
      def next : Ptr[wiringPiNodeStruct] = struct._15.asInstanceOf[Ptr[wiringPiNodeStruct]]
      def next_=(value: Ptr[wiringPiNodeStruct]): Unit = !struct.at15 = value.asInstanceOf[Ptr[Byte]]
    


@extern
@link("wiringPi") // [Manual]
private[wiringpi] object extern_functions:
  import _root_.wiringpi.enumerations.*
  import _root_.wiringpi.predef.*
  import _root_.wiringpi.structs.*

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def analogRead(pin : CInt): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def analogWrite(pin : CInt, value : CInt): Unit = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def delay(ms : CUnsignedInt): Unit = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def delayMicroseconds(us : CUnsignedInt): Unit = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def digitalRead(pin : CInt): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def digitalReadByte(): CUnsignedInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def digitalReadByte2(): CUnsignedInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def digitalWrite(pin : CInt, value : CInt): Unit = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def digitalWriteByte(value : CInt): Unit = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def digitalWriteByte2(value : CInt): Unit = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def getAlt(pin : CInt): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def getPinModeAlt(pin : CInt): WPIPinAlt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def gpioClockSet(pin : CInt, freq : CInt): Unit = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def micros(): CUnsignedInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def millis(): CUnsignedInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def physPinToGpio(physPin : CInt): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def piBoard40Pin(): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def piBoardId(model : Ptr[CInt], rev : Ptr[CInt], mem : Ptr[CInt], maker : Ptr[CInt], overVolted : Ptr[CInt]): Unit = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def piBoardRev(): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def piGpioLayout(): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def piGpioLayoutOops(why : Ptr[CUnsignedChar]): Unit = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def piHiPri(pri : CInt): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def piLock(key : CInt): Unit = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def piMicros64(): CUnsignedLongLong = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def piRP1Model(): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def piThreadCreate(fn : CFuncPtr1[Ptr[Byte], Ptr[Byte]]): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def piUnlock(key : CInt): Unit = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def pinMode(pin : CInt, mode : CInt): Unit = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def pinModeAlt(pin : CInt, mode : CInt): Unit = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def pullUpDnControl(pin : CInt, pud : CInt): Unit = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def pwmSetClock(divisor : CInt): Unit = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def pwmSetMode(mode : CInt): Unit = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def pwmSetRange(range : CUnsignedInt): Unit = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def pwmToneWrite(pin : CInt, freq : CInt): Unit = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def pwmWrite(pin : CInt, value : CInt): Unit = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def setPadDrive(group : CInt, value : CInt): Unit = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def setPadDrivePin(pin : CInt, value : CInt): Unit = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def waitForInterruptClose(pin : CInt): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def wiringPiFailure(fatal : CInt, message : Ptr[CUnsignedChar], rest: Any*): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def wiringPiFindNode(pin : CInt): Ptr[wiringPiNodeStruct] = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def wiringPiGlobalMemoryAccess(): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def wiringPiGpioDeviceGetFd(): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def wiringPiISR(pin : CInt, mode : CInt, function : CFuncPtr0[Unit]): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def wiringPiISR2(pin : CInt, edgeMode : CInt, function : CFuncPtr2[WPIWfiStatus, Ptr[Byte], Unit], debounce_period_us : CUnsignedLongInt, userdata : Ptr[Byte]): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def wiringPiISRStop(pin : CInt): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def wiringPiNewNode(pinBase : CInt, numPins : CInt): Ptr[wiringPiNodeStruct] = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def wiringPiSetup(): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def wiringPiSetupGpio(): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def wiringPiSetupGpioDevice(pinType : WPIPinType): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def wiringPiSetupPhys(): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def wiringPiSetupPiFace(): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def wiringPiSetupPiFaceForGpioProg(): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def wiringPiSetupPinType(pinType : WPIPinType): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def wiringPiSetupSys(): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def wiringPiUserLevelAccess(): CInt = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def wiringPiVersion(major : Ptr[CInt], minor : Ptr[CInt]): Unit = extern

  /**
   * [bindgen] header: /usr/include/wiringPi.h
  */
  def wpiPinToGpio(wpiPin : CInt): CInt = extern


object functions:
  import _root_.wiringpi.enumerations.*
  import _root_.wiringpi.predef.*
  import _root_.wiringpi.structs.*
  import extern_functions.*
  export extern_functions.*

object types:
    export _root_.wiringpi.structs.*
    export _root_.wiringpi.enumerations.*

object all:
  export _root_.wiringpi.definitions.*
  export _root_.wiringpi.enumerations.WPIPinAlt
  export _root_.wiringpi.enumerations.WPIPinType
  export _root_.wiringpi.structs.WPIWfiStatus
  export _root_.wiringpi.structs.wiringPiNodeStruct
  export _root_.wiringpi.functions.analogRead
  export _root_.wiringpi.functions.analogWrite
  export _root_.wiringpi.functions.delay
  export _root_.wiringpi.functions.delayMicroseconds
  export _root_.wiringpi.functions.digitalRead
  export _root_.wiringpi.functions.digitalReadByte
  export _root_.wiringpi.functions.digitalReadByte2
  export _root_.wiringpi.functions.digitalWrite
  export _root_.wiringpi.functions.digitalWriteByte
  export _root_.wiringpi.functions.digitalWriteByte2
  export _root_.wiringpi.functions.getAlt
  export _root_.wiringpi.functions.getPinModeAlt
  export _root_.wiringpi.functions.gpioClockSet
  export _root_.wiringpi.functions.micros
  export _root_.wiringpi.functions.millis
  export _root_.wiringpi.functions.physPinToGpio
  export _root_.wiringpi.functions.piBoard40Pin
  export _root_.wiringpi.functions.piBoardId
  export _root_.wiringpi.functions.piBoardRev
  export _root_.wiringpi.functions.piGpioLayout
  export _root_.wiringpi.functions.piGpioLayoutOops
  export _root_.wiringpi.functions.piHiPri
  export _root_.wiringpi.functions.piLock
  export _root_.wiringpi.functions.piMicros64
  export _root_.wiringpi.functions.piRP1Model
  export _root_.wiringpi.functions.piThreadCreate
  export _root_.wiringpi.functions.piUnlock
  export _root_.wiringpi.functions.pinMode
  export _root_.wiringpi.functions.pinModeAlt
  export _root_.wiringpi.functions.pullUpDnControl
  export _root_.wiringpi.functions.pwmSetClock
  export _root_.wiringpi.functions.pwmSetMode
  export _root_.wiringpi.functions.pwmSetRange
  export _root_.wiringpi.functions.pwmToneWrite
  export _root_.wiringpi.functions.pwmWrite
  export _root_.wiringpi.functions.setPadDrive
  export _root_.wiringpi.functions.setPadDrivePin
  export _root_.wiringpi.functions.waitForInterruptClose
  export _root_.wiringpi.functions.wiringPiFailure
  export _root_.wiringpi.functions.wiringPiFindNode
  export _root_.wiringpi.functions.wiringPiGlobalMemoryAccess
  export _root_.wiringpi.functions.wiringPiGpioDeviceGetFd
  export _root_.wiringpi.functions.wiringPiISR
  export _root_.wiringpi.functions.wiringPiISR2
  export _root_.wiringpi.functions.wiringPiISRStop
  export _root_.wiringpi.functions.wiringPiNewNode
  export _root_.wiringpi.functions.wiringPiSetup
  export _root_.wiringpi.functions.wiringPiSetupGpio
  export _root_.wiringpi.functions.wiringPiSetupGpioDevice
  export _root_.wiringpi.functions.wiringPiSetupPhys
  export _root_.wiringpi.functions.wiringPiSetupPiFace
  export _root_.wiringpi.functions.wiringPiSetupPiFaceForGpioProg
  export _root_.wiringpi.functions.wiringPiSetupPinType
  export _root_.wiringpi.functions.wiringPiSetupSys
  export _root_.wiringpi.functions.wiringPiUserLevelAccess
  export _root_.wiringpi.functions.wiringPiVersion
  export _root_.wiringpi.functions.wpiPinToGpio