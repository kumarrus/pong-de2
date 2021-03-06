#Uses registers r19-r23

.equ keyboard, 0x10000100
.equ gled, 0x10000010
.equ TIMER, 0x10002000

.section .exceptions, "ax"
ISR:
	subi sp, sp, 12 # To save ea, et, ctl1
	stw et, 0(sp)
	rdctl et, ctl1
	stw et, 4(sp)
	stw ea, 8(sp)
	rdctl et, ctl4
	andi et, et, 0x1         #Check if interrupt has been triggered on IRQ0, Priority = 1
	bne et, r0, TIMER_INT
	rdctl et, ctl4
	andi et, et, 0x80       #Check if interrupt has been triggered on IRQ7, Priority = 2
	bne et, r0, KEY_INT
	br EXIT_ISR
	
TIMER_INT:
	movia r19, BALL_X_SPEED
	ldw r20, 0(r19)
	movi r21, 1
	bge r20, r21, positivex
	br negativex
positivex:
	addi r20, r20, 0x1
	br storex
negativex:	
	subi r20, r20, 0x1
	br storex
storex:
	stw r20, 0(r19)
	
	movia r19, BALL_Y_SPEED
	ldw r20, 0(r19)
	movi r21, 1
	bge r20, r21, positivey
	br negativey
positivey:
	addi r20, r20, 0x1
	br storey
negativey:	
	subi r20, r20, 0x1
	br storey
storey:
	stw r20, 0(r19)
	
	# ack the timer interrupt
	movia et,TIMER
	stwio r0,0(et)

	br EXIT_ISR

KEY_INT:
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
	beq r21, r22, player1up 	#w  1D
	movi r22, 0x1B
	beq r21, r22, player1down	#s  1B
	movi r22, 0x75
	beq r21, r22, player2up		#8  75
	movi r22, 0x72
	beq r21, r22, player2down	#2  72
	br notMatched
	
	player1up:
		movia r23, gled
		movi r22, 0x2
		stwio r22, 0(r23)
		movia r19, PADDLE_1_DIR
		subi r20, r0, 0x1
		stw r20, 0(r19)
		br notMatched
	player1down:
		movia r23, gled
		movi r22, 0x1
		stwio r22, 0(r23)
		movia r19, PADDLE_1_DIR
		addi r20, r0, 0x1
		stw r20, 0(r19)
		br notMatched
	player2up:
		movia r23, gled
		movi r22, 0x8
		stwio r22, 0(r23)
		movia r19, PADDLE_2_DIR
		subi r20, r0, 0x1
		stw r20, 0(r19)
		br notMatched
	player2down:
		movia r23, gled
		movi r22, 0x4
		stwio r22, 0(r23)
		movia r19, PADDLE_2_DIR
		addi r20, r0, 0x1
		stw r20, 0(r19)
	
	notMatched:
		#check if there are still values left to read, if so go to begin
		srli r21, r21, 16
		bgt r21, r0, begin
		
	br EXIT_ISR
		
EXIT_ISR:
	ldw et, 4(sp)
	wrctl ctl1, et
	ldw et, 0(sp)
	ldw ea, 8(sp)
	addi sp, sp, 12
	subi ea, ea, 4
	eret

.section .text
.global keyboard_start

keyboard_start:

	movia r19, keyboard
	movia r20, gled

	#enable interrupts for keyboard
	addi r21, r0, 0x1
	stwio r21, 4(r19)

	#enable CPU interrupt from IRQ line 7 && IRQ line 1
	addi r21, r0, 0x81
	wrctl ctl3, r21

	#enable cpu interrupt
	addi r21, r0, 0x1
	wrctl ctl0, r21
	
	ret
