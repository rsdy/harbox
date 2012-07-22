/*
 * Copyright (C) 2012 Peter Parkanyi <me@rhapsodhy.hu>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

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
