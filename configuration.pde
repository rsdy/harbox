#include "configuration.h"
#include <avr/eeprom.h>
#include <avr/wdt.h>

void
reboot(void) {
	wdt_enable(WDTO_2S);
	while(1);
}
