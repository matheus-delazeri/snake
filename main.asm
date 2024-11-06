    #---------------------------------------------------------------#
    #	Display Configuration					#
    #---------------------------------------------------------------#
    #	Unit Width in pixels: 8					#
    #	Unit Height in Pixels: 8				#
    #	Display Width in Pixels: 512				#
    #	Display Height in Pixels: 512  			#
    #---------------------------------------------------------------#


    # Direction Flags (encoded in color value)
    # 00 = Right, 01 = Down, 02 = Left, 03 = Up
    .eqv SNAKE_RIGHT, 0x0000FF00
    .eqv SNAKE_DOWN, 0x0100FF00
    .eqv SNAKE_LEFT, 0x0200FF00
    .eqv SNAKE_UP, 0x0300FF00

    .eqv INITIAL_TAIL, 0x10010000
    .eqv INITIAL_HEAD, 0x10010004
    
    .eqv BG_COLOR, BLACK
    .eqv SNAKE_COLOR, WHITE
    .eqv APPLE_COLOR, RED

.text
    .globl main

    # Initial setup
init:
    la $t0, main
    jalr    $t0
    la $t0, finit
    jr $t0

finit:
    move    $a0, $v0
    li $v0, 17
    syscall

.include "display_bitmap.asm"

main:
    addiu   $sp, $sp, -4
    sw $ra, 0($sp)

    li $a0, BG_COLOR
    jal set_background_color
    jal screen_init2
    jal init_snake

    lw $ra, 0($sp)
    jr $ra

# Paint the starting snake on the screen
init_snake:
    addiu   $sp, $sp, -4
    sw $ra, 0($sp) # Save $ra

    # The snake head and tail will ALWAYS be in $s6 and $s7
    li $s6, INITIAL_TAIL # Tail X in $s0
    li $s7, INITIAL_HEAD # Tail Y in $s1

    # Initialize snake segments (all moving right initially)
    li $t0, SNAKE_RIGHT  # Direction flag (right)
    sw $t0, 0($s6) # Store direction in the color of tail
    sw $t0, 0($s7) # Store direction in the color of head
    jal generate_apple
    jal move_right

    lw $ra, 0($sp)
    addiu   $sp, $sp, 4
    jr $ra

move_up:
    addiu $sp, $sp, -8
    sw    $ra, 4($sp)
    sw    $s0, 0($sp)
    
    move $s0, $a0 # Erase tail?
    # Move up (decrease Y)
    addiu   $a0, $s7, -256
    li      $a1, SNAKE_UP
    jal update_head
    
    beqz $s0, move_up_cont
    jal erase_tail

move_up_cont:
    jal wait_keyboard
    lw $t7, 0xFFFF0004
    beq $t7, 0x00000061, move_left  # a key is pressed
    beq $t7, 0x00000064, move_right # d key is pressed
    beq $t7, 0x00000071, finit    # q key is pressed

    lw $ra, 4($sp)
    lw $s0, 0($sp)
    addiu $sp, $sp, 8
    jal move_up

# Move the snake down
move_down:
    addiu $sp, $sp, -8
    sw    $ra, 4($sp)
    sw    $s0, 0($sp)
    
    move $s0, $a0 # Erase tail?
    # Move down (increase Y)
    addiu   $a0, $s7, 256
    li      $a1, SNAKE_DOWN
    jal update_head
    
    beqz $s0, move_left_cont
    jal erase_tail
    
move_down_cont:
    jal wait_keyboard
    lw $t7, 0xFFFF0004
    beq $t7, 0x00000061, move_left  # a key is pressed
    beq $t7, 0x00000064, move_right # d key is pressed
    beq $t7, 0x00000071, finit    # q key is pressed

    lw $ra, 4($sp)
    lw $s0, 0($sp)
    addiu $sp, $sp, 8
    jal move_down

# Move the snake left
move_left:
    addiu $sp, $sp, -8
    sw    $ra, 4($sp)
    sw    $s0, 0($sp)
    
    move $s0, $a0 # Erase tail?
    # Move left (increase X)
    addiu   $a0, $s7, -4
    li      $a1, SNAKE_LEFT
    jal update_head
    
    beqz $s0, move_left_cont
    jal erase_tail

move_left_cont:
    jal wait_keyboard
    lw $t7, 0xFFFF0004
    beq $t7, 0x00000077, move_up  # w key is pressed
    beq $t7, 0x00000073, move_down  # s key is pressed
    beq $t7, 0x00000071, finit    # q key is pressed

    lw $ra, 4($sp)
    lw $s0, 0($sp)
    addiu $sp, $sp, 8
    jal move_left

# Paramters
# $a0: erase tail? 1 = yes, 0 = no
move_right:
    addiu $sp, $sp, -8
    sw    $ra, 4($sp)
    sw    $s0, 0($sp)
    
    move $s0, $a0 # Erase tail?
    # Move right (increase X)
    addiu   $a0, $s7, 4
    li      $a1, SNAKE_RIGHT
    jal update_head
    
    beqz $s0, move_right_cont
    jal erase_tail

move_right_cont:
    jal wait_keyboard
    lw $t7, 0xFFFF0004   # Verifying which key is pressed
    beq $t7, 0x00000077, move_up  # w key is pressed
    beq $t7, 0x00000073, move_down  # s key is pressed
    beq $t7, 0x00000071, finit    # q key is pressed

    lw $ra, 4($sp)
    lw $s0, 0($sp)
    addiu $sp, $sp, 8
    jal move_right

# Parameters:
# $a0: new head address
# $a1: head direction

update_head:
    addiu $sp, $sp, -16
    sw    $ra, 12($sp)
    sw    $s2, 8($sp) # Has apple
    sw    $s1, 4($sp) # New address
    sw    $s0, 0($sp) # Old address
  
    move $s0, $s7
    move $s1, $a0 # New address
    jal verify_head
    move $s2, $v0
    move $s7, $s1
    
    sw $a1, 0($s7) # Store direction flag for head segment
    sw $a1, 0($s0) # Store the direction in the old position
   
    beqz $s2, update_head_end 
    jal generate_apple
    jal add_point

update_head_end:   
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $ra, 12($sp)
    addiu $sp, $sp, 16
    jr $ra

# Check if the head is positioned in a valid byte or an apple.
# Parameters:
# $a0: new head address
#
# $v0: is apple (1 or 0)
verify_head:
    lw $t0, 0($a0)
    li $t1, APPLE_COLOR
    seq $v0, $t1, $t0
    bnez $v0, verify_head_end # If it's an apple
            
    bne $t0, BG_COLOR, game_over # If new position is a part of snake, game over
verify_head_end:
    jr $ra

game_over:
    # Game Over: End the game by jumping to the finit function
    jal finit

generate_apple:
# Generate random number
	li $a1, 1112	# Here $a1 configures the max value wich is the number of units on display (0 til 1023).
    	li $v0, 42  	#generates the random number.
    	syscall
# Verify if it's inside the playabe area
	move $t0, $a0		
	sll $t0, $t0, 2		# Computing new apple address
	li $t3, DISPLAY_MEMORY_BASE
	add $t3, $t3, $t0	#
	lw $t0, 0($t3)		# get new add content
	bne $t0, BG_COLOR, generate_apple # if new apple address content is not blank, try again
# Painting apple pixel
	li $t0, RED
	sw $t0, 0($t3)
	
	jr $ra
	
add_point:
	lw $t0, 0($s7) # Current direction
	li $a0, 0 # Erase tail = no
	
	beq $t0, SNAKE_RIGHT, move_right
	beq $t0, SNAKE_LEFT, move_left
        beq $t0, SNAKE_UP, move_up
        beq $t0, SNAKE_DOWN, move_down
	
wait_keyboard:
    sub $sp, $sp, 4
    sw $ra, 0($sp)

    li $a0, 0xFFFF0000
    jal wait

    lw $ra, 0($sp)
    add $sp, $sp, 4
    jr $ra
wait:
    lw $t0, 0($a0)
    and $t0, 0x00000001
    beq $t0, $zero,   wait

    jr $ra

erase_tail:
    addiu   $sp, $sp, -4
    sw $ra, 0($sp)

    lw $t0, 0($s6) # Tail direction
    li $t1, BG_COLOR   # Load the background color to erase

    # Clear the tail position
    sw $t1, 0($s6)

    # Check the tail direction flag and move accordingly
    li $t3, SNAKE_RIGHT
    beq $t0, $t3, erase_right

    li $t3, SNAKE_DOWN
    beq $t0, $t3, erase_down

    li $t3, SNAKE_LEFT
    beq $t0, $t3, erase_left

    li $t3, SNAKE_UP
    beq $t0, $t3, erase_up

    # Restore state and return
    lw $ra, 0($sp)
    addiu   $sp, $sp, 4
    jr $ra

erase_right:
    addiu   $s6, $s6, 4   # Move right (x++)
    jr $ra

erase_down:
    addiu   $s6, $s6, 0x00000100 # Move down (y++)
    jr $ra

erase_left:
    addiu   $s6, $s6, -4  # Move left (x--)
    jr $ra

erase_up:
    addiu   $s6, $s6, -0x00000100 # Move up (y--)
    jr $ra
