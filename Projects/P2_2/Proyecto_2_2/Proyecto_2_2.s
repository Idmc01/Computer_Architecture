.macro imprime mensaje, len @Macro para imprimir un string
	push {r0-r12,lr}
	mov r0, #1
	ldr r1, =\mensaje
	ldr r2, =\len
	mov r7, #4
	swi 0
	pop {r0-r12,lr}
.endm



.section .data

entrada: .asciz "Seleccione una opción a realizar:\na. Suma\nb. Resta\nc. Multiplicación\nd. división\nSeleccione la opción que desea realizar:"
lenentrada= .-entrada
primero:    .asciz "Ingrese el primer digito: "
lenprimero = .-primero
segundo:    .asciz "Ingrese el segundo digito: "
lensegundo = .-segundo
suma:    .asciz "Suma en bases 16, 8, 10 y 2: \n"
lensuma = .-suma
diferencia:    .asciz "\nDiferencia en bases 16, 8, 10 y 2: \n "
lendiferencia = .-diferencia
division: .asciz "\nDivision en bases 16, 8, 10 y 2:\n"
lendivision = .-division
multiplicacion: .asciz "\nMultiplicación en bases 16, 8, 10 y 2:\n"
lenmultipĺicacion = .-multiplicacion
multiplicacion2: .asciz "\nMultiplicación en bases 16, 8 y 2:\n"
lenmultipĺicacion2 = .-multiplicacion2

b:    .asciz "Error, dato erroneo ingresado, ¿desea arreglar los datos de entrada?\na. Sí\nb. No\nSeleccióne una opción\n"
lenb = .-b

c:    .asciz "Error, se generó overflow, ¿desea arreglar los datos de entrada?\na. Sí\nb. No\nSeleccióne una opción\n"
lenc = .-c
cero:    .asciz "Diferencia: 0 \n"
lencero = .-cero

a: .asciz "\n"
lena = .-a

d: .asciz "-"
lend = .-d
num: .asciz "Error, el número no se puede representar en 32 bits, desea arreglar los datos de entrada?\na. Sí\nb. No\nSeleccióne una opción\n"
lennum = .-num

opcion: .word 0				@se va aguardar la opcion
num1: .word 100				@se va aguardar el primer numero
num2: .word 100				@se va aguardar el segundo numero
resultadoSuma: .fill 100 		@variable para guardar el resultado de la suma
resultadoDiferencia: .fill 100 		@variable para guardar el resultado de la diferencia
opcion2: .word 0			@se va aguardar la opcion
lookupTable: .asciz "0123456789ABCDEF"	@tabla para obtener el valor ascii de los valores numericos
lenLT = .-lookupTable

.section .text

.globl _start
_start:
	ldr r11,=resultadoSuma
	ldr r14, =lookupTable		@ r14 va a contener la posisicion de la lookup table

	imprime entrada, lenentrada
	
	mov r7, #3 @cargar el primer digito a la variable
	mov r0, #0
	mov r2, #100
	ldr r1, =opcion
	swi 0
	
	@ Verificar que haya escogido alguna de las cuatros opciones
	ldrb r10, [r1]
	cmp r10, #96
	ble error
	cmp r10, #101
	bge error
	
	imprime primero, lenprimero
	mov r7, #3 @cargar el primer digito a la variable
	mov r0, #0
	mov r2, #100
	ldr r1, =num1
	swi 0
	mov r5, #0
	b extremoizquierdo

@---------------------------------------------------------------------------------
@ primer función para comprobar que solo se ingresaron números.
@ r1 contiene el numero ingresado por el usuario.
@ r3 contiene el byte de la entrada y lo compara para ver si es menor que el valor
@ ascii anterior al cero, si es así salta a error sino va a revisar el otro extremo.
@ si el numero tiene mas de diez digitos salata a error
@---------------------------------------------------------------------------------
extremoizquierdo:

	ldrb r3, [r1]
	cmp r3, #10
	beq atoi1
	cmp r5, #9
	bgt errornum
	ldr r4, =47
    	cmp r3, r4
    	ble error
    	add r5,r5,#1
    	bge extremoderecho

@---------------------------------------------------------------------------------
@ segunda función para comprobar que solo se ingresaron números.
@ r3 esta vez se compara con el valor ascii del 9 y si es mayor salta a error.
@ se incrementa el valor de r1 que contiene el numero ingresado.
@---------------------------------------------------------------------------------
extremoderecho:

	ldr r4, =57
    	cmp r3, r4
    	bgt error
    	add r1, r1, #1
    	b extremoizquierdo
    

@---------------------------------------------------------------------------------
@ Función Ascii to Inteeger para convertir la entrada 1 a valores numericos.
@ r4 contiene la base decimal. r3 contiene el byte por manipular en cada ciclo
@ r1 contiene el numero ingresado. r6 contiene el total en cada ciclo.
@ r9 guarda el total para proximas manipulaciones.
@ si el numero es mayor al mayor numero que se puede representar con 32 bits salta error.
@---------------------------------------------------------------------------------
atoi1:
	mov r4, #10
	mov r5, #0
	mov r6, #0
	mov r7, #0
	mov r3, #0
	mov r1, #0
	ldr r1, =num1
proceso1:
	ldrb r3, [r1]
	cmp r3, #10
	moveq r5, #0
	beq segundonumero

	sub r3, r3, #'0' 
	umull r6, r7, r4, r6
	cmp r7, #0
	bne errornum
	adcs r6, r6, r3
	bcs errornum
	sub r6, r6, #1

	mov r9, r6
	add r1, r1, #1
	b proceso1

@---------------------------------------------------------------------------------
@ primer función para comprobar que solo se ingresaron números.
@ r1 contiene el numero ingresado por el usuario.
@ r3 contiene el byte de la entrada y lo compara para ver si es menor que el valor
@ ascii anterior al cero, si es así salta a error sino va a revisar el otro extremo.
@ si el numero tiene mas de diez digitos salata a error.
@---------------------------------------------------------------------------------
extremoizquierdo2:

	ldrb r3, [r1]
	cmp r3, #10
	beq atoi2
	cmp r5, #9
	bgt errornum
	ldr r4, =47
    	cmp r3, r4
    	ble error
    	add r5, r5, #1
    	bge extremoderecho2

@---------------------------------------------------------------------------------
@ segunda función para comprobar que solo se ingresaron números.
@ r3 esta vez se compara con el valor ascii del 9 y si es mayor salta a error.
@ se incrementa el valor de r1 que contiene el numero ingresado.
@---------------------------------------------------------------------------------
extremoderecho2:

	ldr r4, =57
    	cmp r3, r4
    	bgt error
    	add r1, r1, #1
    	b extremoizquierdo2

segundonumero:
imprime segundo, lensegundo
	mov r7, #3
	mov r0, #0
	mov r2, #100
	ldr r1, =num2
	swi 0
	b extremoizquierdo2

@---------------------------------------------------------------------------------
@ Función Ascii to Inteeger para convertir la entrada 2 a valores numericos.
@ r4 contiene la base decimal. r3 contiene el byte por manipular en cada ciclo
@ r1 contiene el numero ingresado. r6 contiene el total en cada ciclo.
@ r8 guarda el total para proximas manipulaciones.
@ si el numero es mayor al mayor numero que se puede representar con 32 bits salta error.
@---------------------------------------------------------------------------------
atoi2:
	mov r4, #10
	mov r5, #0
	mov r6, #0
	mov r8, #0
	mov r3, #0
	mov r1, #0
	mov r7, #0
	ldr r1, =num2
proceso2:
	ldrb r3, [r1]
	cmp r3, #10
	beq comparacion

	
	sub r3, r3, #'0' 
	umull r6, r7, r4, r6
	cmp r7, #0
	bne errornum
	adcs r6, r6, r3
	bcs errornum
	sub r6, r6, #1

	mov r8, r6
	add r1, r1, #1
	b proceso2	

@---------------------------------------------------------------------------------
@funcion para comparar la entrada y dependiendo de que valor escogio se porcesan los datos.
@---------------------------------------------------------------------------------
comparacion:
	

	 cmp r10, #'a'
	 beq sumar
	 cmp r10, #'b'
	 beq restar
	 cmp r10, #'c'
	 beq multiplicar
	 cmp r10, #'d'
	 beq dividir

@---------------------------------------------------------------------------------	
@ Función de suma. 
@ r9 contiene el primer numero. r8 contiene el segundo numero.
@ el resultado de la suma queda en r12.	
@ si la suma da overflow da error sino la procesa.
@---------------------------------------------------------------------------------	
sumar:
	imprime suma, lensuma
	imprime a, lena
	adcs r12, r9, r8
	bcs errorOF
	mov r8, #0
	sub r12, r12, #1
	b preparacion

@---------------------------------------------------------------------------------
@ función de resta en caso de que la entrada 1 sea mayor a la entrada 2.
@ r9 contiene el primer numero. r8 contiene el segundo numero.
@ r12 contiene el resultado.
@---------------------------------------------------------------------------------
restar:
imprime cero,lencero
	cmp r9, r8
	blt resta2
	sub r12, r9, r8
	imprime a, lena
	b preparacion

@---------------------------------------------------------------------------------
@ función de resta en caso de que la entrada 1 sea menor a la entrada 2. 
@ r9 contiene el primer numero. r8 contiene el segundo numero.
@ r12 contiene el resultado. r8 se usa como indicador para despues imprimir el menos
@ ya que este caso siempre es negativo.
@---------------------------------------------------------------------------------
resta2:
	
	sub r12, r8, r9
	mov r8, #0
	mov r8, #1
	imprime a, lena
	b preparacion

@---------------------------------------------------------------------------------
@ Multiplica los dos numeros si da overlfow salta a otro procesamiento sino se procesa normal.
@ en r12 queda la parte baja de los posibles 64 bits y en r3 queda la parte alta.
@---------------------------------------------------------------------------------
multiplicar:
imprime multiplicacion, lenmultipĺicacion
	umull r12, r3, r9, r8
	cmp r3, #0
	beq preparacion
	b preparacionMul

@---------------------------------------------------------------------------------
@ función de resta en caso de que la entrada 1 sea mayor a la entrada 2.
@ en r12 queda la division entera.
@---------------------------------------------------------------------------------
dividir:
imprime division, lendivision
	cmp r9, r8
	blt dividir2
	sdiv r12, r9, r8
	imprime a, lena
	b preparacion

@---------------------------------------------------------------------------------
@ función de division en caso de que la entrada 1 sea menor a la entrada 2. 
@ r9 contiene el primer numero. r8 contiene el segundo numero.
@ r12 contiene el resultado.
@---------------------------------------------------------------------------------
dividir2:
	sdiv r12, r8, r9
	imprime a, lena
	b preparacion

@---------------------------------------------------------------------------------
@ limpia los registros y carga la base inicial que es la hexadecimal.
@---------------------------------------------------------------------------------
preparacion: 

	mov r10, #16
	mov r0, #0
	mov r5, #0
	mov r4, #0
	mov r2, #0
	mov r1, #0
	
@---------------------------------------------------------------------------------
@ funciones para formar un Inteeger to Ascii para convertir la suma a cadena decaracteres que se puedan mostrar en pantalla.
@ r4 utiliza como puntero para escribir los caracteres en la varibale resultadoSuma.
@ r5 tiene el resultado de la suma. r7 tiene el exponente de cada ciclo. r0 tiene la base de cada ciclo.
@ r11 va a ser el contador para encontrar el digito mas significativo. r10 guarda la base de cada ciclo.
@ depende de la base en la que se trabaje esta se eleva a un exponente diferente para poder representar la cantidad
@ maxima de caracteres. Cuando la base sea 0 saltamos a procesar la diferencia.
@---------------------------------------------------------------------------------
previa:
    mov r4, #0
    ldr r4, =resultadoSuma     
    mov r5, r12    
    cmp r10, #16                    
    moveq r7, #7
    cmp r10, #10
    moveq r7, #9
    cmp r10, #8
    moveq r7, #10
    cmp r10, #2
    moveq r7, #30          
    mov r11, #0
    cmp r10, #14
    beq aumentar
    cmp  r10, #12
    beq aumentar
    cmp r10, #6
    beq aumentar
    cmp r10, #4
    beq aumentar
    cmp r10, #0
    beq salir  


@---------------------------------------------------------------------------------
@ Cargar la base y el exponente, verificando que no sea exponente 0
@---------------------------------------------------------------------------------
potenciaMenor:
    mov r0, r10    
    mov r1, r7    
    cmp r1, #0       
    moveq r2, #1      
    beq paso4
    mov r2, r0      
    sub r1, #1  
    
@---------------------------------------------------------------------------------
@ r2 contiene la potencia de diez. r1 contiene el exponente.
@---------------------------------------------------------------------------------
paso3: 
    cmp r1, #0      
    ble paso4           
    mul r2, r0 ,r2   
    sub r1, #1       
    b paso3 

@---------------------------------------------------------------------------------
@ r6 contiene la potencia de diez. compara con el numero y si es menor salta a digito.
@ si no es menor le resta uno al exponente y salata apotencia menor.
@---------------------------------------------------------------------------------
paso4:
    mov r0, r2      
    
    
    mov r6, r0          
    cmp r6, r5           
    ble digito       
    sub r7, #1           
                             
    b potenciaMenor

@---------------------------------------------------------------------------------
@ Encontrar el digito más significativo restando las potencias de la base especifica.
@ la cantidad de veces que se pueda restar la potencia de la base al numero es el 
@ digito que debemos guardar. r11 es el contador de veces que se resto la potencia.
@ cuando el numero sea menor que la potencia vamos a guardar el numero.
@---------------------------------------------------------------------------------
digito:
    cmp r5, r6          
    blt escribir           
    add r11, r11, #1      
    sub r5, r5, r6      
    b digito 

@---------------------------------------------------------------------------------
@ Buscar en la lookup table el caracter correspondiente al digito y  guardarlo en la variable resultadoSuma.
@ r4 tiene la posicion donde debemos escribir el caracter. r11 el caracter que debemos escribir.
@ si el exponente es cero vamos a imprimir el resultado sino hacemos el proceso de crear una potencia de diez.
@---------------------------------------------------------------------------------
escribir:
	
    ldrb r11, [r14, r11]    
    strb r11, [r4], #1    


    sub r7, #1          
    cmp r7, #0          
    blt menos            
    
    mov r0, r10    
    mov r1, r7    
    cmp r1, #0      
    moveq r2, #1      
    beq paso2
    mov r2, r0      
    sub r1, #1  

@---------------------------------------------------------------------------------
@ Buscar en la lookup table el caracter correspondiente al digito y  guardarlo en la variable resultadoSuma.
@ r4 tiene la posicion donde debemos escribir el caracter. r11 el caracter que debemos escribir.
@ si el exponente es cero vamos a imprimir el resultado sino hacemos el proceso de crear una potencia de diez.
@---------------------------------------------------------------------------------
paso1: 
    cmp r1, #0       
    ble paso2          
    mul r2, r0 ,r2  
    sub r1, #1      
    b paso1 

@---------------------------------------------------------------------------------
@ mover resultado a r6 para ir a verificar si la nueva potencia es menor.
@ reseteamos r11 para ver el nuevo digito.
@---------------------------------------------------------------------------------
paso2:
    mov r0, r2      
    mov r6, r0           
    mov r11, #0           
    b digito 
@---------------------------------------------------------------------------------
@ imprime la variable resultadoSuma.
@ Saltamos a procesar la diferencia.
@--------------------------------------------------------------------------------- 
finalItoa: 

	
    mov r7, #4          
    mov r0, #1          
    ldr r1, =resultadoSuma      
    mov r2, #35         
    swi 0
    imprime a, lena
    @add registro, registro, #1
    @b previa
    sub r10, r10, #2
    b previa

@---------------------------------------------------------------------------------
@ resta dos a las bases para avanzar en el ciclo
@---------------------------------------------------------------------------------
aumentar:
	sub r10, r10, #2
	b previa

@---------------------------------------------------------------------------------
@ Imprime el signo menos cuando el numero es negativo
@---------------------------------------------------------------------------------
menos:
	cmp r8, #1
	bne finalItoa
	imprime d, lend
	b finalItoa

@---------------------------------------------------------------------------------
@ imprime un cero en la diferencia cuando es cero.
@---------------------------------------------------------------------------------
casoCero:

    imprime cero, lencero
    b salir	

@---------------------------------------------------------------------------------
@imprime mensaje de error y pregunta si se desea reiniciar o terminar el programa
@---------------------------------------------------------------------------------
error: 
	imprime b, lenb
	mov r7, #3
	ldr r0, =0
	ldr r1, =opcion2
	ldr r2, =4
	swi 0

	ldrb r1, [r1]
	ldr r2, =97
	cmp r1, r2
	beq _start
	
	b salir

@---------------------------------------------------------------------------------
@ prepara los registros para hacer el proceso de 64 bits.
@ r2 hace una copia de la parte baja del resultado de la multiplicacion.
@ r10 hace una copia de la parte alta del resultado.
@---------------------------------------------------------------------------------
preparacionMul:
mov r8, #16
mov r2, r12
mov r10, r3
mov r1, #17
b resultadoMul

@---------------------------------------------------------------------------------
@ r12 vuelve a tener la parte baja del resultado. r3 vuelve a tener la parte alta del resultado.
@ r4 va a tener la posicion del caracter por escribir, se va a escribir de derecha a izquierda.
@ r8 tienen la base en la que se va a trabajar, cuando llegue a cero acaba el programa.
@ r1 tiene la cantidad maxima de digitos representables en 64 bits para cada una de las bases.
@ r5 contador de la cantidad de digitos que lleva.
@ se compara r8 para solo procesar las bases 2, 8 y 16.
@---------------------------------------------------------------------------------
resultadoMul:
	mov r12, r2
	mov r3, r10
	mov r4, #0
	ldr r4, =resultadoSuma
	mov r11, #'\n'
	strb r11, [r4], #-1
	mov r5, #0
	cmp r8, #16
	moveq r1, #17
	beq hexadecimal
	cmp r8, #8
	moveq r1, #23
	beq octal
	cmp r8, #2
	moveq r1, #65
	beq binario
	cmp r8, #0
	beq salir
	sub r8, r8, #2
	b resultadoMul

@---------------------------------------------------------------------------------
@ caso cuando se trabaja la base hexadecimal.
@ r1 tiene la cantidad de digitos que se pueden representar en 64 bits.
@---------------------------------------------------------------------------------
hexadecimal:
	add r4, r4, r1
	b previa2

@---------------------------------------------------------------------------------
@ caso cuando se trabaja la base octal
@ r1 tiene la cantidad de digitos que se pueden representar en 64 bits.
@---------------------------------------------------------------------------------
octal:
	add r4, r4, r1
	b previa2

@---------------------------------------------------------------------------------
@ caso cuando se trabaja la base binaria.
@ r1 tiene la cantidad de digitos que se pueden representar en 64 bits.
@---------------------------------------------------------------------------------
binario:
	add r4, r4, r1
	b previa2

@---------------------------------------------------------------------------------
@ compara para saber si sa se llego al maximo de digitos y salta a imprimir el numero sino inicializa r7 y r6.
@---------------------------------------------------------------------------------
previa2:
	add r5, r5, #1
	cmp r5, r1
	bgt finalMultiplicacion
	mov r7, #0
	mov r6, #0
	
	b movimientoBits

@---------------------------------------------------------------------------------
@ El movimiento de bits fue el tipo de procesamiento que se eligio para esta parte del proyecto
@ pero no se comprendio para hacerlo desde cero, se encontraron varias implementaciones todas muy parecidas
@ por lo que cocluimos que esa era la mejor forma de hacerlo y adaptamos la funcion loop recuperada de
@ gpit2286. 64-bit-math. GitHub. https://github.com/gpit2286/armasm-by-example/blob/master/16-64-bit-math/main.s 
@---------------------------------------------------------------------------------
movimientoBits:
	add r7, r7, #1
	cmp r7, #64
	bgt guardaCaracter
	lsl r6, #1
	lsls r3, #1
	adc r6, #0
	lsls r12, #1
	adc r3, #0
	cmp r6, r8
	blt movimientoBits
	sub r6, r6, r8
	add r12, r12, #1
	b movimientoBits

@---------------------------------------------------------------------------------
@ Usa la lookup table para saber cual digito corresponde y guardarlo.
@ r6 tiene el digito que hay que buscar. r11 tiene el valor ascii.
@---------------------------------------------------------------------------------
guardaCaracter:
	ldrb r11, [r14, r6]
	strb r11, [r4], #-1
	b previa2

@---------------------------------------------------------------------------------
@ imprime el resultado en pantalla, debido al tipo de procesamiento salen ceros a la izquierda.
@ restamos 2 al contador de bases y pasasmos a la siguiente base.
@---------------------------------------------------------------------------------
finalMultiplicacion:
	imprime resultadoSuma, #65
	sub r8, r8, #2
	imprime a, lena
	b resultadoMul

@---------------------------------------------------------------------------------
@imprime mensaje de error cuando hay overflow y pregunta si se desea reiniciar o terminar el programa
@---------------------------------------------------------------------------------
errorOF: 
	mov r12, #0
	imprime c, lenc
	mov r7, #3
	ldr r0, =0
	ldr r1, =opcion2
	ldr r2, =4
	swi 0

	ldrb r1, [r1]
	ldr r2, =97
	cmp r1, r2
	beq _start

	b salir

@---------------------------------------------------------------------------------
@imprime mensaje de error cuando el numero tiene mas de diez digitos y pregunta si se desea reiniciar o terminar el programa
@---------------------------------------------------------------------------------
errornum:
	imprime num, lennum
	mov r7, #3
	ldr r0, =0
	ldr r1, =opcion2
	ldr r2, =4
	swi 0

	ldrb r1, [r1]
	ldr r2, =97
	cmp r1, r2
	beq _start

	b salir

salir:	@fin del programa
imprime a, lena
	mov r7, #1
	mov r0, #0
	swi 0

