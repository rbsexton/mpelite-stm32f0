int USBGetCharAvail(int stream);
int USBGetChar(int stream,unsigned long *tcb);
bool USBPutChar(int stream, uint8_t c, unsigned long *tcb);

