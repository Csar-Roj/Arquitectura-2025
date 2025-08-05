.data
	semaforoIdle: .asciiz "Semáforo en verde, esperando pulsador\n"
	semaforoGreen: .asciiz "Pulsador activado: en 20 segundos, el semáforo cambiará a amarillo\n"
	semaforoYellow: .asciiz "Semáforo en amarillo, en 10 segundos, semáforo en rojo\n"
	semaforoRed: .asciiz "Semáforo en rojo, en 30 segundos, semáforo en verde\n"
.text
	lui $s7, 0xFFFF # Direccion de lectura de caracter
	j main

receiveInput:
	li $v0, 0 # Retornar 0 si no se ha leido 's'
	lw $t0, 0($s7) # Revisar si se leyo algo
	beq $t0, $zero, doneInput
	lw $t0, 4($s7) # Si se escribio algo, revisar si es 's'
	li $t1, 's'
	bne $t0, $t1, doneInput
	li $v0, 1 # Si es 's', retornar 1
	doneInput:
	jr $ra
	
waitSeconds: # $a0 = tiempo en segundos a esperar
	# Convertir segundos a milisegundos
	mul $t0, $a0, 1000
	# Recibir tiempo actual
	li $v0, 30
	syscall
	add $t0, $t0, $a0
	# Esperar hasta que ocurran X segundos 
	waitLoop:
	li $v0, 30
	syscall
	bge $a0, $t0, endWait
	j waitLoop
	endWait:
	jr $ra

main:
	# Escribir por pantalla
	li $v0, 4
	la $a0, semaforoIdle
	syscall
	waitForInput:
	# Esperar a que el usuario presione 's'
	jal receiveInput
	move $s0, $v0
	
	li $t0, 1
	beq $s0, $t0, startCycle
	j waitForInput
	
	startCycle:
	# Escribir por pantalla
	li $v0, 4
	la $a0, semaforoGreen
	syscall
	# Esperar 20 segundos
	li $a0, 20
	jal waitSeconds
	# Escribir por pantalla
	li $v0, 4
	la $a0, semaforoYellow
	syscall
	# Esperar 10 segundos
	li $a0, 10
	jal waitSeconds
	# Escribir por pantalla
	li $v0, 4
	la $a0, semaforoRed
	syscall
	# Esperar 30 segundos
	li $a0, 30
	jal waitSeconds
	# Volver al inicio
	j main