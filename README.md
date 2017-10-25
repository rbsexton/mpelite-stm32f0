This is a port of MPE-Lite for Cortex-M0 to the ST Micro 
SMT32F072R Discovery board.  It makes use of the Sockpuppet
layer for interfacing between the board-support layer (supervisor)
and the application written in forth.

The supervisor is supplied in binary form, and can be re-compiled
from source with GNU GCC for arm.  

-------------------------------------
Applications:
hello - Hello World. 

-------------------------------------
How to Build 
- Install the MPE Lite compiler
- Copy over the MPE Files from CortexLight 




-------------------------------------
Configuring the STMF0-Discovery Board
CN4/CB5 - ST-Link Jumpers - Either

Hook up USB-User




Advanced features - 
Supports run-time installation of interrupt vectors.
Supports run-time installation of system calls.



