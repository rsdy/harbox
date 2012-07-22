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
#ifndef __CONFIGURATION_H__
#define __CONFIGURATION_H__

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
};

inline void reboot(void);

#endif
