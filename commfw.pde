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

static EthernetServer service_port = EthernetServer(23);
static EthernetClient server; // this is the connection towards the server to which we send the data

static bool error_displayed = false;
static uint32_t last_comm = 0;

static uint8_t gateway[4] = {127, 0, 0, 1};
static uint8_t netmask[4] = {255, 255, 255, 0};
static uint8_t mac[6] = {0x55, 0xee, 0xdd, 0xaa, 0xbb, 0xcc};
static uint8_t ip[4] = {192, 168, 1, 254};
static uint8_t host[4] = {192, 168, 1, 100};
static uint16_t port = 10000;

static uint8_t key[10];
static uint8_t key_len;

static void echo(const char* const buf, const uint8_t buf_len);
static void configure_board(const char* const buf, const uint8_t buf_len);
static void reboot_bootloader(const char* const unused, const uint8_t unused2);
static void print_to_lcd(const char* const buf, const uint8_t buf_len);

static command_handler commands[] = {
	{'e', echo},
	{'c', configure_board},
	{'r', (handler_fn)reboot},
	{'p', print_to_lcd},
	{'b', reboot_bootloader}
};

static void
print_to_lcd(const char* const buf, const uint8_t buf_len) {
	LCD.clear();
	LCD.write((const uint8_t *)buf, buf_len);
	last_comm = millis();
}

static void
echo(const char* const buf, const uint8_t buf_len) {
	Interaction.write((const uint8_t *)buf, buf_len);
	last_comm = millis();
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

	if (eeprom_read_byte((uint8_t *)CONFIG) == 1) {
		key_len = eeprom_read_byte((uint8_t *)HMAC_KEY_LEN);
		port = eeprom_read_word((uint16_t *)PORT);

		eeprom_read_block(key, (uint8_t *)HMAC_KEY, key_len);
		eeprom_read_block(gateway, (uint8_t *)GATEWAY, 4);
		eeprom_read_block(netmask, (uint8_t *)NETMASK, 4);
		eeprom_read_block(mac, (uint8_t *)MAC, 6);
		eeprom_read_block(ip, (uint8_t *)IP, 4);
		eeprom_read_block(host, (uint8_t *)HOST, 4);
	} else {
		key_len = LEN("HMAC-key");
		memcpy(key, "HMAC-key", key_len);
	}

	Ethernet.begin(mac, ip, gateway, gateway, netmask);
	service_port.begin();

	Interaction.init(key, key_len, commands, LEN(commands));
}

void loop() {
	uint8_t *rfid;
	uint8_t output_buffer[7];

	Interaction.stream = &server;
	Interaction.process_input();

	EthernetClient client = service_port.available();
	if(client == true) {
		Interaction.stream = &client;

		while(!client.available())
			;

		Interaction.process_input();
		client.stop();
	}

	if(!server.connected()) {
		if(!error_displayed) {
			LCD.clear();
			LCD.print("A szerver nem   elerheto!");
			error_displayed = true;
		}

		server.stop();
		server.connect(host, port);
		last_comm = millis();
	}
	else {
		if(error_displayed) {
			LCD.clear();
			LCD.print("OK");
			error_displayed = false;
		}

		Interaction.stream = &server;
		Interaction.process_input();
	}

	if(millis() - last_comm > 5*1000 && server.connected()) {
		server.stop();
	}

	if(server.connected() && (rfid = RFID.read()) != 0) {
		error_displayed = false;
		Interaction.stream = &server;

		output_buffer[0] = 't';
		output_buffer[1] = 25;

		// we will let the interaction class handle the rest of the packet
		memcpy(output_buffer + 2, rfid, 5);
		Interaction.write(output_buffer, 7);
	}
}
