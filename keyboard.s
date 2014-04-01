.include "Nios_macros.s"

.equ keyboard, 0x10000100
.equ gled, 0x10000010
.equ timer, 0x10002000

.section .exceptions, "ax"
ISR:
	#reset gled to all off
	movia r21, gled
	movi r22, 0x0
	stwio r22, 0(r21)
	
	begin:
	movia r22, keyboard
	#ack interrupt
	ldb r21, (r22)
	#get 7-0 bit data by masking
	movi r22, 0xff
	and r21, r22, r21
	
	#check keyboard for valid input (it is up/down/left/right) if so, light led
	movi r22, 0x1D
	beq r21, r22, player1up 		#w  1D
	movi r22, 0x1B
	beq r21, r22, player1down	#s  1B
	movi r22, 0x75
	beq r21, r22, player2up		#8  75
	movi r22, 0x72
	beq r21, r22, player2down	#2  72
	br notMatched
	
	player1up:
		movia r23, gled
		movi r22, 0x1
		stwio r22, 0(r23)
		br notMatched
	player1down:
		movia r23, gled
		movi r22, 0x2
		stwio r22, 0(r23)
		br notMatched
	player2up:
		movia r23, gled
		movi r22, 0x3
		stwio r22, 0(r23)
		br notMatched
	player2down:
		movia r23, gled
		movi r22, 0x4
		stwio r22, 0(r23)
	
	notMatched:
		#check if there are still values left to read, if so go to begin
		srli r21, r21, 16
		bgt r21, r0, begin
		
	subi ea, ea, 4
	eret

.section .text
.global _start

_start:

movia r19, keyboard
movia r20, gled
movia r

#enable interrupts for keyboard
addi r21, r0, 0x1
stwio r21, 4(r19)

#enable CPU interrupt from IRQ line 7
addi r21, r0, 128
wrctl ctl3, r21

#enable cpu interrupt
addi r21, r0, 0x1
wrctl ctl0, r21

#wait for keyboard interrupt
loop:
	br loop

