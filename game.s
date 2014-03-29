#---------------------------------------------------#
#	Register Tracker:
#	r4	->	Used in Subroutines to hold X,Y coordinates
#	r5	->	Used in Subroutines to hold X,Y coordinates
#	r6
#	r7
#		CALLER SAVED
#	r8	->	ADDRESS Holder (VGA,TIMER)
#	r9	->	Used in Subroutine
#	r10	->	Used in Subroutine
#	r11	->	Used in Subroutine
#	r12	->	Used in Subroutine
#	r13	->	Used in Subroutine
#	r14
#	r15
#		CALEE SAVED
#	r16	->	ADDRESS Holder for .data
#	r17
#	r18
#	r19
#	r20
#	r21
#	r22
#	r23
#---------------------------------------------------#

.include "nios_macros.s"

.equ TIMER, 0x10002000
.equ PERIOD, 5000000
.equ MAX_X, 320
.equ MAX_Y, 240
.equ SIZE_BALL_X, 3
.equ SIZE_BALL_Y, 3
.equ SIZE_PADDLE_X, 4
.equ SIZE_PADDLE_Y, 40
.equ COL_WHITE, 0xffff
.equ COL_BLACK, 0x0000

.section .data
PADDLE_1_X:
	.word 4
PADDLE_1_Y:
	.word 0
PADDLE_2_X:
	.word 311
PADDLE_2_Y:
	.word 0
BALL_X:
	.word 16
BALL_Y:
	.word 16

.section .text
.global _start
.global timer

_start:
	
	movia sp, 0x007ffffc		#0x17fff80
	call erase_screen
	movi r21, 0
	movi r4, 0
	movi r5, 0

draw_inf:
	subi sp, sp, 24
	stw ra, 20(sp)
	
	movia r16, PADDLE_1_X
	ldw r4, 0(r16)
	mov r15, r4
	
	movia r16, PADDLE_1_Y
	ldw r5, 0(r16)

increment_y:	
	addi r15, r15, 1
	stw r15, 0(r16)
	
	movi r15, MAX_Y
	subi r15, r15, 41
	ldw r17, 0(r16)
	
	blt r17, r15, move
	stw r0, 0(r16)

move:
	movia r16, PADDLE_1_X
	ldw r15, 0(r16)
	stw r15, 0(sp)
	
	movia r16, PADDLE_1_Y
	ldw r15, 0(r16)
	stw r15, 4(sp)

	movi r15, SIZE_PADDLE_X
	stw r15, 8(sp)
	movi r15, SIZE_PADDLE_Y
	stw r15, 12(sp)
	
	movui r15, COL_WHITE
	stw r15, 16(sp)
	
	call draw_rect
	call timer

	ldw ra, 20(sp)
	addi sp, sp, 24

	br draw_inf

infinite_loop:
	br infinite_loop
	
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
