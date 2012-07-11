#ifndef __LCD_H__
#define __LCD_H__

#include "SoftwareSerial.h"

class SoftwareSerialLCD : public SoftwareSerial {
public:
	SoftwareSerialLCD(uint8_t tx_pin) : SoftwareSerial(0, tx_pin) {}
	void position(int row, int col);
	void clear(void);
	void backlight_on(void);
	void backlight_off(void);
};

#endif
