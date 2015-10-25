#        addiu   $sp, $sp, -40   # create a stack frame
# 
#        sw      $s0,  0($sp)
#        sw      $s1,  4($sp)
#        sw      $s2,  8($sp)
#        sw      $s3, 12($sp)
#        sw      $s4, 16($sp)
#        sw      $s5, 20($sp)
#        sw      $s6, 24($sp)
#        sw      $s7, 28($sp)
#        sw      $ra, 32($sp)
#        sw      $a3, 36($sp)
#		INSERT JUMP CALL
#        lw      $s0,  0($sp)
#        lw      $s1,  4($sp)
#        lw      $s2,  8($sp)
#        lw      $s3, 12($sp)
#        lw      $s4, 16($sp)
#        lw      $s5, 20($sp)
#        lw      $s6, 24($sp)
#        lw      $s7, 28($sp)
#        lw      $ra, 32($sp)
#        lw      $a3, 36($sp)
#        addiu   $sp, $sp, 40   # create a stack frame


.data

RandNum:	.word 1
Seed:		.word 0
Max:		.word 0
Sequence:	.word 1
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
Colors:		
		.word 0x000000 
		.word 0x00ff00 #	1
		.word 0xff0000 #	2
		.word 0x0000ff #	3
		.word 0xffff00 #	4
		.word 0xffffff 
	
		
base:		
		.word 0x10040000
	
Clear:		.asciiz "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
YourTurn: 	.asciiz "Now its Your turn!\nEnter the sequence:\t"
	

.text

###########################################################################################
#	
#	ProcNames:
#		#	Randomize
#		#	AddToSequence
#		#	IncreaseMax
#		#	DisplaySequence
#		#	ClearScreen
#		#	UserInput
#		#	CompareSeq
#
###########################################################################################

main:
	add  $a0,$zero,1
	add  $a1,$zero,1
	la   $a2,RandNum
	jal DrawDot

#	reset all to zero
	j mStart
	
RanNumb:
	lw  $t5,Max
	add $t5,$t5,1
	sw  $t5,Max
mStart:
	la $a0,0
	la $a1,Seed
	la $a2,RandNum
	
	jal Randomize

	#	Test to make sure random number is saved correctly
#	lw $a0,RandNum
#	li $v0,1
#	syscall
	
	#	Add # to Sequence
	#	Display Sequence
	#	Clear Screen/bitmap
	la	$a0,RandNum
	la	$a1,Sequence
	
	jal SeedNum
	
	la	$a0,RandNum
	la	$a1,Sequence
	la	$a2,Max
	jal AddToSequence
	
	#	Test to make sure sequence shows correctly.
#	la $a0,Sequence
#	lw $a0,0($a0)
#	li $v0,1
#	syscall
	
	


#	read user input for sequence
#	compare each entry in real time
	
	la	$a0,Max
	la	$a1,Sequence
	la	$a2,Clear
	
	jal DisplaySequence
	
	la	$a2,Max
	la	$a1,Sequence
	
	jal UserInput

#	if sequence is max and user input all 5 then display win.

	la	$a0,Clear
	li	$v0,4
	syscall

	lw $t5, Max

	bne $t5,4,RanNumb
	

###########################################################################################
#	
#	This Generates the values stores seed based on system time
#	input:	a0 for initial seed
#	input:	a1 used to hold inital seed
#	
###########################################################################################				
SeedNum:

	li $v0,30
	syscall
	move $a1,$a0
	
	li $a0,0
	li $v0,40
	syscall
	
	sw $a0,Seed
	
	jr $ra

###########################################################################################
#	
#	This Generates the values stores the random num in a0 then to RandNum.
#	input:	a0 for initial seed
#	input:	a2 place to store randNum
#	
###########################################################################################
Randomize:
	
	addiu $a1,$zero,4
	li $v0,42
	syscall
#	lw $t1,0($a0)
	addu $a0,$a0,1
	sw $a0,0($a2)
	
	jr $ra

	
	
###########################################################################################
#	
#	Input:	a0	Number to add to sequence.
#	Input:	a1	Sequence destination
#	Input:	a2	Max	
#	
###########################################################################################
AddToSequence:
        
        #	loads the current max then multiplies this by 4 so that
        #	you can move the sequence to the correct place to save the
        #	new number coming in.
        lw 	$t0, 0($a2)
        mul 	$t0,$t0,4
        addu  	$a1,$a1,$t0
        
        #	load the actual number, store the number the the new sequence
        #	destination. Then return to the callee.
        lw 	$t1,($a0)
        sw	$t1,0($a1)
        
	
	jr $ra



###########################################################################################
#	
#	adds the max value of Sequence.
#	I don't think this needs much explaining.
#	
###########################################################################################
IncreaseMax:

	lw 	$t1,($a0)
	bne	$t1,4,notMax
	addiu 	$t1,$t1,1
notMax:	sw	$t1,($a0)
	
	jr $ra


###########################################################################################
#	
#	Input:	$a0 =	Max
#	Input:	$a1 =	Sequence
#	Input:	$a2 =	Clear
#	
#
#	t0 =	the sequence mover (moves through the array of words)
#	t1 =	holds the max value	
#	t3 =	this is the count
#
###########################################################################################

DisplaySequence:	
	addiu   $sp, $sp, -4   # create a stack frame
       	sw	$ra,  0($sp)
	
	#	set seqMover to zero
	addu 	$t0,$zero,$zero
	
	lw	$t1, 0($a0)
	
	#	set count to zero
	add	$t3,$zero,$zero
	
	#	This is to skip the initial loop stage since I don't want
	#	to get the the second item in the list.
	j	DispStart
	
	
DispLoop:
	#	add to the count.
	add	$t3,$t3,1
	#	add 4 seqMover
	add	$t0,$zero,4
	#	Then move the array over by the number of seqMover bytes
	add	$a1,$a1,$t0
	#	Just to keep the max value.
	add	$t1,$t1,$zero
DispStart:
	
	#	Display the number in the current SeqMover
	lw 	$a0,0($a1) 	
	li 	$v0,1
	syscall
	
	#	Pause the display
	#
	#	This should be a sub routine
	#	
	li	$a0,500
	li 	$v0,32
	syscall
	
	# 	as long as the max isnt reached continue printing the
	#	numbers in the sequence.
	bne 	$t3,$t1,DispLoop
        
        #	Clear the screen
        #
        #	This will move above when the bit mapp is added in so that you
        # 	can clear the display between color displays
        #	
        la	$a0,($a2)
	jal ClearScreen

       lw	$ra,  0($sp)
       addiu   	$sp, $sp, 4
        
        jr $ra


###########################################################################################
#	
#	Moves the text/clears bit map so that it can not be seen.
#	
###########################################################################################
ClearScreen:
	
	li 	$v0,4
	syscall
	
	jr $ra

###########################################################################################
#	
#	input:	$a2 = 	Max
#	input:	$a1 =	Sequence
#	
###########################################################################################
UserInput:
	la	$a0,YourTurn
	li	$v0,4
	syscall
	
	# 	Set Max value to $t2
	lw  $t2,0($a2)
	and $t3,$zero,$zero
	
	j FirstNum

	#	Sets max t2 every time, adds to t3 (count) and moves sequence ahead.
NumEnter:
	add $t2,$t2,$zero
	add $t3,$t3,1
	add $a1,$a1,4
	
	#	begin of for loop to go through sequence of entries.
FirstNum:
	li	$v0,12
	syscall
	
	sub $t1,$v0,48
	
	# 	load current sequence to $t0.
	lw $t0, 0($a1)
	
	# 	Check if equal, if they are continue to loop
	#
	#	This should be changed to have a flaged value.
	bne $t0,$t1,Lose
	blt $t3,$t2,NumEnter
	beq $t3,4,Win
	
	jr $ra

.data

YouLose: .asciiz "\nYou Lost :(\n"

.text
Lose:	
	la	$a0,YouLose
	li	$v0,4
	syscall
	
	li	$v0,10
	syscall
	
	
.data

YouWin: .asciiz "\nYou Win!\n"

.text
Win:	
	la	$a0,YouWin
	li	$v0,4
	syscall

	li $v0,10
	syscall
###########################################################################################
#	
#	Draw dot
#	input:	$a0 -	x coordinate
#	input:	$a1 -	y coordinate
#	input:	$a2 -	color number
#	
###########################################################################################
calcAddress:

	la	$t1,base	
	mul	$a0,$a0,4 
	mul	$a1,$a1,4 
	mul	$a1,$a1,32 
	addu	$v0,$t1,$a0
	addu	$v0,$v0,$a1
	
jr $ra
	
	
###########################################################################################
#	
#	Draw dot
#	input:	$a0 -	x coordinate
#	input:	$a1 -	y coordinate
#	input:	$a2 -	color number
#	
###########################################################################################
getColor:

	la	$t0,Colors
	sll	$t1,$a2,2
	addu	$t1,$t1,$t0
	add	$v1,$t1,$zero
	
jr $ra
	
	
	
	
###########################################################################################
#	
#	Draw dot
#	input:	$a0 -	x coordinate
#	input:	$a1 -	y coordinate
#	input:	$a2 -	color number
#	
###########################################################################################
DrawDot:
	#	creates stack
	addiu 	$sp,$sp,-8
	sw	$ra,4($sp)
	sw	$a2,0($sp)
	
	#	creates calculation to memeory 
	#	address where the dot goes.
	jal 	calcAddress
	
	lw	$a2,0($sp)
	sw	$v0,0($sp)
	
	#	gets the color  from $a2 value
	jal	getColor
	
	lw	$v0,0($sp)
	sw	$v1,0($v0)
	#	Destroys stack
	lw	$ra,4($sp)
	addiu 	$sp,$sp,8
	
	#	fuck you don't jump and return.
	li $v0,10
	syscall
jr $ra
				
###########################################################################################
#	
#	You use this to pause breifly.
#	
###########################################################################################	
Pause:
	addi	$sp,$sp,-4
	sw	$ra,0($sp)
	
	#	This is the thread pause syscall.
	li	$a0,500
	li 	$v0,32
	syscall
	
	lw	$ra,0($sp)
	addi	$sp,$sp,4
	jr $ra
