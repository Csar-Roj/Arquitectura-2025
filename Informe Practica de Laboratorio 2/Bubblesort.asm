.data
	array: .space 400 # Array[100]
	message1: .asciiz "Ingrese la longitud del arreglo \n"
	message2: .asciiz "Ingrese los elementos del arreglo \n"
	separator: .asciiz "|"
	message3: .asciiz "Arreglo ingresado \n"
	message4: .asciiz "Arreglo ordenado con Bubblesort \n"
	newLine: .asciiz "\n"
.text
	# Pedirle al usuario la longitud del arreglo
	la $a0, message1
	li $v0, 4
	syscall
	li $v0, 5
	syscall
	
	# Guardarla en $s0
	addi $s0, $v0, 0
	
	# Pedirle al usuario que llene el arreglo
	la $a0, message2
	li $v0, 4
	syscall
	
	# Funcion para llenar el arreglo
	la $a0, array # Pasar direccion del arreglo por argumento
	addi $a1, $s0, 0 # Pasar tamaño del arreglo por argumento
	jal inputArray
	
	# Mostrarle el arreglo al usuario por pantalla
	la $a0, array # Pasar direccion del arreglo por argumento
	addi $a1, $s0, 0 # Pasar tamaño del arreglo por argumento
	jal printArray
	
	# Imprimir mensaje
	la $a0, message3
	li $v0, 4
	syscall
	
	# Ordenar arreglo usando bubblesort
	la $a0, array # Pasar direccion del arreglo por argumento
	addi $a1, $s0, 0 # Pasar tamaño del arreglo por argumento
	jal bubblesort
	
	# Imprimir mensaje
	la $a0, message4
	li $v0, 4
	syscall
	
	# Cerrar programa
	li $v0, 10
	syscall
	

inputArray:
	addi $sp, $sp, -8
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	
	li $s0, 0
	
	inputLoop:
		bge $s0, $a1, finishInput # while ($t1 < $t2)
		addi $s0, $s0, 1
		# Entrada
		li $v0, 5
		syscall
		# Guardar entrada en $s1
		addi $s1, $v0, 0
		# Guardar $s1 en el arreglo
		sw $s1, 0($a0)
		# Aumentar la direccion del arreglo
		addi $a0, $a0, 4
		# Repetir bucle
		j inputLoop
	finishInput:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	addi $sp, $sp, 8
	jr $ra
	
printArray:
	addi $sp, $sp, -16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $a0, 12($sp)
			 # Guardar direccion del arreglo en $s2
	addi $s2, $a0, 0 # Ya que usaremos el registro $a0 para imprimir por pantalla
	
	# Imprimir un separador por pantalla
	la $a0, separator
	li $v0, 4
	syscall
	
	li $s0, 0
	printLoop:
		bge $s0, $a1, finishPrint # while ($t1 < $t2)
		addi $s0, $s0, 1
		# Cargar elemento en $a0
		lw $a0, 0($s2)
		# Imprimirlo por pantalla
		li $v0, 1
		syscall
		# Aumentar la direccion del arreglo
		addi $s2, $s2, 4
		# Imprimir un separador por pantalla
		la $a0, separator
		li $v0, 4
		syscall
		j printLoop
	finishPrint:
	# Nueva linea
	la $a0, newLine
	li $v0, 4
	syscall
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $a0, 12($sp)
	addi $sp, $sp, 16
	jr $ra

bubblesort:
	addi $sp, $sp, -20
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $ra, 16($sp)
	
	li $t0, 0 # Contador
	addi $t1, $a1, -1 # Queremos terminar un elemento antes del ultimo
	
	loopBubblesort:
		bge $t0, $t1, finishBubblesort # Salida del bucle
		
		addi $s1, $a0, 0 # Cargar direccion del arreglo en $s1
		li $t2, 0 # Contador 2
		sub $t3, $t1, $t0 # No hace falta comparar con elementos ya ordenados
		loopSwapBubblesort:
			bge $t2, $t3, finishSwapBubblesort
			addi $t2, $t2, 1
			# Comparar el elemento actual con el siguiente
			lw $s2, 0($s1)
			lw $s3, 4($s1)
			
			slt $t4, $s2, $s3
			li $t5, 1
			# Intercambiar posiciones si es mayor
			beq $t4, $t5, noSwapBubblesort
			addi $t4, $s2, 0
			sw $s3, 0($s1)
			sw $t4, 4($s1)
			# Imprimir el arreglo por pantalla
			jal printArray
			noSwapBubblesort:
			addi $s1, $s1, 4
			j loopSwapBubblesort
		finishSwapBubblesort:
		addi $t0, $t0, 1
		j loopBubblesort
	finishBubblesort:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20
	jr $ra
