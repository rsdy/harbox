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
