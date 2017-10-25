\ STM32F072.ctl - STM32F072RB discovery board sockpuppet-based forth.
\ Flash this into your board with the built-in DFU utility.

((
To do
=====

Change history
==============
20171021 RBS First Release.
))



only forth definitions  decimal


\ **************************
\ *S Define directory macros
\ **************************
\ *P The MPE cross compilers contain a useful text macro system.
\ ** Macros allow easy porting of control files when projects are
\ ** moved from their default locations. Each directory macro
\ ** defines where a particular set of files are located.

\ *[
c" ."			setmacro AppDir		\ application files
c" ."			setmacro HwDir		\ Board hardware files
c" ../CortexLite"	setmacro CpuDir		\ CPU specific files

c" ../../sockpuppet" setmacro SockPuppet \ Sockpuppet files.

\ *]


\ *****************************
\ *S Turn on the cross compiler
\ *****************************

\ *[

include %CpuDir%/Macros		\ macros needed by the cross-compiler

CROSS-COMPILE			\ Turn host Forth into a cross-compiler

only forth definitions          \ default search order

  no-log                        \ uncomment to suppress output log
  rommed                        \ split ROM/RAM target
  interactive                   \ enter interactive mode at end
  +xrefs			\ enable cross references
  align-long                    \ code is 32bit aligned
  Cortex-M0			\ Thumb2 processor type and register usage
  -LongCalls			\ no calls outside 25 bit range
  +FlashCompile			\ target compiles to Flash
  \ Hex-I32			\ also produce Intel Hex-32 obj format
  +SaveCdataOnly		\ no data area image files

0 equ false
-1 equ true

\ *]

\ *******************
\ *S Configure target
\ *******************

#64 cells equ /ExcVecs	\ -- len
\ *G Size of the exception/interrupt vector table. There are
\ ** 16 slots reserved by ARM.

\ =============
\ *N Memory map
\ =============
\ *P If you are using the *\fo{Reflash} code in the *\i{ReProg}
\ ** folder, note that the Flash reprogramming code uses RAM
\ ** from $2000:0000..$2000:0FFF and its mirrors. Ensure that
\ ** your stacks are outside this region.

\ *P The Flash memory starts at $0800:0000.
\ ** The Bottom 32k is reserved for the supervisor.
\ ** This part has 16k of memory, half of which is reserved 
\ ** for the supervisor.




\ *[
  $0800:0000 $0800:7FFF cdata section Sup	\ Supervisor goes here.
  data-file ../supervisor/exe/supervisor.bin

  \ Its necessary to pad things out.  For now...
  $8000 swap  - allot \ CRITICAL!!!!

  $0800:8000 $0801:FFFF cdata section STM32F072	\ code
  $2000:2000 $2000:2FFF udata section PROGu	\ 4k UDATA RAM
  $2000:3000 $2000:3FFF idata section PROGd	\ 4k IDATA RAM

interpreter
: prog STM32F072  ;		\ synonym
target

PROG PROGd PROGu  CDATA		\ use Code for HERE , and so on

\ *]

\ ============================
\ *N Stack and user area sizes
\ ============================

\ *[
$0F0 equ UP-SIZE		\ size of each task's user area
$0F0 equ SP-SIZE		\ size of each task's data stack
$0100 equ RP-SIZE		\ size of each task's return stack
up-size rp-size + sp-size +
  equ task-size			\ size of TASK data area
\ define the number of cells of guard space at the top of the data stack
#2 equ sp-guard			\ can underflow the data stack by this amount

$0100 equ TIB-LEN		\ terminal i/p buffer length

\ define nesting levels for interrupts and SWIs.
1 equ #IRQs			\ number of IRQ stacks,
				\ shared by all IRQs (1 min)
0 equ #SVCs			\ number of SVC nestings permitted
				\ 0 is ok if SVCs are unused
\ *]

\ ==========================
\ *N Serial and ticker rates
\ ==========================

1 equ useUSART10?	\ -- n
10 equ console-port	\ -- n ; Designate serial port for terminal (0..n).
\ *G Ports 1..4 are the on-chip UARTs. The internal USB device
\ ** is port 10, and bit-banged ports are defined from 20 onwards.

#1 equ tick-ms		\ -- ms
\ *G Timebase tick in ms.

\ =====================
\ *N Software selection
\ =====================
\ *P With 128 kb of Flash we can select a comfortable set of
\ ** software and still have plenty of space for application
\ ** code.

\ *[
 0 equ Tiny?			\ nz to make a minimal kernel.
 1 equ ColdChain?		\ nz to use cold chain mechanism
 1 equ tasking?			\ true if multitasker needed
   6 cells equ tcb-size		\   for internal consistency check
 0 equ timebase?		\ true for TIMEBASE code
 0 equ softfp?			\ true for software floating point
 0 equ FullCase?		\ true to include ?OF END-CASE NEXTCASE extensions
 0 equ target-locals?		\ true if target local variable sources needed
 0 equ romforth?		\ true for ROMForth handler
 0 equ blocks?			\ true if BLOCK needed
 $0000 equ sizeofheap		\ 0=no heap, nz=size of heap
   1 equ heap-diags?		\   true to include diagnostic code
 0 equ paged?			\ true if ROM or RAM is paged/banked
\ *]


\ *****************
\ default constants
\ *****************

cell equ cell				\ size of a cell (16 bits)
0 equ false
-1 equ true


\ ***************
\ *S Kernel files
\ ***************

\ *[
  include %CpuDir%/CM0def		\ Cortex generic equates and SFRs
  include %CpuDir%/StackDef		\ Reserve default task and stacks
PROGd  sec-top 1+ equ UNUSED-TOP  PROG	\ top of memory for UNUSED
  include %AppDir%/startSTM32F072	\ start up code
l: crcslot
  0 ,					\ the kernel CRC
l: crcstart
  include %CpuDir%/CodeM0lite		\ low level kernel definitions
  include %CpuDir%/kernel72lite		\ high level kernel definitions
\ include %CpuDir%/Drivers/rebootSTM32	\ reboot using watchdog
\  include %CpuDir%/IntCortex		\ interrupt handlers for NVIC
\  include %CpuDir%/FaultCortex		\ fault exception handlers for NVIC
\ *]

\ *[
  include %CpuDir%/Dump			\ DUMP .S etc development tools

  \ include %CpuDir%/Drivers/gpioSTM32F0xx \ easy pin access
  \ include %CpuDir%/Drivers/SysTickDisco072

tasking? [if]
  include %CpuDir%/MultiCM0lite		\ multitasker
[then]

\ *]


\ *************
\ *S End of kernel
\ *************
\ *P After the main kernel has been built, some version data is
\ ** laid down for use by the sign-on code.

\ *[

buildfile STM32F072.no
l: version$
  build$,
l: BuildDate$
  DateTime$,

internal
: .banner	\ --
  cr ." ****************************"
;

\ Keep this very short.  It may sit in a buffer for a while.
: .CPU		\ -- ; display CPU type
  \ .banner
  cr ." MPE Forth Lite for STM32F072/Sockpuppet"
  \ cr version$ $. space BuildDate$ $.
  \ cr ." Copyright (C) 2014 MicroProcessor Engineering Ltd."
  \ .banner
;
external
\ *]


\ *******************
\ *S Application code
\ *******************
\ *P This code is not essential, but makes life very much easier.

include %SockPuppet%/forth/serCM3_SAPI-level1 \ polled serial driver

 \  include %CpuDir%/include		\ include from AIDE

\ RAMEND constant RP-END	\ end of available RAM


\ ***************
\ *S Finishing up
\ ***************
\ *[

libraries	\ to resolve common forward references
  include %CpuDir%/LibM0M1
  include %CpuDir%/LIBRARY
end-libs

decimal

\ Add a kernel checksum
crcstart here crcslot crc32 checksum
/DefStart 128 > [if]
  .( DEFSTART area too big ) abort
[then]

update-build				\ update build number file

FINIS					\ all done

\ *]


\ ======
\ *> ###
\ ======
