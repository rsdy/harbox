// This code is based on the one found at
// http://www.arduino.cc/playground/Learning/SparkFunSerLCD
//
#include <util/delay.h>
#include "lcd.h"

#define LCD_DELAY 5.0

void
SoftwareSerialLCD::position(int row, int col) {
	write(0xFE);                 //command flag
	write((col + row*64 + 128)); //position
	_delay_ms(LCD_DELAY);
}

void
SoftwareSerialLCD::clear(void) {
	write(0xFE); //command flag
	write(0x01); //clear command.
	_delay_ms(LCD_DELAY);
}

void
SoftwareSerialLCD::backlight_on(void) {
	write(0x7C); //command flag for backlight stuff
	write(157);  //light level.
	_delay_ms(LCD_DELAY);
}

void
SoftwareSerialLCD::backlight_off(void) {
	write(0x7C); //command flag for backlight stuff
	write(128);  //light level for off.
	_delay_ms(LCD_DELAY);
}
