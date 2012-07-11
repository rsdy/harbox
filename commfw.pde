// AVR libs
#include <avr/eeprom.h>
#include <string.h>

// Arduino libs
#include "Ethernet.h"
#include "sha1.h"
#include "SoftwareSerial.h"
#include "SPI.h"

// Custom libs
#include "configuration.h"
#include "cwl1.h"
#include "interaction.h"
#include "lcd.h"
#include "utils.h"

#define LCD_PIN 2

static SoftwareSerialLCD LCD = SoftwareSerialLCD(LCD_PIN);
static CWL1 RFID = CWL1(&Serial);

static EthernetServer server = EthernetServer(23);

static uint8_t gateway[4] = {127, 0, 0, 1};
static uint8_t netmask[4] = {255, 255, 255, 0};
static uint8_t mac[6] = {0x55, 0xee, 0xdd, 0xaa, 0xbb, 0xcc};
static uint8_t ip[4] = {192, 168, 1, 254};

static uint8_t key[10];
static uint8_t key_len;

static void echo(const char* const buf, const uint8_t buf_len);
static void configure_board(const char* const buf, const uint8_t buf_len);
static void reboot_bootloader(const char* const unused, const uint8_t unused2);

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
	eeprom_write_byte((uint8_t *)CONFIG, 1);
	eeprom_write_block(buf, (uint8_t *)GATEWAY, buf_len);
	Interaction.write((uint8_t *)"OK", 2);
}

static inline void
reboot_bootloader(const char* const unused, const uint8_t unused2) {
	eeprom_write_byte((uint8_t *)BOOTLOADER, 0x55);
	reboot();
}

void setup() {
	pinMode(LCD_PIN, OUTPUT);

	Serial.begin(2400);
	LCD.begin(9600);
	LCD.backlight_on();
	LCD.clear();
	LCD.position(0, 0);

	if (eeprom_read_byte((uint8_t *)CONFIG) == 1) {
		key_len = eeprom_read_byte((uint8_t *)HMAC_KEY_LEN);

		eeprom_read_block(key, (uint8_t *)HMAC_KEY, key_len);
		eeprom_read_block(gateway, (uint8_t *)GATEWAY, 4);
		eeprom_read_block(netmask, (uint8_t *)NETMASK, 4);
		eeprom_read_block(mac, (uint8_t *)MAC, 6);
		eeprom_read_block(ip, (uint8_t *)IP, 4);
	} else {
		key_len = LEN("HMAC-key");
		memcpy(key, "HMAC-key", key_len);
	}

	Ethernet.begin(mac, ip);
	server.begin();

	delay(1000);
	LCD.write("what");
}

void loop() {
	uint8_t *buffer;

	EthernetClient client = server.available();
	if(client == true) {
		if(client.connected()) {
			Interaction.init(client, key, key_len, commands, LEN(commands));
			Interaction.process_input();
			client.stop();
		}
	}

	if((buffer = RFID.read()) != 0)
		LCD.write(buffer, 10);
}
