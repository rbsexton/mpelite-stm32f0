@ SVC Call Table.
@
@ Copyright (C) 2016-2017, Robert Sexton.  All rights reserved.
@ Covered by the terms of the supplied Licence.txt file
@ 
@ This is a reference copy.  It may need to be customized, depending
@ on how much of the SAPI API is implemented.


@ Version History
@ 2.06.00 - Move the jump table to SRAM - it's faster and can be modified.
@ 2.05.00 - Officially define wake request
@ 2.04.00 - Change return codes for putchar, type and eol for use with multitasking.
@ 2.03.00 - Support 64-bit return values.
@ 2.02.01 - Change return code of EOL.
@ 2.02.00 - Add WakeRequest
@ 2.01.00 - Add CPUUsage and clarify behavior of unsupported calls.
@ 2.00.00 - Initial Release.
#include "sapiopts.h"

.text
.syntax unified
.cpu cortex-m0

.thumb_func @ Set the thumb bit in the linker. 
@ Version coding: 0xMMIIPP
@ Major 
@ Minor Release / Feature Change
@ Patchlevel 
__SAPI_00_ABIVersion:
	ldr r0,  =0x00020600
	bx lr  

@ Hang out and wait for debugger help.
.thumb_func
__SAPI_RFU:
	b __SAPI_RFU

// ------------------------------------------------------------
// The first 16 are whats required for bootstrapping forth.
// TYPE and CR are special - They are included for efficiency,
// but can be built from other primitives.
// ------------------------------------------------------------

.global syscall_table
.data 
.align 4
syscall_table:
	@ ------------------ Mandatory -----------------
	.word	__SAPI_00_ABIVersion		@ SVC 0

	@ ------------------ Core -----------------
	@ This is the main syscall for runtime linking - symbolic lists, 
	@ jump tables, etc.
	@ R0 = 0 - Return a pointer to a symbol table.
	@ R0 = 1 - Return a pointer to a bare jump table.
	@ Unsupported/Stubbed - return 0
	.word	__SAPI_01_GetRuntimeData	@ SVC 1  - 
	.extern __SAPI_01_GetRuntimeData	- 

	@ Notes about stream IO.   There are many cases where the user
	@ app will not succeed.  In the model where threading/tasking
	@ is a user space thing, the task in question must re-try any failing
	@ or partial IO operations.  That allows the thread to yield and try again.


	@ ------------------ Core -----------------
	@ Single Character Write
	@ R0 - Stream #
	@ R1 - The Character.
	@ R2 - The address of the caller's tcb if blocking is requested, or zero.
	@
	@ Returns:
	@  0 - Success/Room for more.
	@  1 - Caller must yield/pause and wait for wake by service layer.
	@
	.word	__SAPI_02_PutChar		@ SVC 2/emit
	.extern __SAPI_02_PutChar

	@ ------------------ Core -----------------
	@ Single character read
	@ R0 - Stream #
	@ R1 - The address of the caller's tcb if blocking is requested, or zero.
	@
	@ Returns
	@ >= 0 - the Character
	@   -1 - failure/nothing
	@
	.word	__SAPI_03_GetChar		@ SVC 3/key
	.extern	__SAPI_03_GetChar

	@ ------------------ Core -----------------
	@ Input buffer queue check.
	@ R0 - Stream #
	@
	@ Returns
	@ R0 - The number of characters in the input queue.
	.word	__SAPI_04_GetCharAvail	@ SVC 4/key?
	.extern	__SAPI_04_GetCharAvail

	@ --------------------------------------------------
	@ Bulk Character IO - These can improve performance.
	@ but require a higher level of integration.
	@ --------------------------------------------------

	@ ------------------ Enhanced -----------------	
	@ Put a block of characters.  TYPE.
	@ R0 - Stream #
	@ R1 - Number of Characters
	@ R2 - Pointer to the data
	@ R3 - The address of the caller's tcb if blocking is requested, or zero.
	@ Returns:
	@  0 - Success/Room for more.
	@  1 - Caller must yield/pause and wait for wake by service layer.
	@ Unsupported/Stub behavior - Fault/Spin/Trap
	.word	__SAPI_RFU @ 5

	@ ------------------ Enhanced -----------------	
	@ Send a newline or whatever corresponds to it.
	@ R0 - Stream #
	@ R1 - The address of the caller's tcb if blocking is requested, or zero.
	@ Returns
	@  0 - Success/Room for more.
	@  1 - Caller must yield/pause and wait for wake by service layer.
	@ Unsupported/Stub behavior - Fault/Spin/Trap
	.word	__SAPI_RFU @ 6

	.word	__SAPI_RFU @ 7
	.word	__SAPI_RFU @ 8
	.word	__SAPI_RFU @ 9
	.word	__SAPI_RFU @ 10
	.word	__SAPI_RFU @ 11

	@ ------------------ Enhanced -----------------	
	@ A mechanism so that a user task can request a 
	@ wake in response to a specific event.  This is an
	@ Implementation specific thing.  Types 0-15 are reserved
	@ One use case scenario is periodic timers.
	@
	@ Arguments
	@ R0 - Wake Type.
	@ R1 - Wake argument - type-specific.
	@ R2 - TCB of the thing to wake.
	@ Returns true for block requested.
	.word	__SAPI_12_WakeRequest @ 12
	.extern	__SAPI_12_WakeRequest 
	
	@ ------------------ Enhanced -----------------	
	@ The most basic tool for reducing power consumption is to 
	@ clock gate the CPU when there is no work.  The simplest
	@ mechanism for measuring this is a free-running counter
	@ clock-gated by WFI, with an ISR that measures the ticks
	@ of the timer per wall clock unit of time.  
	@
	@ No arguments.
	@ Returns a platform-specific measure of CPU utilization.
	@ Unsupported/Stub behavior - Return 0
	.word	__SAPI_13_CPUUsage	 
	.extern	__SAPI_13_CPUUsage	

	@ ------------------ Enhanced -----------------	
	@ R0 - Number of ticks (optional), or zero for the default.
	@ Unsupported/Stub behavior - No Action
	.word	__SAPI_14_PetWatchdog	 
	.extern	__SAPI_14_PetWatchdog	

	@ ------------------ Enhanced -----------------	
	@ Returns
	@ 32-bit Milliseconds
	@ R0 =  0 Return the Current 32-bit value.
	@ R1 =  1 Return the address of the current value.
	@ R2 = -1 Return the 64-Bit value.
	@ Unsupported/Stub behavior - Return 0
	.word   __SAPI_15_GetTime     @ SVC 15/ticks
	.extern __SAPI_15_GetTime

@ --------------------------------------------------
@ End of reserved vectors.
@ --------------------------------------------------

	.word	__SAPI_RFU @ 16
	.word	__SAPI_RFU @ 17
	.word	__SAPI_RFU @ 18
	.word	__SAPI_RFU @ 19
	.word	__SAPI_RFU @ 20
	.word	__SAPI_RFU @ 21
	.word	__SAPI_RFU @ 22
	.word	__SAPI_RFU @ 23
	.word	__SAPI_RFU @ 24
	.word	__SAPI_RFU @ 25
	.word	__SAPI_RFU @ 26
	.word	__SAPI_RFU @ 27

.word	__SAPI_RFU @ 28
.word	__SAPI_RFU @ 29
.word	__SAPI_RFU @ 30
.word	__SAPI_RFU @ 31

syscall_table_end:

.end

