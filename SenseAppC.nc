#include "XM1000Radio.h"
#include "printf.h"

configuration SenseAppC 
{ 
} 
implementation { 
  
	components SenseC, MainC, LedsC;
	components new TimerMilliC() as Timer0;
	components new TimerMilliC() as Timer1;
	components new HamamatsuS10871TsrC() as LightSensor;
	components new AMSenderC(AM_XM1000MSG);
	components new AMReceiverC(AM_XM1000MSG);
	components ActiveMessageC; 
	components PrintfC;
	components SerialStartC;


	SenseC.Boot -> MainC;
	SenseC.Leds -> LedsC;
	SenseC.Timer0 -> Timer0;
	SenseC.Timer1 -> Timer1;
	SenseC.Light -> LightSensor;
	SenseC.AMSend -> AMSenderC;
	SenseC.Packet -> AMSenderC;
	SenseC.Receive -> AMReceiverC;
	SenseC.AMControl -> ActiveMessageC;
}
