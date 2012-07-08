#include <avr/eeprom.h>
#include <string.h>
#include "sha1.h"
#include "utils.h"
#include "interaction.h"
#include "configuration.h"

static void echo(const char* const buf, const uint8_t buf_len);
static void configure_board(const char* const buf, const uint8_t buf_len);
static void reboot_bootloader(const char* const unused, const uint8_t unused2);

static uint8_t key[10];
static command_handler commands[] = {
	{'e', echo},
	{'c', configure_board},
	{'r', (handler_fn)reboot},
	{'b', reboot_bootloader}
};

static void
echo(const char* const buf, const uint8_t buf_len) {
	Interaction.write((const uint8_t *)buf, buf_len);
}

static void
configure_board(const char* const buf, const uint8_t buf_len) {
	eeprom_update_byte((uint8_t *)CONFIG, 1);
	eeprom_update_block(buf, (uint8_t *)GATEWAY, buf_len);
	Interaction.write((uint8_t *)"OK", 2);
}

static inline void
reboot_bootloader(const char* const unused, const uint8_t unused2) {
	eeprom_write_byte((uint8_t *)BOOTLOADER, 0x55);
	reboot();
}

void setup() {
	uint8_t key_len;

	Serial.begin(9600);
	if (eeprom_read_byte((uint8_t *)CONFIG) == 1) {
		key_len = eeprom_read_byte((uint8_t *)HMAC_KEY_LEN);
		eeprom_read_block(key, (uint8_t *)HMAC_KEY, key_len);
	} else {
		key_len = LEN("HMAC-key");
		memcpy(key, "HMAC-key", key_len);
	}

	Interaction.init(Serial, key, key_len, commands, LEN(commands));
}

void loop() {
	Interaction.process_input();
}
