\ startSTM32F072.fth - Cortex startup code for SM32F072B-DISCO board
\ Customized for use with SockPuppet.  No hardware init code.

((

To do
=====

Change history
==============
))

only forth definitions  decimal

\ ===========
\ *! startstm32f072
\ *T Cortex start up for STM32F072
\ ===========

l: ExcVecs	\ -- addr ; start of vector table
\ *G The exception vector table is *\fo{/ExcVecs} bytes long. The
\ ** equate is defined in the control file. Note that this table
\ ** table must be correctly aligned as described in the Cortex-M3
\ ** Technical Reference Manual (ARM DDI0337, rev E page 8-21). If
\ ** placed at 0 or the start of Flash, you'll usually be fine.
  /ExcVecs allot&erase

interpreter
: SetExcVec	\ addr exc# --
\ *G Set the given exception vector number to the given address.
\ ** Note that for vectors other than 0, the Thumb bit is forced
\ ** to 1.
  dup if				\ If not the stack top
    swap 1 or swap			\   set the Thumb bit
  endif
  cells ExcVecs + !  ;
target

L: CLD1		\ holds xt of main word
  0 ,					\ fixed by MAKE-TURNKEY

proc DefExc2	b  $	end-code	\ NMI
proc DefExc3	b  $	end-code	\ HardFault
proc DefExc4	b  $	end-code	\ MemManage
proc DefExc5	b  $	end-code	\ BusFault
proc DefExc6	b  $	end-code	\ UsageFault
proc DefExc11	b  $	end-code	\ SVC
proc DefExc12	b  $	end-code	\ DbgMon
proc DefExc14	b  $	end-code	\ PendSV
proc DefExc15	b  $	end-code	\ SysTick


\ Calculate the initial value for the data stack pointer.
\ We allow for TOS being in a register and guard space.

[undefined] sp-guard [if]		\ if no guard value is set
0 equ sp-guard
[then]

init-s0 tos-cached? sp-guard + cells -
  equ real-init-s0	\ -- addr
\ The data stack pointer set at start up.

: StartCortex	\ -- ; never exits
\ *G Set up the Forth registers and start Forth. Other primary
\ ** hardware initialisation can also be performed here.
\ ** All the GPIO blocks are enabled.
  begin
    \ INT_STACK_TOP SP_main sys!		\ set SP_main for interrupts
    \ INIT-R0 SP_process sys!		\ set SP_process for tasks
    \ 2 control sys!			\ switch to SP_process
    \ Don't mess with the stack pointers.  The launcher will handle it.
    REAL-INIT-S0 set-sp			\ Allow for cached TOS and guard space
    INIT-U0 up!				\ USER area
    CLD1 @ execute
  again
;
external

INT_STACK_TOP StackVec# SetExcVec	\ Define initial return stack
' StartCortex ResetVec# SetExcVec	\ Define startup word
DefExc2       2         SetExcVec
DefExc3       3         SetExcVec
DefExc4       4         SetExcVec
DefExc5       5         SetExcVec
DefExc11      11        SetExcVec
DefExc12      12        SetExcVec
DefExc14      14        SetExcVec
DefExc15      15        SetExcVec


\ ------------------------------------------
\ reset values for user and system variables
\ ------------------------------------------

[undefined] umbilical? [if]
L: USER-RESET
  init-s0 tos-cached? sp-guard + cells - ,	\ s0
  init-r0 ,				\ r0
  0 ,  0 ,                              \ #tib, 'tib
  0 ,  0 ,                              \ >in, out
  $0A ,  0 ,                            \ base, hld

\ initial values of system variables
L: INIT-FENCE  0 ,                      \ fence
L: INIT-DP  0 ,                         \ dp
L: INIT-RP  0 ,				\ RP
L: INIT-VOC-LINK  0 ,                   \ voc-link
[then]


\ ======
\ *> ###
\ ======

decimal

