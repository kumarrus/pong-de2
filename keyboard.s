.include "Nios_macros.s"

.equ keyboard, 0x10000100
.equ gled, 0x10000010

.section .exceptions, "ax"
ISR:
	#reset gled to all off
	movia r9, gled
	movi r10, 0x0
	stwio r10, 0(r9)
	
	begin:
	movia r10, keyboard
	#ack interrupt
	ldb r9, (r10)
	#get 7-0 bit data by masking
	movi r10, 0xff
	and r9, r10, r9
	
	#check keyboard for valid input (it is up/down/left/right) if so, light led
	movi r10, 0x1D
	beq r9, r10, player1up 		#w  1D
	movi r10, 0x1B
	beq r9, r10, player1down	#s  1B
	movi r10, 0x75
	beq r9, r10, player2up		#8  75
	movi r10, 0x72
	beq r9, r10, player2down	#2  72
	br notMatched
	
	player1up:
		movia r11, gled
		movi r10, 0x1
		stwio r10, 0(r11)
		br notMatched
	player1down:
		movia r11, gled
		movi r10, 0x2
		stwio r10, 0(r11)
		br notMatched
	player2up:
		movia r11, gled
		movi r10, 0x3
		stwio r10, 0(r11)
		br notMatched
	player2down:
		movia r11, gled
		movi r10, 0x4
		stwio r10, 0(r11)
	
	notMatched:
		#check if there are still values left to read, if so go to begin
		srli r9, r9, 16
		bgt r9, r0, begin
		
	subi ea, ea, 4
	eret

.section .text
.global _start

_start:

movia r7, keyboard
movia r8, gled

#enable interrupts for keyboard
addi r9, r0, 0x1
stwio r9, 4(r7)

#enable CPU interrupt from IRQ line 7
addi r9, r0, 128
wrctl ctl3, r9

#enable cpu interrupt
addi r9, r0, 0x1
wrctl ctl0, r9

#wait for keyboard interrupt
loop:
	br loop

#r19-r23
