.data
RandNum:	.word 0
Seed:		.word 0
Max:		.word 0
Sequence:	.word 0
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

		.word 0x000000		# black 
		.word 0x00ffff		# blue + green
		.word 0xffff00		# green + red
		.word 0x0000ff		# blue  
		.word 0xff0000		# red 
		.word 0xffffff		# white
		.word 0x00ff00		# green

		
BoxVals: 
		.word 1  ,1  ,6 ,13
		.word 18 ,1  ,4 ,13
		.word 1  ,18 ,3 ,13
		.word 18 ,18 ,2 ,13
		.word 0  ,0  ,0 ,13
		
Dividors:
		.word 0,15,5,32
		.word 0,16,5,32
		.word 15,0,5,32
		.word 16,0,5,32
	
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
	jal	DrawDivs
	
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

#	read user input for sequence
#	compare each entry in real time
	
	la	$a0,Max
	la	$a1,Sequence
	
	jal DisplaySequence2
	
	la	$a2,Max
	la	$a1,Sequence
	
	jal UserInput

#	if sequence is max and user input all 5 then display win.

	lw $t5, Max

	bne $t5,4,RanNumb
	
	li $v0,10
	syscall
	

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
	j	DispStart1
	
	
DispLoop1:
	#	add to the count.
	add	$t3,$t3,1
	#	add 4 seqMover
	add	$t0,$zero,4
	#	Then move the array over by the number of seqMover bytes
	add	$a1,$a1,$t0
	#	Just to keep the max value.
	add	$t1,$t1,$zero
DispStart1:
	
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
	bne 	$t3,$t1,DispLoop1
        
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
	addiu   $sp, $sp, -40   # create a stack frame
        sw      $s0,  0($sp)
        sw      $s1,  4($sp)
        sw      $s2,  8($sp)
        sw      $s3, 12($sp)
        sw      $s4, 16($sp)
        sw	$a0, 20($sp)
	sw	$a1, 24($sp)
	sw	$a2, 28($sp)
	sw	$a3, 32($sp)
        sw      $ra, 36($sp)
	#	This is the base of the display
	la	$t1, 0x10040000
	mul	$a0,$a0,4 
	sll	$a1,$a1,7
	addu	$v0,$t1,$a0
	addu	$v0,$v0,$a1
	
	lw      $s0,  0($sp)
        lw      $s1,  4($sp)
        lw      $s2,  8($sp)
        lw      $s3, 12($sp)
        lw      $s4, 16($sp)
        lw	$a0, 20($sp)
	lw	$a1, 24($sp)
	lw	$a2, 28($sp)
	lw	$a3, 32($sp)
        lw      $ra, 36($sp)
        addiu   $sp, $sp, 40 
	
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
 	addiu   $sp, $sp, -40   # create a stack frame
        sw      $s0,  0($sp)
        sw      $s1,  4($sp)
        sw      $s2,  8($sp)
        sw      $s3, 12($sp)
        sw      $s4, 16($sp)
        sw	$a0, 20($sp)
	sw	$a1, 24($sp)
	sw	$a2, 28($sp)
	sw	$a3, 32($sp)
        sw      $ra, 36($sp)

	la	$t0,Colors
	move	$t2,$a2
	sll	$t2,$t2,2
	add	$a2,$t2,$t0
	lw	$v1,0($a2)
	and	$t2,$zero,$zero
	and	$t0,$zero,$zero
		
	lw      $s0,  0($sp)
        lw      $s1,  4($sp)
        lw      $s2,  8($sp)
        lw      $s3, 12($sp)
        lw      $s4, 16($sp)
        lw	$a0, 20($sp)
	lw	$a1, 24($sp)
	lw	$a2, 28($sp)
	lw	$a3, 32($sp)
        lw      $ra, 36($sp)
        addiu   $sp, $sp, 40 
	
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
        addiu   $sp, $sp, -40   # create a stack frame
        sw      $s0,  0($sp)
        sw      $s1,  4($sp)
        sw      $s2,  8($sp)
        sw      $s3, 12($sp)
        sw      $s4, 16($sp)
        sw	$a0, 20($sp)
	sw	$a1, 24($sp)
	sw	$a2, 28($sp)
	sw	$a3, 32($sp)
        sw      $ra, 36($sp)
	
	#	creates calculation to memeory 
	#	address where the dot goes.
	jal 	calcAddress
	
	lw	$a2,28($sp)
	sw	$v0,0($sp)
	
	#	gets the color  from $a2 value array
	jal	getColor
	
	lw	$v0,0($sp)
	sw	$v1,0($v0)
	#	Destroys stack
	lw      $s0,  0($sp)
        lw      $s1,  4($sp)
        lw      $s2,  8($sp)
        lw      $s3, 12($sp)
        lw      $s4, 16($sp)
        lw	$a0, 20($sp)
	lw	$a1, 24($sp)
	lw	$a2, 28($sp)
	lw	$a3, 32($sp)
        lw      $ra, 36($sp)
        addiu   $sp, $sp, 40 
	
jr $ra
				
###########################################################################################
#	
#	You use this to pause breifly.
#	
###########################################################################################	
Pause:
	
	#	This is the thread pause syscall.
	li	$a0,500
	li 	$v0,32
	syscall
	
jr $ra
	
###########################################################################################
#	
#	Draw Horizontal Line
#	input:	$a0  =	x cordinate
#	input:	$a1  =	y cordinate
#	input:	$a2  =	colorNum
#	input:	$a3  =	length of line
#	
###########################################################################################
HorzLine:
        addiu   $sp, $sp, -40   # create a stack frame
        sw      $s0,  0($sp)
        sw      $s1,  4($sp)
        sw      $s2,  8($sp)
        sw      $s3, 12($sp)
        sw      $s4, 16($sp)
        sw      $ra, 36($sp)
HorzLoop:

	sw	$a0, 20($sp)
	sw	$a1, 24($sp)
	sw	$a2, 28($sp)
	sw	$a3, 32($sp)

	jal	DrawDot
	
	lw	$a0, 20($sp)
	lw	$a1, 24($sp)
	lw	$a2, 28($sp)
	lw	$a3, 32($sp)
	
        addiu	$a0,$a0,1	#	move y cord over 1
        addiu	$a3,$a3,-1	#	- 1 from count
        bnez	$a3,HorzLoop	#	breaks when count = zero

	lw      $s0,  0($sp)
        lw      $s1,  4($sp)
        lw      $s2,  8($sp)
        lw      $s3, 12($sp)
        lw      $s4, 16($sp)
        lw	$a0, 20($sp)
	lw	$a1, 24($sp)
	lw	$a2, 28($sp)
	lw	$a3, 32($sp)
        lw      $ra, 36($sp)
        addiu   $sp, $sp, 40 
        
jr $ra
        
        
###########################################################################################
#	
#	Draw Vertical Line
#	input:	$a0  =	x cordinate
#	input:	$a1  =	y cordinate
#	input:	$a2  =	colorNum
#	input:	$a3  =	length of line
#	
###########################################################################################
VertLine:
	addiu   $sp, $sp, -40   # create a stack frame
        sw      $s0,  0($sp)
        sw      $s1,  4($sp)
        sw      $s2,  8($sp)
        sw      $s3, 12($sp)
        sw      $s4, 16($sp)
        sw	$a0, 20($sp)
	sw	$a1, 24($sp)
	sw	$a2, 28($sp)
        sw      $ra, 32($sp)
VertLoop:
	sw	$a0, 4($sp)
	sw	$a1, 8($sp)
	sw	$a2, 12($sp)
	sw	$a3, 16($sp)
	
	jal	DrawDot
		
	lw	$a0, 4($sp)
	lw	$a1, 8($sp)
	lw	$a2, 12($sp)
	lw	$a3, 16($sp)
	
        addiu	$a1,$a1,1	#	move y cord over 1
        addiu	$a3,$a3,-1	#	- 1 from count
        bnez	$a3,VertLoop	#	breaks when count = zero
        
        lw      $s0,  0($sp)
        lw      $s1,  4($sp)
        lw      $s2,  8($sp)
        lw      $s3, 12($sp)
        lw      $s4, 16($sp)
        lw	$a0, 20($sp)
	lw	$a1, 24($sp)
	lw	$a2, 28($sp)
        lw      $ra, 32($sp)
        addiu   $sp, $sp, 40 
        
jr $ra

###########################################################################################
#	
#	Drawing the box
#	input:	$a0  =	x cordinate
#	input:	$a1  =	y cordinate
#	input:	$a2  =	colorNum
#	input:	$a3  =	length of line
#	
###########################################################################################
DrawBox:
	addiu   $sp, $sp, -40   # create a stack frame
        sw      $s0,  0($sp)
        sw      $s1,  4($sp)
        sw      $s2,  8($sp)
        sw      $s3, 12($sp)
        sw      $s4, 16($sp)
        sw	$a0, 20($sp)
	sw	$a1, 24($sp)
	sw	$a2, 28($sp)
	sw	$a3, 32($sp)
        sw      $ra, 36($sp)
        
	add	$s3,$a3,$zero	#	Used to count
	
BoxLoop:
	sw	$a0, 20($sp)
	sw	$a1, 24($sp)
	sw	$a2, 28($sp)
	sw	$a3, 32($sp)
	
	jal 	HorzLine
	
	lw	$a0, 20($sp)
	lw	$a1, 24($sp)
	lw	$a2, 28($sp)
        lw	$a3, 32($sp)
        
	addiu	$a1,$a1,1
	addiu	$s3,$s3,-1
	bne	$s3,$0,BoxLoop
	
	lw      $s0,  0($sp)
        lw      $s1,  4($sp)
        lw      $s2,  8($sp)
        lw      $s3, 12($sp)
        lw      $s4, 16($sp)
        lw	$a0, 20($sp)
	lw	$a1, 24($sp)
	lw	$a2, 28($sp)
        lw	$a3, 32($sp)
        lw      $ra, 36($sp)
        addiu   $sp, $sp, 40 
	
jr $ra

###########################################################################################
#	
#	draws the dividors
#	
###########################################################################################
DrawDivs:
	addiu	$sp,$sp,-4
	sw	$ra,0($sp)
	
	la	$t0,Dividors
	lw	$a0,0($t0)
	lw	$a1,4($t0)
	lw	$a2,8($t0)
	lw	$a3,12($t0)
	jal 	HorzLine
	
	la	$t0,Dividors
	lw	$a0,16($t0)
	lw	$a1,20($t0)
	lw	$a2,24($t0)
	lw	$a3,28($t0)
	jal 	HorzLine
	
	la	$t0,Dividors
	lw	$a0,32($t0)
	lw	$a1,36($t0)
	lw	$a2,40($t0)
	lw	$a3,44($t0)
	jal 	VertLine
	
	la	$t0,Dividors
	lw	$a0,48($t0)
	lw	$a1,52($t0)
	lw	$a2,56($t0)
	lw	$a3,60($t0)
	jal 	VertLine
	
	lw	$ra,0($sp)
	addiu	$sp,$sp,4
	
jr $ra
	
	
###########################################################################################
#	
#	decides what to draw.
#	input:	$a0  =	sequence#
#	
###########################################################################################
GetBox:
 	addiu   $sp, $sp, -40   # create a stack frame
        sw      $s0,  0($sp)
        sw      $s1,  4($sp)
        sw      $s2,  8($sp)
        sw      $s3, 12($sp)
        sw      $s4, 16($sp)
        sw	$a0, 20($sp)
	sw	$a1, 24($sp)
	sw	$a2, 28($sp)
	sw	$a3, 32($sp)
        sw      $ra, 36($sp)

	lw	$s0,0($a0)
	la	$s1,BoxVals
	addi	$s0,$s0,-1
	mul	$s0,$s0,16
	addu	$s2,$s1,$s0
	
				#	This should grab all the needed values
				#	to draw the box from BoxVals	
	lw	$a0,0($s2)
	lw	$a1,4($s2)
	lw	$a2,8($s2)
	lw	$a3,12($s2)
				#	Store Values
	
	jal 	DrawBox
				#	Restore Values
		
	lw      $s0,  0($sp)
        lw      $s1,  4($sp)
        lw      $s2,  8($sp)
        lw      $s3, 12($sp)
        lw      $s4, 16($sp)
        lw	$a0, 20($sp)
	lw	$a1, 24($sp)
	lw	$a2, 28($sp)
	lw	$a2, 32($sp)
        lw      $ra, 36($sp)
        addiu   $sp, $sp, 40 
		
jr $ra


###########################################################################################
#	
#	clear the display
#	
###########################################################################################
ClearDisp:
        addiu   $sp, $sp, -40   # create a stack frame
        sw      $s0,  0($sp)
        sw      $s1,  4($sp)
        sw      $s2,  8($sp)
        sw      $s3, 12($sp)
        sw      $s4, 16($sp)
        sw      $ra, 32($sp)
        
				#	Takes the old box value, and over writes it
				#	With black.	
	la	$s0,0($a0)
	la	$s1,BoxVals
	addi	$s0,$s0,-1
	mul	$s0,$s0,16
	addu	$s2,$s1,$s0
	
	addi $a0,$zero,0	# 	get x value
	addi $a1,$zero,0
	addi $a2,$zero,0
	addi $a3,$zero,32
		# only need to save ra because a values are stored in other places 
	jal DrawBox
	
	jal DrawDivs
				# after done drawing box restore
        lw      $s0,  0($sp)
        lw      $s1,  4($sp)
        lw      $s2,  8($sp)
        lw      $s3, 12($sp)
        lw      $s4, 16($sp)
        lw      $ra, 32($sp)
        addiu   $sp, $sp, 40   # create a stack frame
	
	jr $ra 
	
TestArea:
	addiu	$sp,$sp,-8
	sw	$ra,0($sp)
	sw	$a0,4($sp)
	
	jal	GetBox
	
	lw	$ra,0($sp)
	sw	$ra,0($sp)
	
	jal	Pause
	
	lw 	$a0,4($sp)
	jal	ClearDisp
	
	li	$v0,10
	syscall
	
	lw	$ra,0($sp)
	addiu	$sp,$sp,8
	
jr $ra
###########################################################################################
#	
#	Input:	$a0 =	Max
#	Input:	$a1 =	Sequence
#	Input:	$a2 =	Clear
#	
#
#	s0 =	the sequence mover (moves through the array of words)
#	s1 =	holds the max value	
#	s3 =	this is the count
#
###########################################################################################
DisplaySequence2:	
	addiu	$sp,$sp,-16
        sw	$a0, 0($sp)
	sw	$a1, 4($sp)
	sw	$a2, 8($sp)
	sw	$a3, 12($sp)
        sw      $ra, 16($sp)

	
	#	set seqMover to zero
	addu 	$s3,$zero,$zero
	
	move	$s0,$a0
	la	$s1,0($a1)

	
	#	set count to zero
	add	$s4,$zero,$zero
	
	
	#	This is to skip the initial loop stage since I don't want
	#	to get the the second item in the list.
	j	DispStart
	
	
DispLoop:
	#	add to the count.
	add	$s4,$s4,1
	#	add 4 seqMover
	add	$s3,$s3,4
	#	Then move the array over by the number of seqMover bytes
	add	$s1,$s1,$s3
DispStart:
	
	
	move	$a0,$s1
	
	jal	GetBox
	
	jal	Pause
	
	jal	ClearDisp
	
	lw	$s0,Max
	
	bne 	$s4,$s0,DispLoop
        
        #	Clear the screen
        #
        #	This will move above when the bit mapp is added in so that you
        # 	can clear the display between color displays
        #	
	
        lw	$a0, 0($sp)
	lw	$a1, 4($sp)
	lw	$a2, 8($sp)
	lw	$a3, 12($sp)
        lw      $ra, 16($sp)
        addiu	$sp,$sp,16
        
        jr $ra
	

