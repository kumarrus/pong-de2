#---------------------------------------------------#
#	Register Tracker:
#	r4	->	
#	r5	->	
#	r6	->	Used to hold x,y increment for moving ball
#	r7
#		CALLER SAVED
#	r8	->	ADDRESS Holder (VGA,TIMER)
#	r9	->	Used in Subroutine
#	r10	->	Used in Subroutine
#	r11	->	Used in Subroutine
#	r12	->	Used in Subroutine
#	r13	->	Used in Subroutine
#	r14
#	r15	->	Temp reg
#		CALEE SAVED
#	r16	->	ADDRESS Holder for .data
#	r17	->	Temp reg
#	r18
#	r19
#	r20
#	r21
#	r22
#	r23
#---------------------------------------------------#

#.include "nios_macros.s"

.equ TIMER, 0x10002000
.equ PERIOD, 500000000
.equ MAX_X, 320
.equ MAX_Y, 240
.equ SIZE_BALL_X, 3
.equ SIZE_BALL_Y, 3
.equ SIZE_PADDLE_X, 4
.equ SIZE_PADDLE_Y, 40
.equ COL_WHITE, 0xffff
.equ COL_BLACK, 0x0000
.equ PUSH_BUTTONS, 0x10000050
.equ AUDIO_FIFO, 0x10003040

.global PADDLE_1_DIR
.global PADDLE_2_DIR
.global BALL_X_SPEED
.global BALL_Y_SPEED

.section .data
PADDLE_1_X:
	.word 4
PADDLE_1_Y:
	.word 0
PADDLE_2_X:
	.word 311
PADDLE_2_Y:
	.word 10
BALL_X:
	.word 16
BALL_Y:
	.word 16
BALL_X_SPEED:
	.word 1
BALL_Y_SPEED:
	.word 1
PADDLE_1_DIR:
	.word 1
PADDLE_2_DIR:
	.word -1
PLAYER_1_LIFE:
	.word 0
PLAYER_2_LIFE:
	.word 0
SOUND_1:
	.word 5
SOUND_2:
	.word -5
	
.section .text
.global main
.global timer
.global move_paddle_1
.global move_paddle_2
.global move_ball

main:
	
	movia sp, 0x007ffffc		#0x17fff80
	movi r4, 0
	movi r5, 0
	call timer_set
	call keyboard_start
	movia r16, PLAYER_1_LIFE
	ldw r15, 0(r16)
	addi r15, r0, 6
	stw r15, 0(r16)
	movia r16, PLAYER_2_LIFE
	ldw r15, 0(r16)
	addi r15, r0, 6
	stw r15, 0(r16)
	call erase_screen
	call erase_char_buffer
	call delay_counter
	movi r4, 0
	movi r5, 0
	game_start:
		call draw_game_start
		movia r16, PUSH_BUTTONS
		ldwio r17, 0(r16)
		movi r18, 0x2
		beq r17, r18, exit_loop_start
		
		start_music:
		movia r16, AUDIO_FIFO
		ldwio r17, 4(r16)
		andi r17, r17, 0xff
		beq r17, r0, start_music
		ldwio r17, 8(r16)
		stwio r17, 8(r16)
		ldwio r17, 12(r16)
		stwio r17, 12(r16)
			
	br game_start
exit_loop_start:
	call erase_screen
	call erase_char_buffer
	call delay_counter
	movi r4, 0
	movi r5, 0
	infinite_loop:
		call move_paddle_1
		call move_paddle_2
		call move_ball
		movia r16, PLAYER_2_LIFE
		ldw r4, 0(r16)
		movia r16, PLAYER_1_LIFE
		ldw r5, 0(r16)
		call display_hex
		
		run_music:
		movia r16, AUDIO_FIFO
		ldwio r17, 4(r16)
		andi r17, r17, 0xff
		beq r17, r0, run_music
		ldwio r17, 8(r16)
		stwio r17, 8(r16)
		ldwio r17, 12(r16)
		stwio r17, 12(r16)
	br infinite_loop
	
	game_over_1:
	game_over_2:
		movia r16, PLAYER_2_LIFE
		ldw r4, 0(r16)
		movia r16, PLAYER_1_LIFE
		ldw r5, 0(r16)
		call draw_game_over
				
		movia r16, PUSH_BUTTONS
		ldwio r17, 0(r16)
		movi r18, 0x2
		beq r17, r18, main

		end_music: 
		movia r16, AUDIO_FIFO
		ldwio r17, 4(r16)
		andi r17, r17, 0xff
		beq r17, r0, end_music
		ldwio r17, 8(r16)
		stwio r17, 8(r16)
		ldwio r17, 12(r16)
		stwio r17, 12(r16)
		
		br game_over_2
	
move_paddle_1:
	subi sp, sp, 24
	stw ra, 20(sp)
	
	movia r16, PADDLE_1_X
	ldw r4, 0(r16)
	
	movia r16, PADDLE_1_Y
	ldw r5, 0(r16)

	increment_y_1:	
		movia r16, PADDLE_1_Y
		ldw r15, 0(r16)
		
		movia r16, PADDLE_1_DIR
		ldw r17, 0(r16)
		add r15, r15, r17
		
		movi r17, MAX_Y
		subi r17, r17, SIZE_PADDLE_Y
		subi r17, r17, 1
		
		move_1:
			bge r15, r17, paddle_1_draw
			ble r15, r0, paddle_1_draw
			
			movia r16, PADDLE_1_Y
			#addi r15, r15, 1
			stw r15, 0(r16)
		br paddle_1_draw

		reset_1:
			stw r0, 0(r16)	

	paddle_1_draw:
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
		call delay_counter

	ldw ra, 20(sp)
	addi sp, sp, 24

	ret
	
move_paddle_2:
	subi sp, sp, 24
	stw ra, 20(sp)
	
	movia r16, PADDLE_2_X
	ldw r4, 0(r16)
	#mov r15, r4
	
	movia r16, PADDLE_2_Y
	ldw r5, 0(r16)

	increment_y_2:	
		movia r16, PADDLE_2_Y
		ldw r15, 0(r16)
		
		movia r16, PADDLE_2_DIR
		ldw r17, 0(r16)
		add r15, r15, r17
		
		movi r17, MAX_Y
		subi r17, r17, SIZE_PADDLE_Y
		subi r17, r17, 1
		
		move_2:
			bge r15, r17, paddle_2_draw
			ble r15, r0, paddle_2_draw
			
			movia r16, PADDLE_2_Y
			#addi r15, r15, -1
			stw r15, 0(r16)
		br paddle_2_draw

		reset_2:
			stw r17, 0(r16)

	paddle_2_draw:
		movia r16, PADDLE_2_X
		ldw r15, 0(r16)
		stw r15, 0(sp)
		
		movia r16, PADDLE_2_Y
		ldw r15, 0(r16)
		stw r15, 4(sp)

		movi r15, SIZE_PADDLE_X
		stw r15, 8(sp)
		movi r15, SIZE_PADDLE_Y
		stw r15, 12(sp)
		
		movui r15, COL_WHITE
		stw r15, 16(sp)
		
		call draw_rect
		call delay_counter

	ldw ra, 20(sp)
	addi sp, sp, 24

	ret


move_ball:
	subi sp, sp, 24
	stw ra, 20(sp)
	
	movia r16, BALL_X
	ldw r4, 0(r16)
	
	movia r16, BALL_Y
	ldw r5, 0(r16)

	increment_y:	
		movia r16, BALL_Y
		ldw r15, 0(r16)
		movia r16, BALL_Y_SPEED
		ldw r6, 0(r16)
		add r15, r15, r6
		
		PADDLE_1_BOUNCE_Y:
			#Paddle bounce 1 y
			movia r16, PADDLE_1_Y
			ldw r17, 0(r16)
			cmpge r18, r15, r17
			beq r18, r0, PADDLE_2_BOUNCE_Y
			addi r17, r17, SIZE_PADDLE_Y
			cmplt r18, r15, r17
			
		PADDLE_2_BOUNCE_Y:
			#Paddle bounce 1 y
			movia r16, PADDLE_2_Y
			ldw r17, 0(r16)
			cmpge r7, r15, r17
			beq r7, r0, BOUNCE_WALL_Y
			addi r17, r17, SIZE_PADDLE_Y
			cmplt r7, r15, r17
		
		BOUNCE_WALL_Y:
			movi r17, MAX_Y
			subi r17, r17, SIZE_BALL_Y
			
			bge r15, r17, bounce_up
			blt r15, r0, bounce_down
		movia r16, BALL_Y
		stw r15, 0(r16)
		br increment_x
		
		bounce_up:	
			movia r16, BALL_Y_SPEED
			mov r6, r0
			movi r6, -1
			stw r6, 0(r16)
			
			movia r16, BALL_Y
			ldw r15, 0(r16)
			add r15, r15, r6
			stw r15, 0(r16)
		br increment_x

		bounce_down:
			movia r16, BALL_Y_SPEED
			mov r6, r0
			movi r6, 1
			stw r6, 0(r16)
			
			movia r16, BALL_Y
			ldw r15, 0(r16)
			add r15, r15, r6
			stw r15, 0(r16)
		br increment_x
		
		
	increment_x:
		movia r16, BALL_X
		ldw r15, 0(r16)
		movia r16, BALL_X_SPEED
		ldw r6, 0(r16)
		add r15, r15, r6
		
		PADDLE_1_BOUNCE:
			#Paddle bounce 1
			movia r16, PADDLE_1_X
			ldw r17, 0(r16)
			addi r17, r17, SIZE_PADDLE_X
			blt r15, r17, IN_1_X
			br PADDLE_2_BOUNCE
		IN_1_X:
			#cmpeqi r18, r18, 0x1
			beq r18, r0, PADDLE_2_BOUNCE
			br bounce_right
		
		PADDLE_2_BOUNCE:
			#Paddle bounce 2
			movia r16, PADDLE_2_X
			ldw r17, 0(r16)
			subi r17, r17, SIZE_BALL_X
			bge r15, r17, IN_2_X
			br BOUNCE_WALL_X
		IN_2_X:
			#cmpeqi r7, r7, 0x1
			beq r7, r0, BOUNCE_WALL_X
			br bounce_left
			
		BOUNCE_WALL_X:
			movi r17, MAX_X
			subi r17, r17, SIZE_BALL_X
			
			#Wall bounce
			bge r15, r17, player_2_die
			ble r15, r0, player_1_die
		
		movia r16, BALL_X
		stw r15, 0(r16)
		br ball_draw
		
		player_2_die:
			movia r16, PLAYER_2_LIFE
			ldw r15, 0(r16)
			subi r15, r15, 1
			beq r15, r0, game_over_2
			stw r15, 0(r16)
			br bounce_left

		player_1_die:
			movia r16, PLAYER_1_LIFE
			ldw r15, 0(r16)
			subi r15, r15, 1
			beq r15, r0, game_over_1
			stw r15, 0(r16)
			br bounce_right
		
		bounce_left:	
			movia r16, BALL_X_SPEED
			ldw r6, 0(r16)
			movi r6, -1
			#sub r6, r0, r6
			stw r6, 0(r16)
			
			movia r16, BALL_X
			ldw r15, 0(r16)
			add r15, r15, r6
			stw r15, 0(r16)
		br ball_draw

		bounce_right:
			movia r16, BALL_X_SPEED
			ldw r6, 0(r16)
			movi r6, 1
			#sub r6, r0, r6 
			stw r6, 0(r16)
			
			movia r16, BALL_X
			ldw r15, 0(r16)
			add r15, r15, r6
			stw r15, 0(r16)
		br ball_draw


	ball_draw:
		movia r16, BALL_X
		ldw r15, 0(r16)
		stw r15, 0(sp)
		
		movia r16, BALL_Y
		ldw r15, 0(r16)
		stw r15, 4(sp)

		movi r15, SIZE_BALL_X
		stw r15, 8(sp)
		movi r15, SIZE_BALL_Y
		stw r15, 12(sp)
		
		movui r15, COL_WHITE
		stw r15, 16(sp)
		
		call draw_rect
		call delay_counter

	ldw ra, 20(sp)
	addi sp, sp, 24

	ret

	
#timer: 
#	movia r8,TIMER
#	movui r15,%lo(PERIOD)
#	stwio r15,8(r8)
#	movui r15,%hi(PERIOD)
#	stwio r15,12(r8)
#
#	stwio r0,0(r8)
#	movui r15,0x6
#	stwio r15,4(r8)
#
#	pollt: 
#		ldwio r15,0(r8)
#		andi r15,r15,0x1
#		beq r15,r0,pollt
#   
#	ret

timer_set: 
	movia r8,TIMER
	movui r15,%lo(PERIOD)
	stwio r15,8(r8)
	movui r15,%hi(PERIOD)
	stwio r15,12(r8)

	# enable interrupts on timer
	stwio r0,0(r8)
	movui r15,0x7
	stwio r15,4(r8)
	
	# Enable IRQ line
	#movi r21, 0b1 #IRQ0 for timer
	#wrctl ctl3, r21 #ctl3 - ienable
	ret
	
delay_counter:
	movia r15,50000 /* set starting point for delay counter */
	DELAYG:
		subi r15,r15,1       /* subtract 1 from delay */
		bne r15,r0, DELAYG   /* continue subtracting if delay has not elapsed */
			
	ret

#tone:
#movia r19, AUDIO_FIFO
#movia r20, SOUND_1
#movi r21, 0xFFF
#movi r16, 0xFFF
#movi r22, 0
#movi r23, 0 

#ldwio r20, 8(r19)
#ldwio r20, 12(r19)
#addi r22, r22, 0x1
#bleu r22, r21, tone
#movi r22, 0

#tone2:
#movia r20, SOUND_2
#ldwio r20, 8(r19)
#ldwio r20, 12(r19)
#addi r22, r22, 0x1
#bleu r22, r21, tone2

#addi r23, r23, 0x1
#bleu r23, r16, tone

#ret
