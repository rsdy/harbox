Harbox
======

Harbox is an Arduino-based project aiming to process RFID input, and send it
to a server through Ethernet with SHA1 HMAC signature. On the attached serial
16x2 LCD display, Harbox can display text coming from the server.

Hardware setup
--------------

My setup:
 * Arduino Ethernet w/ PoE
 * 16x2 Sparkfun Serial LCD
 * CWL-1 125kHz RFID reader

The RFID reader is tied to the hardware serial port of the Arduino. Since there
is no data sent to the reader, it is sufficient to attach the RX pin only.

The serial display is the other way around: it doesn't even have a TX pin on the
back. Since the default baud rate of the CWL-1 is 2400, I attached the LCD to a
separate pin, using the SoftwareSerial library because I don't need buffering,
and this way I can use the default 9600 baud rate of the LCD.

Besides the wiring of the two serial ports and the obvious Vcc+Gnd, I simply
hooked it up with a Power over Ethernet-capable switch.

Software
--------

I flashed the [optiboot-w5100][bootloader] bootloader onto my Arduino, so that I
can upload new firmware to the devices at any time without direct physical
access. This resulted in storing the network configuration in the EEPROM
according to how the bootloader expects it.

	enum Address {
		/* address configuration to comply with optiboot ethernet */
		CONFIG = 0, // configured if != 0
		// reserved for later use: 1-9
		GATEWAY = 0x10,
		NETMASK = 0x14,
		MAC = 0x18,
		IP = 0x1e,
		BOOTLOADER = 0x22,
		/* where the server is */
		HOST = 0x23,
		PORT = 0x27,
		HMAC_KEY_LEN = 0x29,
		HMAC_KEY = 0x2a
	}; //as in configuration.h

The git submodule in the repository is the one I use for the SHA1 HMAC
functionality. Just copy the Sha directory to `<arduino dir>/libraries`.
You might have some troubles with compiling with Arduino 1.0 or greater, so I
recommend you cherry-pick the patch from [maniacbug][arduino10patch]. If you're
lazy, you may want to fix the lib yourself, just like I did.

[bootloader]: http://sowerbutts.com/optiboot-w5100/
[arduino10patch]: https://github.com/maniacbug/Cryptosuite/commit/5ce39bcac2d6f9fdb6f0edb61a07e84fd9b5934f

Default configuration
---------------------

	gateway     = 127.0.0.1
	netmask     = 255.255.255.0
	ip          = 192.168.1.254
	mac         = 55:ee:dd:aa:bb:cc

	server host = 192.168.1.100
	server port = 10000;

	hmac key    = HMAC-key

Protocol
--------

Harbox speaks a very minimal protocol with the server. The communication happens
in packets (although uses TCP for reliablity), which may be at most 128 bytes in
length. Looks like this:

	command (1 byte)
	length of data including sha1 (1 byte)
	data (rest - 20 bytes)
	sha1 hmac (20 byte)

The HMAC is the hash of the packet without the HMAC itself.

A command sent to the box may be one of the following:

 * `b` -- reboot to bootloader and wait for roughly 10 minutes for flashing
   over ethernet
 * `c` -- configure board (for details, see test.rb, and consult the EEPROM
   layout above)
 * `e` -- echo
 * `p` -- print test to the lcd
 * `r` -- reboot

Currently, the only command the box may invoke on the server:

 * `t` -- send the RFID tag (5 bytes)

Communication
-------------

On boot, Harbox opens a TCP connection to the IP and port set in the
configuration. This socket is then kept open for as long as possible, so that
there are no unneeded handshakes.

The box expects the server to send any command to it in every 5 seconds. If
there was no command received during the last 5 seconds, it closes the
connection, displays an error message on the LCD, and tries to reconnect in a
loop.

On port 23 listens a socket that accepts connections from clients, and
speaks the exact same protocol, and handles the exact same commands as the other
interface. This is good for testing purposes on one hand, and also for
debugging.

Testing
-------

I included a Ruby script called `test.rb`, which may be used for sending packets
to the Harbox according to the protocol specification. I tested most of its
communication code using this tool, although I may have missed something. At the
time of writing, the devices I have built have been working without a reset for
about two weeks, so it should be fine.

Take a look at the code if you want to understand what's going on, because it's
really simple. I deliberately included all the configuration in the file itself,
because it was easier during development than specifying and parsing obnoxious
command line arguments. There is one command line argument, though: `--net`
causes the script to try access the Harbox at the `@ip` IP address defined in
the file.

Issues
------

 * The connection timeout cannot be configured, but is hardcoded.
 * The 128 bytes max packet length are used throughout the code as literals.
   Should use defines instead.
 * Same for the 10 bytes max length of the HMAC key.
 * CWL-1 is a component that is unkown to the Internet outside of Hungary, so I
   guess this is a custom stuff of the dealer I got it from. It should be fairly
   straightforward to implement a driver for another kind of reader/sensor, though.

Licence
-------
Copyright (C) 2012 Peter Parkanyi <me@rhapsodhy.hu>

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
