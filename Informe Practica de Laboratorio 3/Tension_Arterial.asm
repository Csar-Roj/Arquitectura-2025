.data
	TensionControl: .word 1 # Si 1, inicia una medicion
	TensionEstado: .word 0 # 0 = Leyendo | 1 = Lectura terminada
	TensionSistol: .word 0 # Contiene los datos leidos
	TensionDiastol: .word 0 # Contiene los datos leidos
	
	message1: .asciiz "Tension Sistol: "
	message2: .asciiz " | Tension Diastol: "
	
	inputMessage1: .asciiz "Ingrese la Tension Sistol: "
	inputMessage2: .asciiz "Ingrese la Tension Diastol: "
.text
	mainLoop:
	# Si se escribe 1 en TensionControl, iniciar una medicion
	lw $s0, TensionControl
	li $s1, 1
	
	bne $s0, $s1, noListo
	
	jal controlador_tension
	
	# Escribir las tensiones por pantalla
	move $t0, $v0
	move $t1, $v1
	
	li $v0, 4
	la $a0, message1
	syscall
	
	li $v0, 1
	move $a0, $t0
	syscall
	
	li $v0, 4
	la $a0, message2
	syscall
	
	li $v0, 1
	move $a0, $t1
	syscall
	
	noListo:
	j mainLoop
	
	
	controlador_tension:
		# Resetear TensionControl
		sw $zero, TensionControl
		# Iniciar la medicion
		loopTension:
			lw $t0, TensionEstado
			li $t1, 1
			beq $t0, $t1, finishLoopTension
		
			# Leer Tension Sistol
			li $v0, 4
			la $a0, inputMessage1
			syscall
		
			li $v0, 5
			syscall
			sw $v0, TensionSistol
			# Leer Tension Diastol
			li $v0, 4
			la $a0, inputMessage2
			syscall
		
			li $v0, 5
			syscall
			sw $v0, TensionDiastol
		
			# Lectura finalizada
			li $t0, 1
			sw $t0, TensionEstado
			j loopTension
		
		finishLoopTension:
		# Retornar las tensiones en $v0 y $v1
		lw $v0, TensionSistol
		lw $v1, TensionDiastol
		
		jr $ra
		
		
		
		
		
		
		
		
		
