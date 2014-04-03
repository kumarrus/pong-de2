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
