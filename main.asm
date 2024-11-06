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
.eqv SNAKE_RIGHT 0x0000FF00
.eqv SNAKE_DOWN  0x0100FF00
.eqv SNAKE_LEFT  0x0200FF00
.eqv SNAKE_UP    0x0300FF00

.eqv INITIAL_TAIL 0x10010000
.eqv INITIAL_HEAD 0x10010004
.eqv BG_COLOR BLACK
.eqv SNAKE_COLOR WHITE
.eqv MAX_SIZE 4096  #  Total units: (512/8) * (512/8) = 64 x 64 = 4096 pixels


.text
.globl main

# Initial setup
init:
    la      $t0, main
    jalr    $t0                
    la      $t0, finit
    jr      $t0                

finit:
    move    $a0, $v0          
    li      $v0, 17            
    syscall   

.include "display_bitmap.asm"

# Main function
main:
    addiu   $sp, $sp, -4     
    sw      $ra, 0($sp) 

    jal init_snake

        jal move_down
                jal move_down
       
                        
       
               
    # Restore saved registers and return
    lw      $ra, 0($sp)      
    addiu   $sp, $sp, 4      
    jr      $ra 

# Paint the starting snake on the screen
init_snake:
    addiu   $sp, $sp, -4
    sw      $ra, 0($sp)       # Save $r

    # The snake head and tail will ALWAYS be in $s6 and $s7
    li      $s6, INITIAL_TAIL     # Tail X in $s0
    li      $s7, INITIAL_HEAD     # Tail Y in $s1
   
    # Initialize snake segments (all moving right initially)
    li      $t0, SNAKE_RIGHT    # Direction flag (right)
    sw      $t0, 0($s6)        # Store direction in the color of tail
    sw      $t0, 0($s7)        # Store direction in the color of head

    # Epilogue
    lw      $ra, 0($sp)
    addiu   $sp, $sp, 4    
    jr      $ra
    
move_up:
    addiu   $sp, $sp, -4
    sw      $ra, 0($sp)
    
    # Move right (increase X)
    addiu   $s7, $s7, -256 # Size of row, so we go 1 row down

    # Check for wraparound on the right
    li      $t1, 64
    blt     $t0, $t1, move_up_cont   # If X < 64, continue
    # Implement collision = lost

move_up_cont:
    # Store the new head X position
    li      $t2, SNAKE_UP
    sw      $t2, 0($s7)  # Store direction flag for head segment

    jal	    erase_tail		

    # Restore state and return
    lw      $ra, 0($sp)
    addiu   $sp, $sp, 4
    jr      $ra

# Move the snake down
move_down:
    addiu   $sp, $sp, -4
    sw      $ra, 0($sp)
    
    # Move right (increase X)
    addiu   $s7, $s7, 0x00000100 # Size of row (256), so we go 1 row down

    # Check for wraparound on the right
    li      $t1, 64
    blt     $t0, $t1, move_down_cont   # If X < 64, continue
    # Implement collision = lost

move_down_cont:
    # Store the new head X position
    li      $t2, SNAKE_DOWN
    sw      $t2, 0($s7)  # Store direction flag for head segment

    jal	    erase_tail		

    # Restore state and return
    lw      $ra, 0($sp)
    addiu   $sp, $sp, 4
    jr      $ra

# Move the snake left
move_left:
    addiu   $sp, $sp, -4
    sw      $ra, 0($sp)
    
    # Move right (increase X)
    addiu   $s7, $s7, -4

    # Check for wraparound on the right
    li      $t1, 64
    blt     $t0, $t1, move_left_cont   # If X < 64, continue

move_left_cont:
    # Store the new head X position
    li      $t2, SNAKE_LEFT
    sw      $t2, 0($s7)  # Store direction flag for head segment

    jal	    erase_tail		

    # Restore state and return
    lw      $ra, 0($sp)
    addiu   $sp, $sp, 4
    jr      $ra

move_right:
    addiu   $sp, $sp, -4
    sw      $ra, 0($sp)
    
    # Move right (increase X)
    addiu   $s7, $s7, 4

    # Check for wraparound on the right
    li      $t1, 64
    blt     $t0, $t1, move_right_cont   # If X < 64, continue
    # Implement collision = lost

move_right_cont:
    # Store the new head X position
    li      $t2, SNAKE_RIGHT
    sw      $t2, 0($s7)  # Store direction flag for head segment

    jal	    erase_tail		

    # Restore state and return
    lw      $ra, 0($sp)
    addiu   $sp, $sp, 4
    jr      $ra

erase_tail:	
    lw      $t0, 0($s6)      # Tail direction
    li      $t1, BG_COLOR    # Load the background color to erase

    # Clear the tail position
    sw      $t1, 0($s6)

    # Check the tail direction flag and move accordingly
    li      $t3, SNAKE_RIGHT
    beq     $t0, $t3, erase_right

    li      $t3, SNAKE_DOWN
    beq     $t0, $t3, erase_down

    li      $t3, SNAKE_LEFT
    beq     $t0, $t3, erase_left

    li      $t3, SNAKE_UP
    beq     $t0, $t3, erase_up

    jr      $ra

erase_right:
    addiu   $s6, $s6, 4  # Move right (x++)
    jr      $ra

erase_down:
    addiu   $s6, $s6, 0x00000100  # Move down (y++)
    li $v0, 17
    syscall
    jr      $ra

erase_left:
    addiu   $s6, $s6, -4  # Move left (x--)
    jr      $ra

erase_up:
    addiu   $s6, $s6, -0x00000100  # Move up (y--)
    jr      $ra