#include <avr/eeprom.h>
#include "sha1.h"
#include "interaction.h"
#include "configuration.h"

void
echo(size_t (*println)(const char*), const char* const buf, const uint8_t buf_len) {
	Interaction::client.println(buf);
}

Stream& Interaction::client = Serial;
Interaction::handler_table_item Interaction::handlers[] = {
	{'e', echo}
};

void setup() {

	/* fire up serial communication */
	Serial.begin(9600);

	Serial.println("eee");
}

void loop() {
	Interaction::process_input();

}

