This is a port of MPE-Lite for Cortex-M0 to the ST Micro 
SMT32F072R Discovery board.  It makes use of the Sockpuppet
layer for interfacing between the board-support layer (supervisor)
and the application written in forth.

The supervisor is supplied in binary form, and can be re-compiled
from source with GNU GCC for arm.   See the supervisor dir for details

## How to Install
- Install the MPE Lite compiler
- Clone this into the MPELight CortexLite Directory, along with the submodules:
  - git clone --recursive https://github.com/rbsexton/mpelite-stm32f0.git

## Applications:
hello : Hello World.  No features to speak of, just a prompt.

## How to Build with Wine:
- Start Wine Shell.
- cd ./xArmCortexLite/CortexLite/mpelite-stm32f0/hello
- wine <path>/xArmCortexLite.exe include STM32F072.ctl


## Flashing images 
You'll need some sort of tool for installing images via DFU.

For Linux and Mac, you can use dfu-util.

1. Connect the BOOT0 pin to VDD with a jumper and reset the board.
2. Remove the jumper.  The board will stay in DFU mode.
3. Launch your dfu utility. Example: *dfu-util -s 0x8000000 -a 0 -D STM32F072.img*
4. After the board loads the image, press the reset button and connect to it with your
   terminal emulator.

# Communicating with the board

The board supervisor contains a USB CDC driver and acts like a serial port.  Connect to it
with the terminal emulator of your choice.


Advanced features - 
Supports run-time installation of system calls.



