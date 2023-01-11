###########################################################
#		Michael Strand
#		4/8/21

###########################################################
#		Program Description
#	This program is modeling an oredering system where a customer will 
#	be asked for a number greater than 0 to createa an array to hold
#	double percision prices greater than 0. The program will then 
#	calculate shipping cost and tax and print the sum, shipping cost,
#	tax, and total of all three before the program ends.

###########################################################
#		Register Usage
#	$t0 base address
#	$t1	array length
#	$t2	
#	$t3
#	$t4
#	$t5
#	$t6
#	$t7
#	$t8
#	$t9

#	$f0	array sum
#	$f2	shipping
#	$f4	tax
###########################################################
		.data

###########################################################
		.text
main:
	#create_array stack set up
	addi $sp, $sp, -12
	sw $ra, 8($sp)

	jal create_array

	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $ra, 8($sp)

	#print_array stack setup
	addi $sp, $sp, -20
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $ra, 16($sp)

	jal print_array

	lw $t0, 0($sp)
	lw $t1, 4($sp)
	l.d $f0, 8($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20

	#get_shipping stack setup
	addi $sp, $sp, -20
	s.d $f0, 0($sp)
	sw $ra, 16($sp)

	jal get_shipping

	l.d $f0, 0($sp)
	l.d $f2, 8($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20

	#calculate_tax stack setup
	addi $sp, $sp, -28
	s.d $f0, 0($sp)
	s.d $f2, 8($sp)

	jal calculate_tax

	l.d $f0, 0($sp)
	l.d $f2, 8($sp)
	l.d $f4, 16($sp)
	lw $ra, 24($sp)
	addi $sp, $sp, 28

	#calculate_print_result stack setup
	addi $sp, $sp, -28
	s.d $f0, 0($sp)
	s.d $f2, 8($sp)
	s.d $f4, 16($sp)
	lw, $ra, 24($sp)

	jal calculate_print_result

	li $v0, 10		#End Program
	syscall
###########################################################

###########################################################
#		create_array
#	
#	Takes in a number greater than 0, then calls allocate_array
#	with the valid length. Using the length and returned base address
#	calls read_array to prompt user for values. Then sends back 
#	array base address and length to main.

###########################################################
#		Arguments In and Out of subprogram
#
#	$a0
#	$a1
#	$a2
#	$a3
#	$v0
#	$v1
#	$sp+0 Base address(OUT)
#	$sp+4 Array length(OUT)
#	$sp+8
#	$sp+12 
###########################################################
#		Register Usage
#	$t0 base address
#	$t1 array length
#	$t2
#	$t3
#	$t4
#	$t5
#	$t6
#	$t7
#	$t8
#	$t9
###########################################################
		.data
array_length_prompt:	.asciiz	"\nPlease enter the number of items. (must be greater than 0): "
invalid_length_prompt:  .asciiz	"\nInvalid number of items."
###########################################################
		.text
create_array:
	prompt:
		li $v0, 4						#starting prompt for array length
		la $a0, array_length_prompt
		syscall

		li $v0, 5						#reading user input
		syscall

		input_validation:
			blez $v0, invalid_length	#validating input > 0

			move $t1, $v0				#$t1 = input
			b input_end

		invalid_length:
			li $v0, 4					#invalid input prompt
			la $a0, invalid_length_prompt
			syscall

			b prompt

	input_end:
	#allocate_array stack setup
	addi $sp, $sp, -12
	sw $t1, 0($sp)
	sw $ra, 8($sp)

	jal allocate_array

	lw $t0, 4($sp)
	lw $t1, 0($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12

	#read_array stack setup
	addi $sp, $sp, -12
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $ra, 8($sp)

	jal read_array

	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12

	sw $t0, 0($sp)
	sw $t1, 4($sp)

	jr $ra	#return to calling location
###########################################################

###########################################################
#		allocate_array
#
#	Creates a dynamic array of double percision numbers using 
#	a given length greater than 0

###########################################################
#		Arguments In and Out of subprogram
#
#	$a0
#	$a1
#	$a2
#	$a3
#	$v0
#	$v1
#	$sp+0	array length(IN)
#	$sp+4	array base address(OUT)
#	$sp+8
#	$sp+12
###########################################################
#		Register Usage
#	$t0
#	$t1 array length
#	$t2
#	$t3
#	$t4
#	$t5
#	$t6
#	$t7
#	$t8
#	$t9
###########################################################
		.data
array:	.word	0
###########################################################
		.text
allocate_array:
	lw $t1, 0($sp)			#copy array length from stack to $t1

	li $v0, 9				#allocate dynamic array
	sll $a0, $t1, 3
	syscall

	la $t0, array			#store base address in variable array
	sw $v0, 0($t0)

	sw $v0, 4($sp)			#storing base address on stack

	jr $ra	#return to calling location
###########################################################

###########################################################
#		read_array
#
#	Reads in a series of double percision numbers greater than
#	0 and puts them into the array. discards any invalid input.

###########################################################
#		Arguments In and Out of subprogram
#
#	$a0
#	$a1
#	$a2
#	$a3
#	$v0
#	$v1
#	$sp+0	base address(IN)
#	$sp+4	array length(IN)
#	$sp+8
#	$sp+12
###########################################################
#		Register Usage
#	$t0 base address
#	$t1 array length/counter
#	$t2
#	$t3
#	$t4
#	$t5
#	$t6
#	$t7
#	$t8
#	$t9
###########################################################
		.data
price_input_prompt:	.asciiz	"\nPlease enter the price of your item. (must be greater than 0): "
invalid_price_prompt:	.asciiz	"\nInvalid price."
###########################################################
		.text
read_array:
	lw $t0, 0($sp)						#$t0 = base address
	lw $t1, 4($sp)						#$t1 = array length
	li.d $f2, 0.0						#$f2 = 0.0

	price_prompt:
		blez $t1, read_end

		li $v0, 4						#prompt to user for input
		la $a0, price_input_prompt
		syscall

		li $v0, 7						#read user input as double
		syscall

		c.le.d  $f0, $f2				#validating input
		bc1t invalid_price

		s.d $f0, 0($t0)					#storing double at index of array

		addi $t0, $t0, 8				#increment index by 8
		addi $t1,$t1,-1					#decrement count

		b price_prompt

		invalid_price:
			li $v0, 4					#invalid price prompt
			la $a0, invalid_price_prompt
			syscall

			b price_prompt

read_end:	

	jr $ra	#return to calling location
###########################################################

###########################################################
#		print_array
#
#	prints each value in the array to the console.

###########################################################
#		Arguments In and Out of subprogram
#
#	$a0
#	$a1
#	$a2
#	$a3
#	$v0
#	$v1
#	$sp+0	base address(IN)
#	$sp+4	array length(IN)
#	$sp+8	array sum(OUT)
#	$sp+12
###########################################################
#		Register Usage
#	$t0 base address
#	$t1	array length
#	$t2	
#	$t3
#	$t4
#	$t5
#	$t6
#	$t7
#	$t8
#	$t9
###########################################################
		.data
print_space:	.asciiz	" "
print_cart:		.asciiz	"\nCart: "
###########################################################
		.text
print_array:
	lw $t0, 0($sp)				#$t0 = base address
	lw $t1, 4($sp)				#$t1 = array length

	li $v0, 4					#print cart
		la $a0, print_cart
		syscall

	print_loop:
		blez $t1, print_end		#loop counter

		l.d $f12, 0($t0)		#$f12 = element at array index
		add.d $f14, $f14, $f12	#summing values

		li $v0, 3				#print double
		syscall

		li $v0, 4				#print space between values
		la $a0, print_space
		syscall

		addi $t0, $t0, 8		#increment index
		addi $t1, $t1, -1		#decrement counter

		b print_loop

print_end:
	s.d $f14, 8($sp)			#putting array sum on stack

	jr $ra	#return to calling location
###########################################################

###########################################################
#		get_shipping
#
#	Shipping cost is a flate rate of $5.95 unless cost of products
#	in greater than $100(returns 0.0)

###########################################################
#		Arguments In and Out of subprogram
#
#	$a0
#	$a1
#	$a2
#	$a3
#	$v0
#	$v1
#	$sp+0	total cost of items(IN)
#	$sp+4
#	$sp+8	shipping cost(5.95 or 0.0)(OUT)
#	$sp+12
###########################################################
#		Register Usage
#	$f0	total cost of items
#	$f2	5.95 shipping
#	$f4 0.0 shiping
#	$f6	100.0
#	$f8
#	$f10
#	$f12
###########################################################
		.data

###########################################################
		.text
get_shipping:
	l.d $f0, 0($sp)				#$f0 = total cost
	li.d $f2, 5.95				#$f2 = 5.95
	li.d $f4, 0.0				#$f4 = 0.0
	li.d $f6, 100.0				#$f6 = 100.0

	c.lt.d $f0, $f6				#if $f0<$f6
	bc1f free_shipping

	s.d $f2, 8($sp)				#5.95 shipping at offset 8

	b shipping_end

	free_shipping:
	s.d $f4, 8($sp)				#0.0 shipping at offset 8

	b shipping_end

shipping_end:
	jr $ra	#return to calling location
###########################################################

###########################################################
#		calculate_tax
#
#	Calculates the sales tax based on the sum of items and Shipping
#	Sales tax is 5% or 0.05.

###########################################################
#		Arguments In and Out of subprogram
#
#	$a0
#	$a1
#	$a2
#	$a3
#	$v0
#	$v1
#	$sp+0	total cost of items, double percision(IN)
#	$sp+4
#	$sp+8	shipping cost, double percision(5.95 or 0.0)(IN)
#	$sp+12
#	$sp+16	tax based on item cost+shipping(OUT)
###########################################################
#		Register Usage
#	$f0	total cost
#	$f2	shipping
#	$f4	tax
#	$f6
#	$f8
#	$f10
#	$f12
#	$f14 temp

#	$t8
#	$t9
###########################################################
		.data

###########################################################
		.text
calculate_tax:
	l.d $f0, 0($sp)			#$f0 = total cost
	l.d $f2, 8($sp)			#$f2 = shipping
	li.d $f4, 0.05			#$f4 = tax

	add.d $f14, $f0, $f2	#summing total and Shipping
	mul.d $f4, $f14, $f4	#getting tax based on total+shipping

	s.d $f4, 16($sp)

	jr $ra	#return to calling location
###########################################################

###########################################################
#		calculate_print_result
#
#	prints the total cost of items, shipping, tax and sum of 
#	all three

###########################################################
#		Arguments In and Out of subprogram
#
#	$a0
#	$a1
#	$a2
#	$a3
#	$v0
#	$v1
#	$sp+0	total cost of items, double percision(IN)
#	$sp+4
#	$sp+8	shipping cost, double percision(5.95 or 0.0)(IN)
#	$sp+12
#	$sp+16	tax based on item cost+shipping(IN)
###########################################################
#		Register Usage
#	$f0 total cost
#	$f2	shipping
#	$f4 tax
#	$f6	final total
#	$f8
#	$f10
#	$f12

#	$t7
#	$t8
#	$t9
###########################################################
		.data
cart_cost:	.asciiz	"\nCart Cost: $"
shipping_cost:	.asciiz	"\nShipping: $"
tax_cost:	.asciiz	"\nTax: $"
print_line:	.asciiz	"\n__________________________________"
total_cost:	.asciiz	"\nTotal Cost: $"
###########################################################
		.text
calculate_print_result:
	l.d $f0, 0($sp)
	l.d $f2, 8($sp)
	l.d $f4, 16($sp)

	li $v0, 4
	la $a0, cart_cost
	syscall

	li $v0, 3
	mov.d $f12, $f0
	syscall

	li $v0, 4
	la $a0, shipping_cost
	syscall

	li $v0, 3
	mov.d $f12, $f2
	syscall

	li $v0, 4
	la $a0, tax_cost
	syscall

	li $v0, 3
	mov.d $f12, $f4
	syscall

	li $v0, 4
	la $a0, print_line
	syscall

	add.d $f6, $f0, $f2
	add.d $f6, $f6, $f4

	li $v0, 4
	la $a0, total_cost
	syscall

	li $v0, 3
	mov.d $f12, $f6
	syscall

	jr $ra	#return to calling location
###########################################################


