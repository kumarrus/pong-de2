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
#	r16
#	r17
#	r18
#	r19
#	r20
#	r21
#	r22
#	r23
#---------------------------------------------------#

.equ ADDR_VGA, 0x08000000
.equ ADDR_CHAR, 0x09000000
.equ COL_BLACK, 0x0000

.global draw_rect

#---------------------------------------------------#
#.global erase_screen
#
#erase_screen:
#	movi r4, MAX_X
#	movi r5, MAX_Y 
#	movui r10, COL_BLACK
#	mov r11, r0
#	erase_screen_while_y:
#		movia r8, ADDR_VGA
#		mov r12, r0
#		slli r13, r11, 10
#		add r8, r8, r13
#		erase_screen_while_x:
#			sthio r10, 0(r8)
#			addi r12, r12, 1
#			addi r8, r8, 2
#			ble r19, r4, erase_screen_while_x
#		#
#		addi r11, r11, 1
#		ble r11, r5, erase_screen_while_y
#	#
#	
#	ret
#---------------------------------------------------#
#---------------------------------------------------#
#	r4		->	OLD_X
#	r5		->	OLD_Y
#	sp(0)	->	NEW_X
#	sp(4)	->	NEW_Y
#	sp(8)	->	X_LENGTH
#	sp(12)	->	Y_LENGTH
#	sp(16)	->	COLOR
#---------------------------------------------------#
draw_rect:
	slli r4, r4, 1
	slli r5, r5, 10
	movi r10, COL_BLACK
	mov r11, r0
	
	erase_rect_while_y:
		movia r8, ADDR_VGA
		add r8, r8, r4
		add r8, r8, r5
		mov r12, r0
		slli r13, r11, 10
		add r8, r8, r13
		erase_rect_while_x:
			sthio r10, 0(r8)
			addi r12, r12, 1
			addi r8, r8, 2
			ldw r9, 8(sp)	# Load X length
			ble r12, r9, erase_rect_while_x
		#
		addi r11, r11, 1
		ldw r9, 12(sp)	# Load Y length
		ble r11, r9, erase_rect_while_y
	#
	
	ldw r4, 0(sp)
	ldw r5, 4(sp)
	slli r4, r4, 1
	slli r5, r5, 10
	ldw r10, 16(sp)	# Load COLOR of paddle
	mov r11, r0
	
	draw_rect_while_y:
		movia r8, ADDR_VGA
		add r8, r8, r4
		add r8, r8, r5
		mov r12, r0
		slli r13, r11, 10
		add r8, r8, r13
		draw_rect_while_x:
			sthio r10, 0(r8)
			addi r12, r12, 1
			addi r8, r8, 2
			ldw r9, 8(sp)	# Load X length
			ble r12, r9, draw_rect_while_x
		#
		addi r11, r11, 1
		ldw r9, 12(sp)	# Load Y length
		ble r11, r9, draw_rect_while_y
	#
	
	ret
