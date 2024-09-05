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
inicio:    .asciz "Ingresa una cadena: "
leninicio = .-inicio
final:    .asciz "Cadena convertida: "
lenfinal = .-final

a:    .asciz "Palabra convertida: "
lena = .-a

b:    .asciz "Error, dato erroneo ingresado o número de caracteres excedido\n"
lenb = .-b



mensaje:.space 100 @Variable y tamaño para guardar el mensaje a convertir


.section .text
.globl _start
_start:
    imprime inicio, leninicio
	
	@Recibe el mensaje del usuario y lo guarda en la variable
	mov r7, #3
	mov r0, #0
	mov r2, #100
	ldr r1, =mensaje
	swi 0

	
	b conversion
@ciclo para revisar los caracteres en la cadena
conversion:

	@Cargar a r3 la dirección de la cadena
	ldrb r3,[r1]
	cmp r3, #10 @Compara que no sea el final de la cadena, si lo es, imprime la nueva cadena
	beq imprimir
	
	@Comparar que el elemento no sea menor que la A mayuscula 
	ldr r4, =64
	cmp r3,r4
	ble prueba1 @salto a función que revisa que el elemento no sea un espacio
	
	@comparar que el elemento sea menor que la z minuscula
	ldr r4, =122
	cmp r3, r4
	ble prueba2 @Salto a función que revisa que el elemento sea una letra valida
	
	@comparar que el elemento sea mayor a z minuscula
	ldr r4, =123
	cmp r3,r4
	bge error @si lo es quiere decir que no es una letra, por lo tanto envia error
	
	
	

	b conversion
	
prueba2:
	@comparar el caracter con la Z mayuscula
	ldr r4, =90
	cmp r3, r4
	ble minuscula @si es menor es una letra, salta a funcion para convertir a minuscula
	
	@comparar el caracter con la a minuscula
	ldr r4, =97
	cmp r3, r4
	bge mayuscula @si es mayor es una letra, por lo tanto salta a convertir a mayuscula
	
	b error @si no se cumple ninguna condición manda error, no hay una letra
	
prueba1:
	@compara el elemento con un espacio
	ldr r4, =32
	cmp r3,r4
	beq espacio @si es un espacio enviar a función para solamente continuar obviando el espacio
	
	@comparar elemento con salto de linea(final de la cadena)
	cmp r3, #10
	beq imprimir @si es un salto de linea envia a imprimir porque se terminó la cadena
	
	b error

error: @imprime mensaje de error y termina el programa
imprime b, lenb

b salir
espacio: @revisa que el caracter sera un espacio, si lo es, pasa al siguiente caracter
    add r1, r1, #1
    b conversion
    
minuscula: @Funcion para convertir una mayuscula a una minuscula
	add r3, r3, #32
	strb r3,[r1]
	add r1, r1, #1
	b conversion
    
mayuscula: @Función para convertir de minuscula a mayuscula
	sub r3, r3, #32
    strb r3,[r1]
    add r1, r1, #1
    b conversion


imprimir: @imprime cadena modificada
imprime a, lena
	push {r0-r12,lr}
	mov r7,#4
	mov r0, #1
	mov r2, #100
	ldr r1, =mensaje
	svc 0
		pop {r0-r12,lr}
salir:	@fin del programa
	mov r7, #1
	mov r0, #0
	swi 0
