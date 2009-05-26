// Copyright 2008-2009  Segher Boessenkool  <segher@kernel.crashing.org>
// This code is licensed to you under the terms of the GNU GPL, version 2;
// see file COPYING or http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

#undef DEBUG_GECKO
#undef DEBUG_BLINK

typedef unsigned int u32;
typedef unsigned char u8;

int nand_open_E0(const char *path, void *buf, u32 mode);
int nand_open_E2(const char *path, void *buf, u32 mode);
int nand_open_J0(const char *path, void *buf, u32 mode);
int nand_open_P0(const char *path, void *buf, u32 mode);

int nand_read_E0(void *buf, void *dest, u32 len);
int nand_read_E2(void *buf, void *dest, u32 len);
int nand_read_J0(void *buf, void *dest, u32 len);
int nand_read_P0(void *buf, void *dest, u32 len);

void audio_stop_E0(void);
void audio_stop_E2(void);
void audio_stop_J0(void);
void audio_stop_P0(void);

void graphics_stop_E0(void);
void graphics_stop_E2(void);
void graphics_stop_J0(void);
void graphics_stop_P0(void);

static u8 nand_buf[0x100] __attribute__ ((aligned(0x40)));

#ifdef DEBUG_GECKO
void gecko_print(void *, const char *);

#define PRINT(x) gecko_print(0, x)
#define HEX(x) hex(x)

static void hex(u32 x)
{
	u32 i;
	u32 digit;
	char s[10];

	for (i = 0; i < 8; i++) {
		digit = x >> 28;
		x <<= 4;
		s[i] = digit + '0' + (digit < 10 ? 0 : 'a' - 10 - '0');
	}
	s[8] = '\n';
	s[9] = 0;
	PRINT(s);
}
#else
#define PRINT(x) do { } while (0)
#define HEX(x) do { } while (0)
#endif

static void sync_cache(void *p, u32 n)
{
	u32 start, end;

	start = (u32)p & ~31;
	end = ((u32)p + n + 31) & ~31;
	n = (end - start) >> 5;

	while (n--) {
		asm("dcbst 0,%0 ; icbi 0,%0" : : "b"(p));
		p += 32;
	}
	asm("sync ; isync");
}

static void sync_before_read(void *p, u32 n)
{
	u32 start, end;

	start = (u32)p & ~31;
	end = ((u32)p + n + 31) & ~31;
	n = (end - start) >> 5;

	while (n--) {
		asm("dcbf 0,%0" : : "b"(p));
		p += 32;
	}
	asm("sync");
}

static void jump(void *p, u32 arg)
{
	PRINT("taking the plunge...\n");

	asm("mr 3,%1 ; mtctr %0 ; bctrl" : : "r"(p), "r"(arg) : "r3");

	PRINT("whoops, payload returned to us\n");
}

#ifdef DEBUG_BLINK
static u32 read32(u32 addr)
{
	u32 x;

	asm volatile("lwz %0,0(%1) ; sync" : "=r"(x) : "b"(0xc0000000 | addr));

	return x;
}

static void write32(u32 addr, u32 x)
{
	asm("stw %0,0(%1) ; eieio" : : "r"(x), "b"(0xc0000000 | addr));
}

static void blink(u32 colour)
{
	u32 *fb = (u32 *)0xC0F00000;
	u32 i;

	// blink tray led
	write32(0x0d8000c0, read32(0x0d8000c0) ^ 0x20);

	for (i = 0; i < 640*576/2; i++)
		fb[i] = colour;
}
#else
#define blink(x) do { } while(0)
#endif

void __attribute__ ((noreturn)) main(u32 baddr)
{
	int ret, i, len;
	char *area;
	char *gameid = (char *)0x80000000;
	int (*nand_open)(const char *path, void *buf, u32 mode);
	int (*nand_read)(void *buf, void *dest, u32 len);
	void (*audio_stop)(void);
	void (*graphics_stop)(void);

	PRINT("Hello, Brave New World!\n");

	baddr -= 0x2c0;

	switch (gameid[3]) {
	case 'E':
		if ((baddr>>16) == 0x8045) {
			nand_open = nand_open_E2;
			nand_read = nand_read_E2;
			audio_stop = audio_stop_E2;
			graphics_stop = graphics_stop_E2;
		} else {
			nand_open = nand_open_E0;
			nand_read = nand_read_E0;
			audio_stop = audio_stop_E0;
			graphics_stop = graphics_stop_E0;
		}
		break;
	case 'P':
		nand_open = nand_open_P0;
		nand_read = nand_read_P0;
		audio_stop = audio_stop_P0;
		graphics_stop = graphics_stop_P0;
		break;
	case 'J':
		nand_open = nand_open_J0;
		nand_read = nand_read_J0;
		audio_stop = audio_stop_J0;
		graphics_stop = graphics_stop_J0;
		break;
	default:
		PRINT("unsupported game region\n");
		for (;;)
			;
	}

	audio_stop();
	graphics_stop();

	blink(0x266a26c0); // maroon

	ret = nand_open("zeldaTp.dat", nand_buf, 1);

	blink(0x7140718a); // olive

	PRINT("nand open --> ");
	HEX(ret);

	area = (void *)0x90000020;

	// Skip past save game, to loader.bin
	ret = nand_read(nand_buf, area, 0x4000);

	len = 0;
	for (i = 0; i < 0x40; i++) {
		PRINT("reading bootloader page: ");
		HEX(i);

		blink(0x40804080 + i*0x02000200); // grey

		sync_before_read(area + 0x1000*i, 0x1000);
		ret = nand_read(nand_buf, area + 0x1000*i, 0x1000);
		len += ret;

		blink(0x552b5515 + i*0x02000200); // lime

		PRINT("--> ");
		HEX(ret);
		PRINT("\n");
	}

	for (i = 0; i < 0x100; i++)
		HEX(((u32 *)area)[i]);

	blink(0xc399c36a); // sky blue

	sync_cache(area, len);
	jump(area, 0x123);

	blink(0x4c544cff); // red

	PRINT("(shouldn't happen)\n");
	for (;;)
		;
}
