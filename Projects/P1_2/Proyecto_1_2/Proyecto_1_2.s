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
primero:    .asciz "Ingrese el primer digito: "
lenprimero = .-primero
segundo:    .asciz "Ingrese el segundo digito: "
lensegundo = .-segundo
suma:    .asciz "Suma: "
lensuma = .-suma
diferencia:    .asciz "Diferencia: "
lendiferencia = .-diferencia

b:    .asciz "Error, dato erroneo ingresado"
lenb = .-b

cero:    .asciz "Diferencia: 0 \n"
lencero = .-cero

num1: .word 100
num2: .word 100
resultadoSuma: .fill 100 @variable para guardar el resultado de la suma
resultadoDiferencia: .fill 100 @variable para guardar el resultado de la diferencia

.section .text

.globl _start
_start:
	ldr r11,=resultadoSuma
	imprime primero, lenprimero
	
	mov r7, #3 @cargar el primer digito a la variable
	mov r0, #0
	mov r2, #100
	ldr r1, =num1
	swi 0
	b extremoizquierdo

@primer función para comprobar que solo se ingresaron números
extremoizquierdo:

	ldrb r3, [r1]
	cmp r3, #10
	beq atoi1
	ldr r4, =47
    cmp r3, r4
    ble error
    bge extremoderecho
@segunda función para comprobar que solo se ingresaron números
extremoderecho:

	ldr r4, =57
    cmp r3, r4
    bgt error
    add r1, r1, #1
    b extremoizquierdo
@Función Ascii to Inteeger para convertir la entrada 1 a un valores numerico
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
	beq segundonumero

	sub r3, r3, #'0' 
	mul r6, r4, r6
	add r6, r6, r3

	mov r9, r6
	add r1, r1, #1
	b proceso1

@Función Ascii to Inteeger para convertir el segundo número a un valor numerico
segundonumero:
imprime segundo, lensegundo
	mov r7, #3
	mov r0, #0
	mov r2, #100
	ldr r1, =num2
	swi 0
atoi2:
	mov r4, #10
	mov r5, #0
	mov r6, #0
	mov r8, #0
	mov r3, #0
	mov r1, #0
	ldr r1, =num2
proceso2:
	ldrb r3, [r1]
	cmp r3, #10
	beq sumar

	sub r3, r3, #'0' 
	mul r6, r4, r6
	add r6, r6, r3

	mov r8, r6
	add r1, r1, #1
	b proceso2	
@Función de suma	
sumar:
	add r12, r9, r8
	b previa
@función de diferencia en caso de que la entrada 1 sea mayor a la entrada 2
diferenciar:
	cmp r9, r8
	blt diferencia2
	sub r10, r9, r8
	b previa2
@función de diferencia en caso de que la entrada 1 sea menor a la entrada 2
diferencia2:
	sub r10, r8, r9
	b previa2

@funciones para formar un Inteeger to Ascii para convertir la suma a cadena decaracteres que se puedan mostrar en pantalla
previa:
	ldr r4, =resultadoSuma     
    mov r5, r12    
                             
    mov r7, #9          
    mov r11, #0           

@Cargar la base y el exponente, verificando que no sea exponente 0
potenciaMenor:
    mov r0, #10   
    mov r1, r7    
    cmp r1, #0       
    moveq r2, #1      
    beq paso4
    mov r2, r0      
    sub r1, #1  
    
@Resultado de eelevar la base a la potencia encontrada 
paso3: 
    cmp r1, #0      
    ble paso4           
    mul r2, r0 ,r2   
    sub r1, #1       
    b paso3 
@mover resultado a R0
paso4:
    mov r0, r2      
    
    
    mov r6, r0          
    cmp r6, r5           
    ble digito       
    sub r7, #1           
                             
    b potenciaMenor

@Encontrar el digito más significativo restando las potencias de la base especifica
digito:
    cmp r5, r6          
    blt escribir           
    add r11, r11, #1      
    sub r5, r5, r6      
    b digito 
@Añadir el caracter AScii y guardarlo en la variable resultadoSuma
escribir:
    add r11, #'0'         
    strb r11, [r4], #1    


    sub r7, #1          
    cmp r7, #0          
    blt finalItoa            
    
    mov r0, #10    
    mov r1, r7    
    cmp r1, #0      
    moveq r2, #1      
    beq paso2
    mov r2, r0      
    sub r1, #1  
@Resultado de eelevar la base a la potencia encontrada 
paso1: 
    cmp r1, #0       
    ble paso2          
    mul r2, r0 ,r2  
    sub r1, #1      
    b paso1 
@mover resultado a R0
paso2:
    mov r0, r2      
    mov r6, r0           
    mov r11, #0           
    b digito 
@Añadir el caracter salto de linea y imprime la variable resultadoSuma 
finalItoa: 
    mov r11, #'\n'        
    strb r11, [r4]        

	imprime suma, lensuma
    mov r7, #4          
    mov r0, #1          
    ldr r1, =resultadoSuma      
    mov r2, #11         
    swi 0
    b diferenciar

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Exactamente el mismo proceso pero ahora para convertir el resultado de la diferencia a caracteres Ascii
previa2:
    cmp r10, #0
    beq casoCero

	mov r1, #0
	mov r2, #0

	ldr r4, =resultadoDiferencia     
    mov r5, r10    
                             
    mov r7, #9          
    mov r8, #0           

@Cargar la base y el exponente, verificando que no sea exponente 0
potenciaMenor2:
    mov r0, #10   
    mov r1, r7    
    cmp r1, #0       
    moveq r2, #1      
    beq paso42
    mov r2, r0      
    sub r1, #1  
@Resultado de eelevar la base a la potencia encontrada 
paso32: 
    cmp r1, #0      
    ble paso42           
    mul r2, r0 ,r2   
    sub r1, #1       
    b paso32 
@mover resultado a R0
paso42:
    mov r0, r2      
    
    
    mov r6, r0          
    cmp r6, r5           
    ble digito2       
    sub r7, #1           
                             
    b potenciaMenor2

@Encontrar el digito más significativo restando las potencias de la base especifica
digito2:
    cmp r5, r6          
    blt escribir2           
    add r8, r8, #1      
    sub r5, r5, r6      
    b digito2 
@Añadir el caracter AScii y guardarlo en la variable resultadoSuma
escribir2:
    add r8, #'0'         
    strb r8, [r4], #1    


    sub r7, #1          
    cmp r7, #0          
    blt finalItoa2            
    
    mov r0, #10    
    mov r1, r7    
    cmp r1, #0      
    moveq r2, #1      
    beq paso22
    mov r2, r0      
    sub r1, #1 
@Resultado de eelevar la base a la potencia encontrada 
paso12: 
    cmp r1, #0       
    ble paso22         
    mul r2, r0 ,r2  
    sub r1, #1      
    b paso12
    
@mover resultado a R0
paso22:
    mov r0, r2      
    mov r6, r0           
    mov r8, #0           
    b digito2 
@Añadir el caracter salto de linea y imprime la variable resultadoSuma 
finalItoa2: 
    mov r8, #'\n'        
    strb r8, [r4]        

	imprime diferencia, lendiferencia
    mov r7, #4          
    mov r0, #1          
    ldr r1, =resultadoDiferencia      
    mov r2, #11         
    swi 0
    b salir

casoCero:

    imprime cero, lencero
    b salir

error: @imprime mensaje de error y termina el programa
	imprime b, lenb
	b salir
salir:	@fin del programa
	mov r7, #1
	mov r0, #0
	swi 0
