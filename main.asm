#---------------------------------------------------------------#
#	Display Configuration					#
#---------------------------------------------------------------#
#	Unit Width in pixels: 8					#
#	Unit Height in Pixels: 8				#
#	Display Width in Pixels: 512				#
#	Display Height in Pixels: 512  			#
#---------------------------------------------------------------#

.eqv INITIAL_X 10
.eqv INITIAL_Y 10
.eqv INITIAL_SIZE 5
.eqv MAX_SIZE 4096  #  Total units: (512/8) * (512/8) = 64 x 64 = 4096 pixels


.data
snake_size: .word 5 # Address for snake size
snake_tail: .word 0 # Address for snake tail
snake_head: .word 0 # Address for snake head

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
    addiu   $sp, $sp, -16       
    sw      $ra, 12($sp)
    sw      $s0, 8($sp)
    sw      $s1, 4($sp)
    sw      $s2, 0($sp)  

    # Load snake parameters into $a registers for paint_snake
    lw      $a0, snake_tail    # Load address of snake_tail into $a0
    lw      $a1, snake_head    # Load address of snake_head into $a1
    li      $a2, INITIAL_SIZE  # Load the initial size of the snake

    jal paint_snake

    # Restore saved registers and return
    lw      $s2, 0($sp)
    lw      $s1, 4($sp)
    lw      $s0, 8($sp)
    lw      $ra, 12($sp)      
    addiu   $sp, $sp, 16      
    jr      $ra 

# Paint the starting snake on the screen
# Parameters:
#   $a0 - Address of snake_tail
#   $a1 - Address of snake_head
#   $a2 - Size of the snake
paint_snake:
    addiu   $sp, $sp, -20
    sw      $ra, 16($sp)       # Save $ra
    sw      $s0, 12($sp)       # Save $s0 (tail X)
    sw      $s1, 8($sp)        # Save $s1 (tail Y)
    sw      $s2, 4($sp)        # Save $s2 (size)

    li      $s0, INITIAL_X     # Tail X in $s0
    li      $s1, INITIAL_Y     # Tail Y in $s1
    add     $s2, $s0, $a2      # Head X = Tail X + size
    addiu   $s2, $s2, -1       # Adjust Head X
   
    # Save coordinates for drawing
    sw      $s0, 0($sp)        # Tail X
    sw      $s1, 4($sp)        # Tail Y
    sw      $s2, 8($sp)        # Head X

    # Move values for extremity update
    move    $a0, $s0           # Tail X
    move    $a1, $s1           # Tail Y
    move    $a2, $s2           # Head X
    move    $a3, $s1           # Head Y

    jal     update_extremity_pos

    # Move values for drawing
    lw      $t0, 0($sp)        # Tail X
    lw      $t1, 4($sp)        # Tail Y
    lw      $t3, 8($sp)        # Head X
    move    $a0, $t0           # Tail X
    move    $a1, $t1           # Tail Y
    move    $a2, $t3           # Head X
    move    $a3, $t1           # Head Y
    jal     draw_line

    # Epilogue
    lw      $s2, 4($sp)
    lw      $s1, 8($sp)
    lw      $s0, 12($sp)
    lw      $ra, 16($sp)
    addiu   $sp, $sp, 20    
    jr      $ra

# Update the tail and head position of the snake
# $a0: Tail X  
# $a1: Tail Y      
# $a2: Head X       
# $a3: Head Y 
update_extremity_pos:
    addiu   $sp, $sp, -8
    sw      $ra, 4($sp)
    sw      $s0, 0($sp)

    # Get address of tail
    jal coordinates_to_address
    la      $t0, snake_tail
    sw      $v0, 0($t0)		

    # Get address of head
    move    $a0, $a2
    move    $a1, $a3
    jal     coordinates_to_address

    la      $t1, snake_head
    sw      $v0, 0($t1)		
    # Restore saved registers and return
    lw      $s0, 0($sp)
    lw      $ra, 4($sp)      
    addiu   $sp, $sp, 8    
    jr      $ra

# Increment snake length by adding a point
# This will update the snake_size in memory
add_point:
    la      $t0, snake_size    # Load the address of snake_size
    lw      $t1, 0($t0)        # Load the current snake size
    addi    $t1, $t1, 1        # Increment the size
    sw      $t1, 0($t0)        # Store the updated size back in memory

    jr $ra
    
move_up:
    # Save state
    addiu   $sp, $sp, -8
    sw      $ra, 4($sp)
    sw      $s0, 0($sp)

    # Load current head Y coordinate
    lw      $s0, snake_head     # Load head address

    # Move up (decrease the address)
    addiu   $t0, $s0, -0x00000100

    # Check for wraparound at the top
    bge     $t0, $zero, move_up_cont   # If Y >= 0, continue
    # Implement colission = lost

move_up_cont:
    # Store the new head Y position
    li	    $t1, WHITE
    sw      $t1, 0($t0)

    # Restore state and return
    lw      $s0, 0($sp)
    lw      $ra, 4($sp)
    addiu   $sp, $sp, 8
    jr      $ra

# Move the snake down
move_down:
    addiu   $sp, $sp, -8
    sw      $ra, 4($sp)
    sw      $s0, 0($sp)

    # Load current head Y coordinate
    lw      $s0, snake_head

    # Move down (increase Y)
    addiu   $t0, $s0, 0x00000100

    # Check for wraparound at the bottom
    li      $t1, 64
    blt     $t0, $t1, move_down_cont   # If Y < 64, continue
    # Implement colission = lost

move_down_cont:
    # Store the new head Y position
    li	    $t1, WHITE
    sw      $t1, 0($t0)

    # Restore state and return
    la      $s0, 0($sp)
    lw      $ra, 4($sp)
    addiu   $sp, $sp, 8
    jr      $ra

# Move the snake left
move_left:
    addiu   $sp, $sp, -8
    sw      $ra, 4($sp)
    sw      $s0, 0($sp)

    # Load current head X coordinate
    lw      $s0, snake_head

    # Move left (decrease X)
    addiu   $t0, $s0, -4

    # Check for wraparound on the left
    bge     $t0, $zero, move_left_cont   # If X >= 0, continue
    # Implement colission = lost

move_left_cont:
    # Store the new head X position
    li	    $t1, WHITE
    sw      $t1, 0($t0)

    # Restore state and return
    lw      $s0, 0($sp)
    lw      $ra, 4($sp)
    addiu   $sp, $sp, 8
    jr      $ra

# Move the snake right
move_right:
    addiu   $sp, $sp, -8
    sw      $ra, 4($sp)
    sw      $s0, 0($sp)

    # Load current head X coordinate
    lw      $s0, snake_head

    # Move right (increase X)
    addiu   $t0, $s0, 4

    # Check for wraparound on the right
    li      $t1, 64
    blt     $t0, $t1, move_right_cont   # If X < 64, continue
    # Implement colission = lost

move_right_cont:
    # Store the new head X position
    li	    $t1, WHITE
    sw      $t1, 0($t0)

    # Restore state and return
    lw      $s0, 0($sp)
    lw      $ra, 4($sp)
    addiu   $sp, $sp, 8
    jr      $ra
