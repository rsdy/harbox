#include <avr/eeprom.h>
#include "sha1.h"
#include "utils.h"
#include "interaction.h"
#include "configuration.h"

static void echo(const char* const buf, const uint8_t buf_len);

static uint8_t key[10];
command_handler commands[] = {
	{'e', echo}
};

static void
echo(const char* const buf, const uint8_t buf_len) {
	Interaction.println(buf);
}

void setup() {
	uint8_t key_len = eeprom_read_byte((uint8_t *)Configuration::HMAC_KEY_LEN);
	eeprom_read_block(key, (uint8_t *)Configuration::HMAC_KEY, key_len);

	Serial.begin(9600);
	Interaction.init(Serial, key, key_len, commands, LEN(commands));
}

void loop() {
	Interaction.process_input();
}
