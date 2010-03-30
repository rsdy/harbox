#include "configuration.h"
#include <avr/eeprom.h>
#include <avr/wdt.h>

int
Configuration::configured() {
	return eeprom_read_byte((uint8_t *)CONFIG);
}

void
Configuration::reboot() {
	wdt_enable(WDTO_15MS);                   // 15ms watchdog delay
	while(1);                                // loop forever until watchdog resets us
}
