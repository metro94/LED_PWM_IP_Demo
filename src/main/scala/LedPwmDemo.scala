import spinal.core._
import spinal.lib.com.uart._
import spinal.lib.fsm._

class SB_LEDDA_IP extends BlackBox {
    val io = new Bundle {
        val LEDDRST   = in  Bool
        val LEDDCLK   = in  Bool
        val LEDDCS    = in  Bool
        val LEDDDEN   = in  Bool
        val LEDDADDR3 = in  Bool
        val LEDDADDR2 = in  Bool
        val LEDDADDR1 = in  Bool
        val LEDDADDR0 = in  Bool
        val LEDDDAT7  = in  Bool
        val LEDDDAT6  = in  Bool
        val LEDDDAT5  = in  Bool
        val LEDDDAT4  = in  Bool
        val LEDDDAT3  = in  Bool
        val LEDDDAT2  = in  Bool
        val LEDDDAT1  = in  Bool
        val LEDDDAT0  = in  Bool
        val LEDDEXE   = in  Bool
        val LEDDON    = out Bool
        val PWMOUT0   = out Bool
        val PWMOUT1   = out Bool
        val PWMOUT2   = out Bool
    }

    def setAddrFromBits(d: Bits) = {
        io.LEDDADDR3 := d(3)
        io.LEDDADDR2 := d(2)
        io.LEDDADDR1 := d(1)
        io.LEDDADDR0 := d(0)
    }

    def setDatFromBits(d: Bits) = {
        io.LEDDDAT7 := d(7)
        io.LEDDDAT6 := d(6)
        io.LEDDDAT5 := d(5)
        io.LEDDDAT4 := d(4)
        io.LEDDDAT3 := d(3)
        io.LEDDDAT2 := d(2)
        io.LEDDDAT1 := d(1)
        io.LEDDDAT0 := d(0)
    }

    def setPwmToBits(d: Bits) = {
        d(0) := io.PWMOUT0
        d(1) := io.PWMOUT1
        d(2) := io.PWMOUT2
    }

    noIoPrefix()
    mapClockDomain(clock = io.LEDDCLK, reset = io.LEDDRST)
}

class SB_RGBA_DRV(current: Array[Int]) extends BlackBox {
    def setGeneric(current: Array[Int]) : Unit = {
        var step = 2

        if (current.filter(_ > 12).length > 0)
            step = 4

        addGeneric("CURRENT_MODE", if (step == 2) "0b1" else "0b0")

        for (i <- 0 until 3) {
            val t = current(i) / step
            if (t * step != current(i) || t < 0 || t > 6)
                throw new IllegalArgumentException("Cannot set current value for RGB" + i + "_CURRENT")
            addGeneric("RGB" + i + "_CURRENT", t match {
                case 0 => "0b000000"
                case 1 => "0b000001"
                case 2 => "0b000011"
                case 3 => "0b000111"
                case 4 => "0b001111"
                case 5 => "0b011111"
                case 6 => "0b111111"
            })
        }
    }

    setGeneric(current)

    val io = new Bundle {
        val CURREN   = in  Bool
        val RGBLEDEN = in  Bool
        val RGB0PWM  = in  Bool
        val RGB1PWM  = in  Bool
        val RGB2PWM  = in  Bool
        val RGB0     = out Bool
        val RGB1     = out Bool
        val RGB2     = out Bool
    }

    def setPwmFromBits(d: Bits) = {
        io.RGB0PWM := d(0)
        io.RGB1PWM := d(1)
        io.RGB2PWM := d(2)
    }

    def setRgbToBits(d: Bits) = {
        d(0) := io.RGB0
        d(1) := io.RGB1
        d(2) := io.RGB2
    }

    noIoPrefix()
}

class LedPwmDemo extends Component {
    val io = new Bundle {
        val rxd = in  Bool
        val pwm = out Bits(3 bits)
        val led = out Bits(3 bits)
    }

    val uartCtrl = new UartCtrl()
    val ledPwm = new SB_LEDDA_IP
    val ledDrv = new SB_RGBA_DRV(Array(24, 24, 24))

    val ipAddr = Reg(Bits(8 bits)) init(0)
    val ipData = Reg(Bits(8 bits)) init(0)
    val writeEn = Bool
    val blink = Reg(Bool) init(False)

    uartCtrl.io.config.setClockDivider(115200 Hz)
    uartCtrl.io.config.frame.dataLength := 8-1
    uartCtrl.io.config.frame.parity := UartParityType.NONE
    uartCtrl.io.config.frame.stop := UartStopType.ONE
    uartCtrl.io.uart.rxd := io.rxd

    val fsm = new StateMachine {
        val READ_ADDR = new State with EntryPoint
        val READ_DATA = new State
        val WRITE_PWM = new State

        uartCtrl.io.read.ready := False
        writeEn := False

        READ_ADDR.whenIsActive {
            uartCtrl.io.read.ready := True
            when (uartCtrl.io.read.valid) {
                ipAddr := uartCtrl.io.read.payload
                goto(READ_DATA)
            }
        }

        READ_DATA.whenIsActive {
            uartCtrl.io.read.ready := True
            when (uartCtrl.io.read.valid) {
                ipData := uartCtrl.io.read.payload
                goto(WRITE_PWM)
            }
        }

        WRITE_PWM.whenIsActive {
            when (ipAddr(7 downto 4) === B"4'b0000") {
                writeEn := True
            }.otherwise {
                blink := ipData.orR
            }
            goto(READ_ADDR)
        }
    }

    ledPwm.io.LEDDCS := writeEn
    ledPwm.io.LEDDDEN := writeEn
    ledPwm.io.LEDDEXE := blink
    ledPwm.io.LEDDON  <> ledDrv.io.RGBLEDEN
    ledPwm.io.PWMOUT0 <> ledDrv.io.RGB1PWM // R
    ledPwm.io.PWMOUT1 <> ledDrv.io.RGB2PWM // G
    ledPwm.io.PWMOUT2 <> ledDrv.io.RGB0PWM // B
    ledPwm.setAddrFromBits(ipAddr(3 downto 0))
    ledPwm.setDatFromBits(ipData)
    ledPwm.setPwmToBits(io.pwm)

    ledDrv.io.CURREN := True
    ledDrv.setRgbToBits(io.led)

    noIoPrefix()
}

object Main {
    def main(args: Array[String]) {
        SpinalConfig(
            mode = Verilog,
            defaultClockDomainFrequency = FixedFrequency(12 MHz)
        ).generate(new LedPwmDemo)
    }
}
