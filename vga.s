#---------------------------------------------------#
#	Register Tracker:
#	r4	->	Used in Subroutines to hold X,Y coordinates
#	r5	->	Used in Subroutines to hold X,Y coordinates
#	r6
#	r7
#	r8	->	ADDRESS Holder (VGA,TIMER)
#	r9
#	r10	
#	r11
#	r12
#	r13
#	r14
#	r15
#	r16
#	r17
#	r18
#	r19
#	r20
#	r21
#	r22
#	r23
#---------------------------------------------------#

.include "nios_macros.s"

.equ ADDR_VGA, 0x08000000
.equ ADDR_CHAR, 0x09000000
.equ TIMER, 0x10002000
.equ PERIOD, 5000000
.equ COL_WHITE, 0xffff
.equ COL_BLACK, 0x00000000
.equ MAX_X, 320
.equ MAX_Y,240
.equ SIZE_BALL_X, 3
.equ SIZE_BALL_Y, 3
.equ SIZE_PADDLE_X, 4
.equ SIZE_PADDLE_Y, 40
.global _start

_start:
	
	movia sp, 0x007ffffc
	call erase_screen
	movi r21, 0
	movi r4, 0
	movi r5, 0
	movi r22, SIZE_PADDLE_X
	movi r23, SIZE_PADDLE_Y
draw_inf:

	subi sp, sp, 24
	movi r15, 4
	stw r15, 0(sp)
	stw r21, 4(sp)
	addi r21, r21, 1
	
	movi r15, MAX_Y
	subi r15, r15, 41
	blt r21, r15, move
	movi r21, 0
move:
	movi r4, 4
	mov r5, r21
	stw r22, 8(sp)
	stw r23, 12(sp)
	movui r15, 0xffff  /* White pixel */
	stw r15, 16(sp)
	stw ra, 20(sp)
	call draw_rect
	ldw ra, 20(sp)
	addi sp, sp, 24
	call timer
	br draw_inf

infinite_loop:
	br infinite_loop

erase_screen:
	movi r16, MAX_X
	movi r17, MAX_Y 
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

#	r4->NEW_X
#	r5->NEW_Y
#	sp(0)->OLD_X
#	sp(4)->OLD_Y
#	sp(8)->X_LENGTH
#	sp(12)->Y_LENGTH
#	sp(16)->COLOR
	
draw_rect:
	ldw r11, 0(sp)
	ldw r12, 4(sp)
	ldw r16, 8(sp)
	ldw r17, 12(sp)
	slli r11, r11, 1
	slli r12, r12, 10
	movi r10, COL_BLACK
	mov r18, r0
	
	erase_rect_while_y:
		movia r8, ADDR_VGA
		add r8, r8, r11
		add r8, r8, r12
		mov r19, r0
		slli r20, r18, 10
		add r8, r8, r20
		erase_rect_while_x:
			sthio r10, 0(r8)
			addi r19, r19, 1
			addi r8, r8, 2
			ble r19, r16, erase_rect_while_x
		addi r18, r18, 1
		ble r18, r17, erase_rect_while_y
	
	ldw r10, 16(sp)
	slli r4, r4, 1
	slli r5, r5, 10
	mov r18, r0
	
	draw_rect_while_y:
		movia r8, ADDR_VGA
		add r8, r8, r4
		add r8, r8, r5
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
	
timer: 
	movia r8,TIMER
	movui r15,%lo(PERIOD)
	stwio r15,8(r8)
	movui r15,%hi(PERIOD)
	stwio r15,12(r8)

	stwio r0,0(r8)
	movui r15,0x6
	stwio r15,4(r8)

	pollt: 
		ldwio r15,0(r8)
		andi r15,r15,0x1
		beq r15,r0,pollt
   
	ret
