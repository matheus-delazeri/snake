#---------------------------------------------------------------#
# 	Display Configuration					#
#---------------------------------------------------------------#
#	Unit Width in pixels: 8					#
#	Unit Height in Pixels: 8				#
#	Display Width in Pixels: 512				#
#	Display Height in Piexels: 512  			#
#---------------------------------------------------------------#

.eqv INITIAL_SIZE 5
.eqv MAX_SIZE 4096  #  Total units: (512/8) * (512/8) = 64 x 64 = 4096 pixels

.data

snake_size: .word 0
snake_tail: .word 0x00000000
snake_head: .word 0x00000000


#---------------------------------------------------------------#
# 	Variable Configuration					#
#---------------------------------------------------------------#
#	$s0 = Address of snake's tail                           #
#	$s1 = Address of snake's head				#
#	$s2 = Current points (snake size)	                #
#---------------------------------------------------------------#	
	
.text
.globl main


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

main:
	addiu   $sp, $sp, -4       
        sw      $ra, 0($sp)  
	
	jal screen_init2
	
	
	lw $t0, screen_background_color
	la $s0, snake_tail
	sw $t0, 0($s0)
	la $s1, snake_head
	sw $t0, 0($s1)
	
	la $s2, snake_size
	li $t2, INITIAL_SIZE
	sw $t2, 0($s2)
	
	jal paint_snake

	
	lw $t3, 0($s1)
	li $t5, GRAY
	sw $t5, 0($t3)
	
	lw      $ra, 0($sp)      
        addiu   $sp, $sp, 4      
        jr	$ra 
	
#
# Paint the starting snake on the screen
# FIXME: bad implementation
#
# $a0 = Snake size
#
paint_snake:
	addiu   $sp, $sp, -4       
        sw      $ra, 0($sp)        

	li $t0, 10 # Tail X
	li $t1, 10 # Tail Y
	lw $t2, 0($s2) # Current size
	add $t3, $t0, $t2 # Head X + 1
	addiu $t3, $t3, -1 # Head X
	
        move $a0, $t0 # Tail X
	move $a1, $t1 # Tail Y
	move $a3, $t3 # Head X
	move $a2, $t1 # Head Y
	
	jal update_extremity_pos
	
	li $t0, 10 # Tail X
	li $t1, 10 # Tail Y
	lw $t2, 0($s2) # Current size
	add $t3, $t0, $t2 # Head X + 1
	addiu $t3, $t3, -1 # Head X
	
	move $a0, $t0 # Tail X
	move $a1, $t1 # Tail Y
	move $a3, $t3 # Head X
	move $a2, $t1 # Head Y
	jal draw_line
		
	lw      $ra, 0($sp)      
        addiu   $sp, $sp, 4      
        jr	$ra

#
# Update the tail and head position of the snake
#
# $a0: Tail X  
# $a1: Tail Y      
# $a2: Head X       
# $a3: Head Y 
#
update_extremity_pos:
        addiu   $sp, $sp, -4       
        sw      $ra, 0($sp)  
	
	# Get address of tail
	jal coordinates_to_address
	sw $v0, 0($s0)
	
	# Get address of heac
	move $a0, $a2
	move $a1, $a3
	jal coordinates_to_address
	sw $v0, 0($s1)

        
        lw      $ra, 0($sp)      
        addiu   $sp, $sp, 4    
        jr	$ra

add_point:
	lw $t0, 0($s2)
	addi $t0, $t0, 1
	sw $t0, 0($s2)	
	
	jr $ra