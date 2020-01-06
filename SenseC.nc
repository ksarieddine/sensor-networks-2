#include "Timer.h"
#include "XM1000Radio.h"
#include "printf.h"

module SenseC
{
	uses {
		interface Boot;
		interface Leds;
		interface Timer<TMilli> as Timer0;
		interface Timer<TMilli> as Timer1;
		interface Read<uint16_t> as Light;
		interface AMSend;
		interface Receive;
		interface SplitControl as AMControl;
		interface Packet;
	}
}
implementation
{
 
	message_t packet;
	bool locked;
	uint16_t lightVal;
	uint16_t counter = 0;
	enum state {TX, RX} mode;
	event void Boot.booted() {
		call AMControl.start();
		mode = RX; /*  if mode RX then it is a receiver if it is TX then it is a transmitter */
	}

	event void AMControl.startDone(error_t err)
	{
		if( err == SUCCESS)
		{
			if(mode == TX) 
			{
				call Timer0.startPeriodic(1000);
			}else{
				call Leds.led0On();
				call Leds.led1On();
				call Leds.led2On();
			}
		}
		else
		{ 
			call AMControl.start();
		}
	}
  
	event void AMControl.stopDone(error_t err){}

	event void Timer0.fired() 
	{
		call Light.read();
		counter++;
		if(locked)
		{
			return;
		}
		else
		{
			XM1000Msg* rcm = (XM1000Msg*) (call Packet.getPayload(&packet, sizeof(XM1000Msg)));
			if(rcm == NULL)
			{
				counter++;
			}
			rcm->light = lightVal;
			if(call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(XM1000Msg)) == SUCCESS)
			{
				locked = TRUE;
			}
		}
	}
	event void Timer1.fired()
	{
		call Leds.led0Toggle();
	}

	event void Light.readDone(error_t result, uint16_t data) 
	{
		if (result == SUCCESS){
			lightVal = data;
			printf("%u\n", data);
			printfflush();
			call Timer1.startPeriodic(250); //Thus Sensing
		}
		else
		{
			call Timer1.startOneShot(0);
		}
	}
  
	event void AMSend.sendDone(message_t* bufPtr, error_t error)
	{
		if(&packet == bufPtr)
		{
			locked = FALSE;
		}
	}


	event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
		if(mode == TX) {
			return bufPtr;
		}

		if (len != sizeof(XM1000Msg)) {
			call Leds.led1Off();
			return bufPtr;
		}
		else 
		{
			XM1000Msg* rsm = (XM1000Msg*)payload;
			printf("I am light %u\n", rsm->light);
			printfflush();
			call Timer1.startPeriodic(1000);
			if(rsm->light < 50)
			{
				call Leds.led2Off();
			}
			else
			{
				call Leds.led2On();
			}
		}
		return bufPtr;
	}
}
