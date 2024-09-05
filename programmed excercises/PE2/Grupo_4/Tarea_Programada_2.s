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
inicio:    .asciz "Desea leer un archivo o escribir un texto en consola?\na)consola\nb)archivo\nPor favor seleccione una opcion:\n"
leninicio = .-inicio
lenguaje:    .asciz "De que lenguaje a que lenguaje desea la traduccion:\na)De espanol a Malespin\nb)De Malespin a espanol\nElija la opcion que desea: \n"
lenlenguaje = .-lenguaje
entradaMensaje: .asciz "ingrerse el mensaje que desea convertir:\n"
lenentradaMensaje= .-entradaMensaje
archivomodificado: .asciz "Archivo de salida modificado: "
lenarchivomodificado= .-archivomodificado 
totalpalabras: .asciz "Total de palabras del archivo de entrada texto: "
lentotalpalabras= .-totalpalabras
Totalletras: .asciz "Total de letras del archivo de entrada: "
lenTotalletras= .-Totalletras 
totalPconvertidas: .asciz "Total de Palabras convertidas: "
lentotalPconvertidas= .-totalPconvertidas 
porcentajeP: .asciz "Porcentaje de palabras convertidas: %"
lenporcentajeP= .-porcentajeP 
totalLcambiadas: .asciz "Total de letras cambiadas: "
lentotalLcambiadas= .-totalLcambiadas 
porcentajeL: .asciz "Porcentaje de letras cambiadas: %"
lenporcentajeL= .-porcentajeL
Archivo: .asciz "traduccion.txt\n"
lenArchivo= .-Archivo
PideArchivo: .asciz "Ingrese el nombre del archivo del cual desea leer su contenido: \n"
lenPideArchivo= .-PideArchivo

a:    .asciz "Palabra convertida: "
lena = .-a

b:    .asciz "Error, dato erroneo ingresado o numero de caracteres excedido\n"
lenb = .-b

c: .asciz "Ocurrio un arror al abrir el archivo\n"
lenc = .-c

d: .asciz "Ocurrio un arror al leer el archivo\n"
lend = .-d
e:    .asciz "Error, dato erroneo ingresado o numero de caracteres excedido\n"
lene = .-e
f: .asciz "Error, se encontro una palabra con mas de 80 caracteres\n"
lenf= .-f

nombreArchivo: .asciz "traduccion.txt"
nombreArchivo2: .asciz "archivo.txt"
auxiliarArchivo: .fill 100	@variable para guarada el nombre del archivo sin salto de linea
opcion: .word 0			@variable para guardar si es consola o archivo
opcion1: .word 0		@variable para guardar opcion de traduccion
opcion2: .word 0		@variable para guardar opcion de traduccion
resultado: .fill 100 		@variable para guardar el resultado de las operaciones
archivolee: .word 100		@variable para guardar el nombre del archivo
mensaje:.space 2070 		@Variable y tamaño para guardar el mensaje a convertir


.section .text
.globl _start
_start:
    imprime inicio, leninicio
    mov r7, #3 			@cargar el primer digito a la variable
    mov r0, #0
    mov r2, #100
    ldr r1, =opcion
    swi 0

    ldrb r10, [r1]
    cmp r10, #97
    beq opcionTraducir1
    cmp r10, #98
    beq opcionLeer
    b errorEnt
@------------------------------------------------------------------------------------------------------
@ Imprime el mensaje para saber el formato de la traduccion
@------------------------------------------------------------------------------------------------------
opcionTraducir1:
    imprime lenguaje, lenlenguaje
    mov r7, #3 @cargar el primer digito a la variable
    mov r0, #0
    mov r2, #100
    ldr r1, =opcion1
    swi 0

    ldrb r10, [r1]
    cmp r10, #97
    beq TraduccionEM
    cmp r10, #98
    beq TraduccionEM
    b errorEnt

@------------------------------------------------------------------------------------------------------
@ Pide el nombre del archivo al usuario, r1 queda como puntero al nombre del archivo. llama al ciclo para quitar
@ el salto de linea al nombre del archivo
@------------------------------------------------------------------------------------------------------
opcionLeer:
imprime PideArchivo, lenPideArchivo
    mov r1, #0
    mov r7, #3 				@cargar el primer digito a la variable
    mov r0, #0
    mov r2, #100
    ldr r1, =archivolee
    swi 0
    mov r5, #0
    ldr r5, =auxiliarArchivo
    b cicloArchivo

@------------------------------------------------------------------------------------------------------
@ Abre el archivo en modo lectura y agarra lo que haya en el archivo. r1 tiene el puntero al contenido del archivo
@ prepara las variables para la traducción del contenido
@------------------------------------------------------------------------------------------------------	
abrirArchivo:	
	mov r7, #5
	ldr r0, =auxiliarArchivo
	mov r1, #0
	svc 0
	@mov r1, #0
	push {r0}
	cpy r4, r0
	@ldr r3, =0
	@cmp r4, r3
	@bne errorArchivo
	
	mov r7, #3
	cpy r0, r4
	ldr r1, =mensaje
	mov r2, #2049
	svc 0
	@cmp r4, r3
	@bne errorArchivoL
	pop {r0}
	mov r7, #6
	svc 0

	mov r1, #0

    imprime lenguaje, lenlenguaje
    mov r7, #3 @cargar el primer digito a la variable
    mov r0, #0
    mov r2, #100
    ldr r1, =opcion1
    swi 0

    mov r8, #0
    mov r5, #0
    mov r7, #0
    ldr r2,=2049
    mov r4, #0
    ldrb r10, [r1]
    cmp r10, #97
    ldr r1, =mensaje
    beq cicloLenMensaje
    cmp r10, #98
    ldr r1, =mensaje
    beq cicloLenMensaje
   
@------------------------------------------------------------------------------------------------------
@ Elimina el caracter de salto linea del nombre del archivo
@------------------------------------------------------------------------------------------------------
cicloArchivo:
	ldrb r3, [r1]
	cmp r3, #10
	beq abrirArchivo
	strb r3, [r5], #1
	add r1, r1, #1
	b cicloArchivo
	


@-------------------------------------------------------------------------------------------------------------
@ solicita el texto del usuario por consola y prepara los registros para el procesamiento
@-------------------------------------------------------------------------------------------------------------
TraduccionEM:
imprime entradaMensaje, lenentradaMensaje
    mov r7, #3 @cargar el primer digito a la variable
    mov r0, #0
    mov r2, #2049
    ldr r1, =mensaje
    swi 0
    mov r8, #0
    mov r7, #0
    ldr r2,=2049
    mov r4, #0
    b cicloLenMensaje

@------------------------------------------------------------------------------------------------------
@ Saca la longitud del contenido, si sobrepasa los limites da error
@------------------------------------------------------------------------------------------------------
cicloLenMensaje:
	add r4, r4, #1
	cmp r4, r2
	bgt error
	ldrb r3, [r1]
	cmp r3, #10
	beq prepAS
	add r1, r1, #1
	
	b cicloLenMensaje

@------------------------------------------------------------------------------------------------------
@ prepara el puntero para el contenido del mensaje
@------------------------------------------------------------------------------------------------------
prepAS:
    mov r10, #1
    mov r11, #0
	mov r1, #0
	ldr r1, =mensaje
	push {r4}
	b as

@------------------------------------------------------------------------------------------------------
@ Traduce de Espanol a malespin. r3 contiene el byte para compararlo segun las letras que deben cambiarse
@ r4 contiene las letras que deben ser cambiadas. r1 puntero para recorrer la entrada. r5 contador de palabras.
@ r6 contador de letras cambiadas. r7 contador de letras totales. r8 identificador de palabra cambiada. r9 contador de palabra cambiada
@------------------------------------------------------------------------------------------------------
as:
	
    ldrb r3,[r1]
    cmp r3, #10
    beq ChequeoUltimoCaracter

    mov r0, r1
    ldr r4, =32
    cmp r3, r4
    beq PalabraN

    ldr r4, =64
    cmp r3, r4
    ble Espacios
    ldr r4, =123
    cmp r3, r4
    bge Espacios
    ldr r4, =91
    cmp r3, r4
    beq Espacios
    ldr r4, =92
    cmp r3, r4
    beq Espacios
    ldr r4, =93
    cmp r3, r4
    beq Espacios
    ldr r4, =94
    cmp r3, r4
    beq Espacios
    ldr r4, =95
    cmp r3, r4
    beq Espacios
    ldr r4, =96
    cmp r3, r4
    beq Espacios

    add r7, r7, #1
    add r11, r11, #1
	
    ldr r4, =69
    cmp r3, r4
    beq letraEM
    
    ldr r4, =79
    cmp r3, r4
    beq letraOM
    
    ldr r4, =84
    cmp r3, r4
    beq letraTM
    
    ldr r4, =71
    cmp r3, r4
    beq letraGM
    
    ldr r4, =77
    cmp r3, r4
    beq letraMM
    
    ldr r4, =101
    cmp r3, r4
    beq letraEm
    
    ldr r4, =111
    cmp r3, r4
    beq letraOm
    
    ldr r4, =116
    cmp r3, r4
    beq letraTm
    
    ldr r4, =103
    cmp r3, r4
    beq letraGm
    
    ldr r4, =109
    cmp r3, r4
    beq letraMm
    
	
    ldr r4, =65
    cmp r3, r4
    beq letraAM
    
    ldr r4, =73
    cmp r3, r4
    beq letraIM
    
    ldr r4, =66
    cmp r3, r4
    beq letraBM
    
    ldr r4, =70
    cmp r3, r4
    beq letraFM
    
    ldr r4, =80
    cmp r3, r4
    beq letraPM
    
    ldr r4, =97
    cmp r3, r4
    beq letraAm
    
    ldr r4, =105
    cmp r3, r4
    beq letraIm
    
    ldr r4, =98
    cmp r3, r4
    beq letraBm
    
    ldr r4, =102
    cmp r3, r4
    beq letraFm
    
    ldr r4, =112
    cmp r3, r4
    beq letraPM   

    
    b letraX

@------------------------------------------------------------------------------------------------------
@ Cambia la letra E por A aumenta los contadores de letras y letras cambiadas. avanza en el ciclo 
@ Setea identificador de palabra modificada
@------------------------------------------------------------------------------------------------------
letraEM:
	sub r3, r3, #4
	strb r3,[r1]
	add r1, r1, #1
	add r6, r6, #1
	add r8, r8, #1
	b as

@------------------------------------------------------------------------------------------------------
@ Cambia la letra O por I aumenta los contadores de letras y letras cambiadas. avanza en el ciclo
@ Setea identificador de palabra modificada
@------------------------------------------------------------------------------------------------------
letraOM:
	sub r3, r3, #6
	strb r3,[r1]
	add r1, r1, #1
	add r6, r6, #1
	add r8, r8, #1
	b as

@------------------------------------------------------------------------------------------------------
@ Cambia la letra T por B aumenta los contadores de letras y letras cambiadas. avanza en el ciclo
@ Setea identificador de palabra modificada
@------------------------------------------------------------------------------------------------------
letraTM:
	sub r3, r3, #18
	strb r3,[r1]
	add r1, r1, #1
	add r6, r6, #1
	add r8, r8, #1
	b as

@------------------------------------------------------------------------------------------------------
@ Cambia la letra G por F aumenta los contadores de letras y letras cambiadas. avanza en el ciclo
@ Setea identificador de palabra modificada
@------------------------------------------------------------------------------------------------------
letraGM:
	sub r3, r3, #1
	strb r3,[r1]
	add r1, r1, #1
	add r6, r6, #1
	add r8, r8, #1
	b as

@------------------------------------------------------------------------------------------------------
@ Cambia la letra M por P aumenta los contadores de letras y letras cambiadas. avanza en el ciclo
@ Setea identificador de palabra modificada
@------------------------------------------------------------------------------------------------------
letraMM:
   add r3, r3, #3
	strb r3,[r1]
	add r1, r1, #1
	add r6, r6, #1
	add r8, r8, #1
	b as

@------------------------------------------------------------------------------------------------------
@ Cambia la letra e por a aumenta los contadores de letras y letras cambiadas. avanza en el ciclo
@ Setea identificador de palabra modificada
@------------------------------------------------------------------------------------------------------
letraEm:
	sub r3, r3, #4
	strb r3,[r1]
	add r1, r1, #1
	add r6, r6, #1
	add r8, r8, #1
	b as

@------------------------------------------------------------------------------------------------------
@ Cambia la letra o por i aumenta los contadores de letras y letras cambiadas. avanza en el ciclo
@ Setea identificador de palabra modificada
@------------------------------------------------------------------------------------------------------
letraOm:
	sub r3, r3, #6
	strb r3,[r1]
	add r1, r1, #1
	add r6, r6, #1
	add r8, r8, #1
	b as

@------------------------------------------------------------------------------------------------------
@ Cambia la letra t por b aumenta los contadores de letras y letras cambiadas. avanza en el ciclo
@ Setea identificador de palabra modificada
@------------------------------------------------------------------------------------------------------
letraTm:
	sub r3, r3, #18
	strb r3,[r1]
	add r1, r1, #1
	add r6, r6, #1
	add r8, r8, #1
	b as

@------------------------------------------------------------------------------------------------------
@ Cambia la letra g por f aumenta los contadores de letras y letras cambiadas. avanza en el ciclo
@ Setea identificador de palabra modificada
@------------------------------------------------------------------------------------------------------
letraGm:
	sub r3, r3, #1
	strb r3,[r1]
	add r1, r1, #1
	add r6, r6, #1
	add r8, r8, #1
	b as

@------------------------------------------------------------------------------------------------------
@ Cambia la letra m por p aumenta los contadores de letras y letras cambiadas. avanza en el ciclo
@ Setea identificador de palabra modificada
@------------------------------------------------------------------------------------------------------
letraMm:
	add r3, r3, #3
	strb r3,[r1]
	add r1, r1, #1
	add r6, r6, #1
	add r8, r8, #1
	b as

@------------------------------------------------------------------------------------------------------
@ Cambia la letra A por E aumenta los contadores de letras y letras cambiadas. avanza en el ciclo
@ Setea identificador de palabra modificada
@------------------------------------------------------------------------------------------------------
letraAM:
	add r3, r3, #4
	strb r3,[r1]
	add r1, r1, #1
	add r6, r6, #1
	add r8, r8, #1
	b as

@------------------------------------------------------------------------------------------------------
@ Cambia la letra I por O aumenta los contadores de letras y letras cambiadas. avanza en el ciclo
@ Setea identificador de palabra modificada
@------------------------------------------------------------------------------------------------------
letraIM:	
	add r3, r3, #6
	strb r3,[r1]
	add r1, r1, #1
	add r6, r6, #1
	add r8, r8, #1
	b as

@------------------------------------------------------------------------------------------------------
@ Cambia la letra B por T aumenta los contadores de letras y letras cambiadas. avanza en el ciclo
@ Setea identificador de palabra modificada
@------------------------------------------------------------------------------------------------------
letraBM:
	add r3, r3, #18
	strb r3,[r1]
	add r1, r1, #1
	add r6, r6, #1
	add r8, r8, #1
	b as

@------------------------------------------------------------------------------------------------------
@ Cambia la letra F por G aumenta los contadores de letras y letras cambiadas. avanza en el ciclo
@ Setea identificador de palabra modificada
@------------------------------------------------------------------------------------------------------
letraFM:
	add r3, r3, #1
	strb r3,[r1]
	add r1, r1, #1
	add r6, r6, #1
	add r8, r8, #1
	b as

@------------------------------------------------------------------------------------------------------
@ Cambia la letra P por M aumenta los contadores de letras y letras cambiadas. avanza en el ciclo
@ Setea identificador de palabra modificada
@------------------------------------------------------------------------------------------------------
letraPM:
	sub r3, r3, #3
	strb r3,[r1]
	add r1, r1, #1
	add r6, r6, #1
	add r8, r8, #1
	b as	

@------------------------------------------------------------------------------------------------------
@ Cambia la letra a por e aumenta los contadores de letras y letras cambiadas. avanza en el ciclo
@ Setea identificador de palabra modificada
@------------------------------------------------------------------------------------------------------	
letraAm:
	add r3, r3, #4
	strb r3,[r1]
	add r1, r1, #1
	add r6, r6, #1
	add r8, r8, #1
	b as

@------------------------------------------------------------------------------------------------------
@ Cambia la letra i por o aumenta los contadores de letras y letras cambiadas. avanza en el ciclo
@ Setea identificador de palabra modificada
@------------------------------------------------------------------------------------------------------
letraIm:	
	add r3, r3, #6
	strb r3,[r1]
	add r1, r1, #1
	add r6, r6, #1
	add r8, r8, #1
	b as

@------------------------------------------------------------------------------------------------------
@ Cambia la letra b por T aumenta los contadores de letras y letras cambiadas. avanza en el ciclo
@ Setea identificador de palabra modificada
@------------------------------------------------------------------------------------------------------
letraBm:
	add r3, r3, #18
	strb r3,[r1]
	add r1, r1, #1
	add r6, r6, #1
	add r8, r8, #1
	b as

@------------------------------------------------------------------------------------------------------
@ Cambia la letra f por g aumenta los contadores de letras y letras cambiadas. avanza en el ciclo
@ Setea identificador de palabra modificada
@------------------------------------------------------------------------------------------------------
letraFm:
	add r3, r3, #1
	strb r3,[r1]
	add r1, r1, #1
	add r6, r6, #1
	add r8, r8, #1
	b as

@------------------------------------------------------------------------------------------------------
@ Cambia la letra p por m aumenta los contadores de letras y letras cambiadas. avanza en el ciclo
@ Setea identificador de palabra modificada
@------------------------------------------------------------------------------------------------------
letraPm:
	sub r3, r3, #3
	strb r3,[r1]
	add r1, r1, #1
	add r6, r6, #1
	add r8, r8, #1
	b as

@------------------------------------------------------------------------------------------------------
@ avanza en el ciclo cuando es una letras normal
@------------------------------------------------------------------------------------------------------
letraX:
	add r1, r1, #1
	b as

@------------------------------------------------------------------------------------------------------
@ aumenta el contador de palabras, si r8 diferente de cero es una palabra modificada
@------------------------------------------------------------------------------------------------------
PalabraN:
	ldr r4, =80
	cmp r11, r4
	bge errorPalabra
	mov r11, #0
	ldrb r3, [r1, r10]
	cmp r3, r4
	beq Espacios
	add r5, r5, #1
	add r1, r1, #1
	cmp r8, #0
	bne cuentaCambios
	b as

@------------------------------------------------------------------------------------------------------
@ si hay espacios en blanco solo avanza en el ciclo
@------------------------------------------------------------------------------------------------------
Espacios:
	add r1, r1, #1
	b as

@------------------------------------------------------------------------------------------------------
@ aumenta el contador de palabras modificadas
@------------------------------------------------------------------------------------------------------
cuentaCambios:
	add r9, r9, #1
	mov r8, #0
	b as

@------------------------------------------------------------------------------------------------------
@ agrega nueva palabra si el ultimo caracter no es un espacio
@------------------------------------------------------------------------------------------------------
ChequeoUltimoCaracter:
	sub r1, r1, #1
	ldrb r3, [r1]
	ldr r4, =10
	cmp r3, r4
	beq preparacion
	add r5, r5, #1
	cmp r8, #0
	beq preparacion
	add r9, r9, #1
	b preparacion

final:
	ldr r4, =32
	cmp r3, r4
	beq Espacios
	add r5, r5, #1
	add r1, r1, #1
	b as
	

@---------------------------------------------------------------------------------
@ limpia los registros .
@---------------------------------------------------------------------------------
preparacion:

	mov r3, #0
	b preparacion2

@------------------------------------------------------------------------------------------------------
@ guarda los totales en otras variables para hacer el itoa, r10 letras cambiadas, r14 letras
@------------------------------------------------------------------------------------------------------
preparacion2: 


	mov r10, r7
	mov r14, r6
	mov r0, #0
	mov r8, #0  @r5
	mov r4, #0
	mov r2, #0
	mov r1, #0
	b Operaciones

@------------------------------------------------------------------------------------------------------
@ verifica por que operacion va el ciclo y salata a dicha operacion
@------------------------------------------------------------------------------------------------------
Operaciones:

	cmp r3, #0
	beq Modificado
	cmp r3, #1
	beq TotalPalabrasNo
	cmp r3, #2
	beq TotalLetrasNo
	cmp r3, #3
	beq TotalPalabrasConvertidas
	cmp r3, #4
	beq PorcentajePalabras
	cmp r3, #5
	beq TotalLetrasConvertidas
	cmp r3, #6
	beq PorcentajeLetras
	b imprimir

@------------------------------------------------------------------------------------------------------
@ imprime el nombre del archivo con el texto traducido
@------------------------------------------------------------------------------------------------------
Modificado:
	imprime archivomodificado, lenarchivomodificado
	imprime Archivo, lenArchivo
	add r3, r3, #1
	b Operaciones

@------------------------------------------------------------------------------------------------------
@ acomoda los registros para el itoa y lo llama para el total de palabras
@------------------------------------------------------------------------------------------------------
TotalPalabrasNo:
	imprime totalpalabras, lentotalpalabras
	mov r12, r5
	add r3, r3, #1
	b previa

@------------------------------------------------------------------------------------------------------
@ acomoda los registros para el itoa y lo llama para el total de letras
@------------------------------------------------------------------------------------------------------
TotalLetrasNo:
	imprime Totalletras, lenTotalletras
	mov r12, r10
	add r3, r3, #1
	b previa

@------------------------------------------------------------------------------------------------------
@ acomoda los registros para el itoa y lo llama para el total de palabras convertidas
@------------------------------------------------------------------------------------------------------
TotalPalabrasConvertidas:
	imprime totalPconvertidas, lentotalPconvertidas
	mov r12, r9
	add r3, r3, #1
	b previa

@------------------------------------------------------------------------------------------------------
@ Opera los totales de palabras para sacar el porcentaje de palabras convertidas
@ acomoda los registros para el itoa y lo llama para el porcentaje de palabras convertidas
@------------------------------------------------------------------------------------------------------
PorcentajePalabras:
	imprime porcentajeP, lenporcentajeP
	mov r4, #100
	mul r12, r9, r4
	sdiv r12, r12, r5
	add r3, r3, #1
	b previa

@------------------------------------------------------------------------------------------------------
@ acomoda los registros para el itoa y lo llama para el total de letras convertidas
@------------------------------------------------------------------------------------------------------
TotalLetrasConvertidas:
	imprime totalLcambiadas, lentotalLcambiadas
	mov r12, r14
	add r3, r3, #1
	b previa

@------------------------------------------------------------------------------------------------------
@ Opera los totales de palabras para sacar el porcentaje de letras convertidas
@ acomoda los registros para el itoa y lo llama para el porcentaje de letras convertidas
@------------------------------------------------------------------------------------------------------
PorcentajeLetras:
	imprime porcentajeL, lenporcentajeL
	mov r4, #100
	mul r12, r14, r4
	sdiv r12, r12, r10
	add r3, r3, #1
	b previa

	
@---------------------------------------------------------------------------------
@ funciones para formar un Inteeger to Ascii.
@ r4 utiliza como puntero para escribir los caracteres en la varibale resultado.
@ r5 tiene el resultado de la suma. r7 tiene el exponente de cada ciclo. r0 tiene la base 10.
@ r11 va a ser el contador para encontrar el digito mas significativo.
@---------------------------------------------------------------------------------
previa:
    mov r4, #0
    ldr r4, =resultado    
    mov r8, r12    
    mov r7, #9
    mov r11, #0 

@---------------------------------------------------------------------------------
@ Cargar la base y el exponente, verificando que no sea exponente 0
@---------------------------------------------------------------------------------
potenciaMenor:
    mov r0, #10    
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
    cmp r6, r8           
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
    cmp r8, r6          
    blt escribir           
    add r11, r11, #1      
    sub r8, r8, r6      
    b digito 

@---------------------------------------------------------------------------------
@ Buscar en la lookup table el caracter correspondiente al digito y  guardarlo en la variable resultadoSuma.
@ r4 tiene la posicion donde debemos escribir el caracter. r11 el caracter que debemos escribir.
@ si el exponente es cero vamos a imprimir el resultado sino hacemos el proceso de crear una potencia de diez.
@---------------------------------------------------------------------------------
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
@ imprime la variable resultado.
@--------------------------------------------------------------------------------- 
finalItoa: 
    mov r11, #'\n'
    strb r11, [r4]
	
    mov r7, #4          
    mov r0, #1          
    ldr r1, =resultado      
    mov r2, #35         
    swi 0
    b Operaciones

@------------------------------------------------------------------------------------------------------
@ Abre el archivo en modo escritura y escribe el texto traducido
@------------------------------------------------------------------------------------------------------
imprimir: 

	mov r3, #0
	pop {r3}
	mov r7, #5
	ldr r0, =nombreArchivo
	mov r1, #0101
	mov r2, #0644
	svc 0
	push {r0}
	cpy r4, r0
	
	mov r7, #4
	cpy r0, r4
	ldr r1, =mensaje
	cpy r2, r3
	svc 0
	
	pop {r0}
	mov r7, #6
	svc 0
	
	b salir

errorArchivo:
	imprime c, lenc
	b salir	
errorArchivoL:
	imprime d, lend
	b salir
error:
	imprime b, lenb
	b salir
errorEnt:
	imprime e, lene
	b salir
errorPalabra:
imprime f, lenf
b salir
salir:    @fin del programa
    mov r7, #1
    mov r0, #0
    swi 0
