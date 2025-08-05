.data
	buffer: .space 3 # Buffer Circular de 3 caracteres
.text
la $s0, buffer # Direccion del buffer
li $s1, 0 # Codigo de caracter
li $s2, 0 # Posicion del buffer
lui $s3, 0xFFFF # Direccion de lectura de caracter
j main

printAndEraseBuffer: # $a0 = buffer adress
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $a0, 4($sp)
	sw $v0, 8($sp)
	
	move $s0, $a0
	li $t0, 0
	li $t1, 3 # Tamaño del buffer
	li $t2, 0
	printLoop:
		beq $t0, $t1, exitPrintLoop
		# No imprimir si es NULL
		lw $a0, 0($s0)
		beq $a0, $zero, skipPrint
		# Imprimir por pantalla y vaciar si no es NULL
		li $v0, 11
		syscall
		sw $zero, 0($s0)
		li $t2, 1
		skipPrint:
		addi $s0, $s0, 4
		addi $t0, $t0, 1
		j printLoop
	exitPrintLoop:
	# Imprimir nueva linea si se escribio algo
	beq $t2, $zero, noNewLine
	li $a0, 10
	li $v0, 11
	syscall
	noNewLine:
	lw $s0, 0($sp)
	lw $a0, 4($sp)
	lw $v0, 8($sp)
	addi $sp, $sp, 12
	jr $ra
	
storeToBuffer: # $s0 = adress, $s1 = char, $s2 = position
	sw $s1, 0($s0)
	# Si estamos en la ultima posicion, volver a la primera
	li $t0, 2
	bne $s2, $t0, noReset
	li $s2, 0
	addi $s0, $s0, -8
	j doneStoring
	noReset:
	# Si no estamos en la ultima posicion, moverse una posicion hacia arriba
	addi $s2, $s2, 1
	addi $s0, $s0, 4
	doneStoring:
	jr $ra

receiveInput:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	lw $t0, 0($s3) # Revisar si se escribio algo
	beq $t0, $zero, doneInput
	lw $s1, 4($s3) # Si se escribio algo, guardarlo en el buffer
	jal storeToBuffer
	doneInput:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
main:
	# Recibir tiempo actual
	li $v0, 30
	syscall
	# Guardarlo en $s5
	move $s5, $a0
	# Bucle de temporizador
	inputLoop: 
	jal receiveInput
	
	li $v0, 30
	syscall
	addi $t0, $s5, 20000
	bge $a0, $t0, exitInputLoop 
	
	j inputLoop
	exitInputLoop:
	# Escribir buffer por pantalla
	la $a0, buffer
	jal printAndEraseBuffer
	j main
