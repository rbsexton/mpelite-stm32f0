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
c" ../../"	setmacro CpuDir		\ CPU specific files

c" ../sockpuppet" setmacro SockPuppet \ Sockpuppet files.

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

\ ==============================
\ *N STM32F0 variant definitions
\ ==============================

$0800:0000 equ FlashBase	\ -- addr
\ *G Start address of Flash. The bottom 2kb (the vector area) is
\ ** mirrored at $0000:0000 for booting.

#128 kb equ /Flash	\ -- len
\ *G Size of Flash.
2 kb equ /FlashPage	\ -- len
\ *G Size of a Flash Page.
1 equ KeepPages		\ -- u
\ *G Set this non-zero for the number of pages at the end of Flash
\ ** that are reserved for configuration data. Often set to 1 or 2
\ ** by systems that use PowerNet.
FlashBase /Flash + /FlashPage KeepPages * - equ CfgFlash  \ -- len
\ *G Base address of the configuration Flash area.

$1FFF:C800 equ /InfoBase	\ -- addr
\ *G Base address of system memory information block.

#12 kb equ /SysMem		\ -- len
\ *G Size of system memory block.

$1FFF:F800 equ OptionBytes	\ -- addr
\ *G Base address of option bytes
#16 equ /OptionBytes		\ -- len
\ *G Number of option bytes


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
  $0800:0000 $0800:FFFF cdata section STM32F072
  \ data-file ../supervisor/exe/supervisor.bin
  data-file ../supervisor/binaries/supervisor_0.1.bin

  \ Its necessary to pad things out.  For now...
  dup $8000014 ! \ Stash sup size in a reserved vector for debug

  \ Pad it out to a 1k size.
  $3ff and  
  $400 swap  -  \ Size
  
  allot \ Pad it out to a boundary

  here $8000010 ! \ Forth address.  Save in a reserved vector

  $2000:2000 $2000:27FF udata section PROGu	\ 2k UDATA RAM - tcbs
  $2000:2800 $2000:3FFF idata section PROGd	\ 6k IDATA RAM - runtime.

interpreter
: prog STM32F072  ;		\ synonym
target

PROG PROGd PROGu  CDATA		\ use Code for HERE , and so on

$0801:F000 equ INFOSTART   	\ kernel status is saved here.
$0801:F800 equ APPSTART		\ application data is saved here.
$0801:FFFF equ INFOEND		\ end of kernel/application status data.

$2000:4000 equ RAMEND		\ end of RAM

$0800:0000 equ FLASHSTART  	\ start of Main Flash
$0801:FFFF equ FLASHEND		\ end of possible main Flash

$0800:C000 equ APPFLASHSTART  	\ start of application flash
$0801:F000 equ APPFLASHEND  	\ end of application flash
APPFLASHEND APPFLASHSTART - equ /APPFLASH	\ size of application flash

APPFLASHSTART TargetFlashStart	\ sets HERE at kernel start up

\ *]

\ ============================
\ *N Stack and user area sizes
\ ============================

\ *[
$100 equ UP-SIZE		\ size of each task's user area
$080 equ SP-SIZE		\ size of each task's data stack
$100 equ RP-SIZE		\ size of each task's return stack
up-size rp-size + sp-size +
  equ task-size			\ size of TASK data area
\ define the number of cells of guard space at the top of the data stack
#2 equ sp-guard			\ can underflow the data stack by this amount

$080 equ TIB-LEN		\ terminal i/p buffer length

\ define nesting levels for interrupts and SWIs.
0 equ #IRQs			\ number of IRQ stacks,
				\ shared by all IRQs (1 min)
0 equ #SVCs			\ number of SVC nestings permitted
				\ 0 is ok if SVCs are unused
\ *]

\ ==========================
\ *N Serial and ticker rates
\ ==========================

1 equ useStream10?	\ -- n
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
  include %CpuDir%/sfrSTM32F072		\ STM32F072 special function registers
  include %CpuDir%/StackDef		\ Reserve default task and stacks
PROGd  sec-top 1+ equ UNUSED-TOP  PROG	\ top of memory for UNUSED
  include %AppDir%/startSTM32F072	\ start up code

l: crcslot
  0 ,					\ the kernel CRC
l: crcstart

  include %CpuDir%/CodeM0lite		\ low level kernel definitions
  include %SockPuppet%/forth/SysCalls \ System Calls.
  include %CpuDir%/Drivers/FlashSTM32	\ Flash programming code
  include %CpuDir%/kernel72lite		\ high level kernel definitions
  include %CpuDir%/Drivers/rebootSTM32	\ reboot using watchdog
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

RAMEND constant RP-END	\ end of available RAM

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
