%macro salida 2
    mov edx, %1     ;EDX=lon. de la cadena
    mov ecx, %2      ;ECX=cadena a imprimir
    mov ebx, 1            ;EBX=manejador de fichero (STDOUT)
    mov eax, 4            ;EAX=funcion sys_write() del kernel
    int 0x80              ;interrupc. 80 (llamada al kernel)
    %endmacro
section .data               ;Solo se utilizo para los mensajes por imprimir en la terminal 
    mensaje     db "Digite el primer numero: ", 0xA
    longitud    equ $ - mensaje

    mensaje2     db "Digite el segundo numero: ", 0xA
    longitud2    equ $ - mensaje2

    mensajeS     db "Suma en bases numericas de la 16 a base 2: ", 0xA
    longitudS    equ $ - mensajeS

    mensajeD db "Diferencia en bases numericas de la 16 a base 2: ", 0xA
    longitudD    equ $ - mensajeD

    mensajeError db "Entrada invalida, por favor intentelo otra vez.", 0xA
    longitudError    equ $ - mensajeError

    salto db 0xA, 0xD
    saltolen equ $-salto

    tble db "0123456789ABCDEF", 0xA
   

section .bss
    cadena1 resb 21                 ;Espacio reservado para las entradas
    resultadoSuma resb 50            ;Espacio reservado para la transformacion de las entradas
    cadena2 resb 21
    resultadoResta resb 50  
    respuesta resb 21                ;Espacio reservado para la respuesta del usuario

section .text    

    ;imprime el mensaje de error y vuelve a preguntar por la entrada del usuario
    _error:
        salida longitudError, mensajeError
        call _inicio

    ;proceso para verificar si es un entero    
    _ciclo:
        cmp byte[rbx], 0xA
        jne _extremoIzquierdo
        ret
    _fin:
        mov ebx, 0            ;EBX=codigo de salida al SO
        mov eax, 1            ;EAX=funcion sys_exit() del kernel
        int 0x80              ;interrupc. 80 (llamada al kernel)  

    ;checkea que el valor ascii no sea menor que el del cero
    _extremoIzquierdo:
        cmp byte[rbx], 48
        jl _error       ; si es menor da error
        jge _extremoDerecho

    ;chequea que el valor asciii de la entrada no sea mayor al del 9
    _extremoDerecho:
        cmp byte[rbx], 57
        jg _error       ; si es mayor da error
        inc rbx         ; avanzamos al siguiente caracter
        jmp _ciclo

    ;imprime un salto de linea en la terminal
    _imprimeSalto:
        mov rax, 1
	    mov rdi, 1
	    mov rsi, salto
	    mov rdx, saltolen
	    syscall
        ret

    ;imprime el mensaje de la suma
    _imprimeMensajeS:
        call _imprimeSalto

        mov rax, 1
	    mov rdi, 1
	    mov rsi, mensajeS
	    mov rdx, longitudS
	    syscall
        ret

    ;imprime el mensaje de la diferencia
    _imprimeMensajeR:
        call _imprimeSalto

        mov rax, 1
	    mov rdi, 1
	    mov rsi, mensajeD
	    mov rdx, longitudD
	    syscall
        ret
    
             
    global _start          ;definimos el punto de entrada
_start:

      _inicio:
      salida longitud, mensaje      ; Imprime primer mensaje

      mov eax, 3
      mov ebx, 2
      mov rcx, cadena1              ; recibe el primer operando
      mov edx, 21
      int 0x80

      mov rbx, cadena1
      call _extremoIzquierdo        ;chequea que el primero sea entero

      salida longitud2, mensaje2      ; Imprime segundo mensaje

      mov eax, 3
      mov ebx, 2
      mov rcx, cadena2              ; recibe el segundo operando
      mov edx, 101
      int 0x80

      mov rbx, cadena2
      call _extremoIzquierdo        ;chequea que el segundo sea entero

      _atoi:     ;ascii to integer
	    xor r10, r10  ;para iterar por el input
	    xor rbx, rbx ; vamos a guardar el numero
	    xor r11, r11 ;aqui vamos a hacer operaciones
	    mov r10, cadena1 ;movimos el input a r10
      .next:
	    movzx r11, byte[r10]
	    cmp r11, 0xA ;para saber si ya terminamos
	    je _atoi2

	    sub r11, '0' ;convirtiendolo a numero
	    imul rbx, 10 
	    add rbx, r11 
	    inc r10
	    jmp .next

    _atoi2:     ;ascii to integer
	    xor r10, r10  ;para iterar por el input
	    xor rcx, rcx ; vamos a guardar el numero
	    xor r11, r11 ;aqui vamos a hacer operaciones
	    mov r10, cadena2 ;movimos el input a r10
     .next:
	    movzx r11, byte[r10]
	    cmp r11, 0xA ;para saber si ya terminamos
	    je _sumar

	    sub r11, '0' ;convirtiendolo a numero
	    imul rcx, 10 
	    add rcx, r11
	    inc r10
	    jmp .next

      _sumar:
        xor r12, r12
        mov r12, 17         ; con esto recorremos las bases numericas de la 16 a la base 2 para la suma
        xor r13, r13
        mov r13, 17         ;; con esto recorremos las bases numericas de la 16 a la base 2 para la diferencia
        xor r8, r8          
        xor r9, r9
        mov r8, rcx
        mov r9, rbx
        add rbx, rcx        ; La suma queda en rbx
        call _imprimeMensajeS
        jmp _itoa           ;llama al ciclo para procesar las sumas

        ; compara las entradas para ver cual es mayor
      _resta:
        call _imprimeSalto
        call _imprimeMensajeR
        xor rbx, rbx
        cmp r8, r9
        jle _resta2     ; si la almacenada en r8 en menor o igual va a ir a la otra funcion

        sub r8, r9      ; la diferencia queda en r8 si esta es mayor para que sea positiva
        mov rbx, r8     ;se la pasamos A rbx para que se pueda procesar en el ciclo
        jmp _itoaResta  ; llama al ciclo para convertir la diferencia a otras bases

      _resta2:
        sub r9, r8      ;la diferencia queda guardada en r9 porque es amyor
        mov rbx, r9 ;se la pasamos A rbx para que se pueda procesar en el ciclo
        jmp _itoaResta


      _itoa:   ;integer to ascii de todas las bases
        xor rax, rax
	    xor rcx, rcx ;vamos a poner el divisor
	    xor rdx, rdx ;aqui vamos a guardar el residuo
	    xor r10, r10 ;movimientos
	    xor r11, r11 ;iterar por 2da variable
        mov r11, 19   ; va del 19 al o para que el numero no salga al reves
        jmp _todasLasBases

        ; primer ciclo para iteral sobre las bases numericas
      _todasLasBases:

    	mov rax, rbx
        mov rcx, r12
        dec rcx         ; rcx lleva la base por la que va el ciclo
        mov r12, rcx    ;guardamos por donde va la iteracion
        cmp rcx, 2      ; cuando lleguemos a la base dos frenamos
        jl _resta

        jmp _conversion

        ; ciclo interno que itera sobre el numero para pasarlo a su respectiva bse
        _conversion:
            xor rdx, rdx
               
            div rcx 	;rax/rcx
            mov r10b, byte[tble+rdx]
            mov byte[resultadoSuma+r11], r10b   ;guardamos el resultado
            dec r11     ; de atras ara adelante para que se imprima bien
            cmp rax, 0  ;si llegamos a 0, no hay nada mas que dividir
            je _imprimirresultado
            
            jmp _conversion

        ;preparamos todas la variables que se van a utilixzar en el proceso de itoa y de conversiones
      _itoaResta:
        xor rax, rax
        xor rcx, rcx ;lleva la base por la que va el ciclo
        xor rdx, rdx
        xor r10, r10  ; movimientos en la look up table
        xor r11, r11 ;iterar sobre los numeros
        mov r11, 19 ; de 19 a 20 para que el numero se imprima bien
       
        jmp _todasLasBasesResta

      _todasLasBasesResta:
        mov rax, rbx ;rax tiene el numero en base diez 
        mov rcx, r13  ; alimentamos por donde va el contador
        dec rcx
        mov r13, rcx  ;guardamos el contador para la siguiente operacion
        cmp rcx, 2      ;cuando lleg a la ue=ltima base termian el programa
        jl _salir

        jmp _conversionResta

        ;ciclo interno para convertir e imorimir cada numero en su base
        _conversionResta:
            xor rdx, rdx
               
            div rcx 	;rax/rcx
            mov r10b, byte[tble+rdx]
            mov byte[resultadoResta+r11], r10b
            dec r11
            cmp rax, 0  ;si llegamos a 0, no hay nada mas que dividir
            je _imprimirresultadoResta
            
            jmp _conversionResta

        ; imprime el resultado de la suma en las bases y vuelve a llamar al ciclo
      _imprimirresultado:
        call _imprimeSalto
        call _imprimeSalto
        xor rax, rax
	    mov rax, 1
	    mov rdi, 1
	    mov rsi, resultadoSuma 
	    mov rdx, 20
	    syscall

        call _itoa      ;llama al ciclo para ir por la sigueinte base

        ; Imprime el resultado de la diferencia en las diferentes bases
     _imprimirresultadoResta:
        call _imprimeSalto
        call _imprimeSalto
        xor rax, rax
	    mov rax, 1
	    mov rdi, 1
	    mov rsi, resultadoResta
	    mov rdx, 20
	    syscall

        call _itoaResta     ; llama al ciclo para ir or la siguente conversiom

    ;proceso para terminar el programa
    _salir:
        call _imprimeSalto
	    mov rax, 60
	    mov rdi, 0
	    syscall	