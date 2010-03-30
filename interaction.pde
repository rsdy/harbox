#include <avr/eeprom.h>
#include <string.h>
#include "interaction.h"
#include "utils.h"
#include "sha1.h"

#define BUFFER_LEN 128

static char buffer[BUFFER_LEN];
static uint8_t input_i;

static void
fill_buffer(void) {
	register char ch = 0;
	input_i = 0;

	for(;;) {
		if(input_i < BUFFER_LEN) {
			if (!Interaction::client.available())
				continue;

			ch = Interaction::client.read();
			if (ch == '\n')
				break;
			else
				buffer[input_i++] = ch;
		} else {
			Interaction::client.read();
		}
	}
}

static int
verify_buffer(void) {
	uint8_t key_len = eeprom_read_byte((uint8_t *)Configuration::HMAC_KEY_LEN);
	uint8_t key[128];
	eeprom_read_block(key, (uint8_t *)Configuration::HMAC_KEY, key_len);
	Sha1.initHmac(key, key_len);
	for(uint8_t i = 0; i < input_i - 20; i++)
		Sha1.write(buffer[i]);

	uint8_t *result = Sha1.resultHmac();
	return memcmp(result, buffer + input_i - 20, 20);
}

void
Interaction::process_input(void) {
	fill_buffer();
	if(!(input_i > 20 && verify_buffer() == 0))
		return;

	buffer[input_i - 20] = 0;

	for(uint8_t i = 0; i < LEN(handlers); i++) {
		if(handlers[i].command == buffer[0]) {
			handlers[i].fn(0, buffer, input_i - 20);
			break;
		}
	}
}
