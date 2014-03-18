#---------------------------------------------------#
#	r4 -> start_x
#	r5 -> 
#	x->320
#	y->240
#---------------------------------------------------#

.equ ADDR_VGA, 0x08000000
.equ ADDR_CHAR, 0x09000000
.equ COL_WHITE, 0xffff
.equ COL_BLACK, 0x00000000
.equ MAX_X, 320
.equ MAX_Y,240
.global _start

_start:
	
	#movi r11, 
	#movi r12,
	#sthio r4,1032(r8) /* pixel (4,1) is x*2 + y*1024 so (8 + 1024 = 1032) */
	call erase_screen
	subi sp, sp, 12
	movia r4, 40
	movia r5, 40
	movui r15, 0xffff  /* White pixel */
	stw r4, 0(sp)
	stw r5, 4(sp)
	stw r15, 8(sp)
	call draw_rect
	addi sp, sp, 12
	movia r9, ADDR_CHAR
	movi  r5, 0x41   /* ASCII for 'A' */
	sthio r15,1032(r8) /* pixel (4,1) is x*2 + y*1024 so (8 + 1024 = 1032) */
	stbio r5,132(r9) /* character (4,1) is x + y*128 so (4 + 128 = 132) */

infinite_loop:
	br infinite_loop

erase_screen:
	movia r16, MAX_X
	movia r17, MAX_Y
	mov r18, r0
	movui r10, COL_BLACK
	erase_screen_while_y:
		movia r8, ADDR_VGA
		mov r19, r0
		slli r20, r18, 10
		add r8, r8, r20
		erase_screen_while_x:
			sthio r10, 0(r8)
			addi r19, r19, 1
			addi r8, r8, 2
			ble r19, r16, erase_screen_while_x
		addi r18, r18, 1
		ble r18, r17, erase_screen_while_y
	ret
	
draw_rect:
	# r4->START_X
	# r5->START_Y
	# sp(0)->X_LENGTH
	# sp(4)->Y_LENGTH
	# sp(8)->COLOR
	ldw r16, 0(sp)
	ldw r17, 4(sp)
	mov r18, r0
	ldw r10, 8(sp)
	
	draw_rect_while_y:
		movia r8, ADDR_VGA
		mov r19, r0
		slli r20, r18, 10
		add r8, r8, r20
		draw_rect_while_x:
			sthio r10, 0(r8)
			addi r19, r19, 1
			addi r8, r8, 2
			ble r19, r16, draw_rect_while_x
		addi r18, r18, 1
		ble r18, r17, draw_rect_while_y
	ret