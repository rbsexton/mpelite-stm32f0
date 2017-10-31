This is the sockpuppet supervisor layer.  

Release 0.1
 Basic feature set.  Supports a single USB-CDC channel on stream 10,
 with blocking IO and support for TICKS.  The USB interface is rudimentary,
 and contains no performance enhancements.

------------------------------------------------

Derived from the ST Micro Cube distribution: STM32Cube_FW_F0_V1.8.0

The supervisor itself is derived from 
Projects/STM32072B_EVAL/Applications/USB_Device/CDC_Standalone

----------------- Building the Supervisor --------------
Pre-built ARM gcc toolchains are avaiable here:

https://launchpad.net/gcc-arm-embedded

Note that the path to gcc is embedded in the makefile

--------------------------------------------------------
Conversion from the ST CDC Demo to Sockpuppet

The ST libs use a UART Transmission complete callback.   This
triggers the Nextpacket process - acceptance of USB OUT Packets.

Incoming packets trigger CDC_Itf_Receive(uint8_t* Buf, uint32_t *Len).
This saves buf and len.

void HAL_UART_TxCpltCallback(UART_HandleTypeDef *huart)
{
  /* Initiate next USB packet transfer once UART completes transfer (transmitting data over Tx line) */
  USBD_CDC_ReceivePacket(&USBD_Device);
}

ST's Libary uses a timer to trigger transmission:
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim) {}


