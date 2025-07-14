.data
	array: .space 400 # Array[100]
	message1: .asciiz "Ingrese la longitud del arreglo \n"
	message2: .asciiz "Ingrese los elementos del arreglo \n"
	separator: .asciiz "|"
	message3: .asciiz "Arreglo ingresado \n"
	message4: .asciiz "Arreglo ordenado con Selection Sort \n"
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
	
	# Ordenar arreglo usando selection sort
	la $a0, array # Pasar direccion del arreglo por argumento
	addi $a1, $s0, 0 # Pasar tamaño del arreglo por argumento
	jal selectionsort
	
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

selectionsort:
	addi $sp, $sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $ra, 20($sp)
	
	li $t0, 0 # Contador
	
	addi $s1, $a0, 0 # $s1 sera la posicion inicial de cada recorrida
	
	addi $s4, $a1, 0 # $s4 sera el tamaño del arreglo, decreciendo con cada corrida
	
	loopSelectionsort:
		bge $t0, $a1, finishSelectionsort # Salida del bucle
		
		li $t1, 0 # Contador
		
		addi $s2, $s1, 0 # $s2 apuntara al numero mas pequeño encontrado en la recorrida
		addi $s3, $s1, 0 # $s3 recorrera el arreglo iniciando en $s1
		
		sub $s4, $a1, $t0 # $s4 es el tamaño del arreglo menos las veces recorrida (para evitar salirnos de este)
		
		swapSelectionsort:
			bge $t1, $s4, finishSwapSelectionsort
			
			# Comparar el contenido de $s2 y $s3
			lw $t2, 0($s2)
			lw $t3, 0($s3)

			# Si $t3 < $t2, mover $s2 a $s3
			slt $t4, $t3, $t2
			li $t5, 0
			beq $t4, $t5, notLessThanSelectionsort
				addi $s2, $s3, 0
			notLessThanSelectionsort:
			
			# Mover $s3 un paso hacia arriba
			addi $s3, $s3, 4
			# Aumentar el contador
			addi $t1, $t1, 1
			j swapSelectionsort
		finishSwapSelectionsort:
		
		# Intercambiar la posicion del elemento en $s2 con la del elemento en $s1
		lw $t1, 0($s1)
		lw $t2, 0($s2)
		sw $t2, 0($s1)
		sw $t1, 0($s2)
		
		# Mover $s1 un paso hacia arriba
		addi $s1, $s1, 4
		# Aumentar el contador
		addi $t0, $t0, 1
		
		# Imprimir el arreglo por pantalla
		jal printArray
		
		j loopSelectionsort
	finishSelectionsort:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $ra, 20($sp)
	addi $sp, $sp, 24
	jr $ra
