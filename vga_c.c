#define ADDR_7SEG1 ((volatile long *) 0x10000020)
#define ADDR_7SEG2 ((volatile long *) 0x10000030)

/* set a single pixel on the screen at x,y
 * x in [0,319], y in [0,239], and colour in [0,65535]
 */
void write_pixel(int x, int y, short colour) {
  volatile short *vga_addr=(volatile short*)(0x08000000 + (y<<10) + (x<<1));
  *vga_addr=colour;
}

/* use write_pixel to set entire screen to black (does not clear the character buffer) */
void erase_screen() {
  int x, y;
  for (x = 0; x < 320; x++) {
    for (y = 0; y < 240; y++) {
	  write_pixel(x,y,0);
	}
  }
}

void display_hex(int value1, int value2) {
	// bits 0000110 will activate segments 1 and 2
	switch(value1) {
	case 0: *ADDR_7SEG1 = 0x00000000; 
	break;
	case 1: *ADDR_7SEG1 = 0x00000006; 
	break;
	case 2: *ADDR_7SEG1 = 0x0000005b; //01011011
	break;
	case 3: *ADDR_7SEG1 = 0x0000004f; //01001111 
	break;
	case 4: *ADDR_7SEG1 = 0x00000066; //01100110
	break;
	case 5: *ADDR_7SEG1 = 0x0000006d; //01101101
	break;
	case 6: *ADDR_7SEG1 = 0x0000007d; //01111101
	break;
	case 7: *ADDR_7SEG1 = 0x00000007; //00000111
	break;
	case 8: *ADDR_7SEG1 = 0x0000007f; //01111111
	break;
	case 9: *ADDR_7SEG1 = 0x0000006f; //01101111
	break;
	}

	switch(value2) {
	case 0: *ADDR_7SEG2 = 0x00000000; 
	break;
	case 1: *ADDR_7SEG2 = 0x00000006; 
	break;
	case 2: *ADDR_7SEG2 = 0x0000005b; //01011011
	break;
	case 3: *ADDR_7SEG2 = 0x0000004f; //01001111 
	break;
	case 4: *ADDR_7SEG2 = 0x00000066; //01100110
	break;
	case 5: *ADDR_7SEG2 = 0x0000006d; //01101101
	break;
	case 6: *ADDR_7SEG2 = 0x0000007d; //01111101
	break;
	case 7: *ADDR_7SEG2 = 0x00000007; //00000111
	break;
	case 8: *ADDR_7SEG2 = 0x0000007f; //01111111
	break;
	case 9: *ADDR_7SEG2 = 0x0000006f; //01101111
	break;
	}
	
}

/*
int main() {
	__asm__( "movia sp, 0x007ffffc		#0x17fff80\n"
             "call erase_screen\n"
             "movi r21, 0\n"
			 "movi r4, 0\n"
			 "movi r5, 0\n"
			 "infinite_loop:\n"
			 "call move_paddle_1\n"
			 "call move_paddle_2\n"
			 "call move_ball\n"
			 "br infinite_loop\n"
    );
}
*/
