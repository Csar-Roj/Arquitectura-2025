.data
	SensorControl: .word 2 # Si 2, se inicializa
	SensorEstado: .word -1 # 0 = No hay lectura | 1 = Listo para leer, lectura en SensorDatos | -1 = Debe reinicializarse
	SensorDatos: .word 24 # Contiene los datos leidos
	
	message1: .asciiz "Temperatura leida: "
	message2: .asciiz " | Codigo leido: "
.text
	
	mainLoop:
	# Si se escribe 2 en SensorControl, inicializar el Sensor
	lw $s0, SensorControl
	li $s1, 2
	
	bne $s0, $s1, noListo
	jal InicializarSensor
	
	# Si el sensor esta listo para leer, leer la temperatura
	lw $s0, SensorEstado
	li $s1, 1
	bne $s0, $s1, noListo
	jal LeerTemperatura
	# Escribir la temperatura y el codigo por pantalla
	move $t0, $v0
	move $t1, $v1
	
	li $t2, -1
	
	# Ya se leyo la temperatura (SensorEstado = 0)
	sw $zero, SensorEstado
	
	# Si hubo un error (codigo -1), SensorEstado debe reinicializarse
	bne $t1, $t2, noError
	sw $t2, SensorEstado
	noError:
	
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
	
	InicializarSensor:
		# Inicializar SensorEstado
		li $t0, 1
		sw $t0, SensorEstado
		# Resetear SensorControl
		sw $zero, SensorControl
		jr $ra
		
	LeerTemperatura:
		# Leer la temperatura
		lw $v0, SensorDatos 
		# Estaba listo el sensor para leer?
		lw $t0, SensorEstado
		li $t1, 1
		bne $t0, $t1, LeerTempError
		# Retornar el codigo (0 si exitoso)
		li $v1, 0
		jr $ra
		LeerTempError:
		# Retornar el codigo (-1 si fallo)
		li $v1, -1
		jr $ra
		
		
		
		
		
		
