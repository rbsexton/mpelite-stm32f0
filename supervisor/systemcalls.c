//
// Required system calls
// 
// Some of these are stubbed out.

#include <stdint.h>
#include <stdbool.h>
#include <ringbuffer.h>

#include "syscalls.h"

void* __SAPI_01_GetRuntimeData(int i) {
	if ( i == 0 ) return(0);
	else return(0);
}

extern RINGBUF rb_ep_IN;

/// @parameters
/// @R0 - Stream Number
/// @R1 - The Character in question.
/// @returns in R0 - Result - 0 for success. 1 for blocked - Thread must yield/pause
bool __SAPI_02_PutChar(int stream, uint8_t c, unsigned long *tcb) {
	int ret;
	switch ( stream ) {
		case 10:
			return(USBPutChar(stream-10, c));
			break;
		default:
			ret = 0;
		}
	return(ret);
	}

// Support blocking by returning -1.
int __SAPI_03_GetChar(int stream, unsigned long *tcb) {
	switch ( stream ) {
		case 10:
			return(USBGetChar(stream-10, tcb));			
			break;
		default:
			return(-1);
		}
	}

// Return the number of incoming characters.
int __SAPI_04_GetCharAvail(int stream) {
	switch ( stream ) {
		case 10:
			return(USBGetCharAvail(stream-10));
			break;
		default:
			return(0);
		}
	}

// Putstring - System call to support TYPE.
// Return 0 for success
bool __SAPI_05_PutString(int stream,  int len, uint8_t *p, unsigned long *tcb) {
	switch ( stream ) {
		case 10:
			return(USBPutString(stream-10,len,p,tcb));
			break;
		default:
			return(0);
		}
	}

// Stubbed out.
bool __SAPI_06_EOL(int stream, unsigned long *tcb) {
	switch ( stream ) {
		case 10:
			return(USBOutEOL(stream-10,tcb));
			break;
		default:
			return(0);
		}
	}

// Stubbed out
bool __SAPI_12_WakeRequest(int request_type, int arg, unsigned long *tcb) {
	return(request_type == 0 || arg == 0 || tcb == 0 ); // A Pointless fn.
	}

// Stubbed out
unsigned __SAPI_13_CPUUsage() {
	static unsigned count = 0;
	return(++count);
	}


// Stubbed out
void __SAPI_14_PetWatchdog(unsigned machineticks) {
	static unsigned count = 0;
	count += machineticks;
	return;
}

extern uint32_t rtc_ms;
unsigned __SAPI_15_GetTime(tTimeType kind) {
	return(0);
}

