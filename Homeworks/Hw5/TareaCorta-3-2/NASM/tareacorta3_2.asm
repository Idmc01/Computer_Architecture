%macro salida 2
    mov edx, %1     ;EDX=lon. de la cadena
    mov ecx, %2      ;ECX=cadena a imprimir
    mov ebx, 1            ;EBX=manejador de fichero (STDOUT)
    mov eax, 4            ;EAX=funcion sys_write() del kernel
    int 0x80              ;interrupc. 80 (llamada al kernel)
    %endmacro
section .data               ;Solo se utilizo para los mensajes por imprimir en la terminal 
    mensaje     db "Que operacion desea Realizar: ", 0xA
    longitud    equ $ - mensaje

    mensaje2     db "1. Suma.", 0xA
    longitud2    equ $ - mensaje2

    mensaje3     db "2. Resta", 0xA
    longitud3    equ $ - mensaje3

    mensaje4     db "3. Multiplicacion.", 0xA
    longitud4    equ $ - mensaje4

    mensaje5     db "4. Division.", 0xA
    longitud5    equ $ - mensaje5

    primerOperando db "Digite el primer operando: ", 0xA
    lenOperando     equ $ - primerOperando

    SegOperando db "Digite el segundo operando: ", 0xA
    lenOperando2     equ $ - SegOperando

    mensajeS     db "Binario: ", 0xA
    longitudS    equ $ - mensajeS

    mensajeD db "Octal: ", 0xA
    longitudD    equ $ - mensajeD

    mensajeH db "Hexadecimal: ", 0xA
    longitudH    equ $ - mensajeH

    mensajeF db "Decimal: ", 0xA
    longitudF    equ $ - mensajeF

    mensajeError db "Entrada invalida, por favor intentelo otra vez.", 0xA
    longitudError    equ $ - mensajeError

    mensajeErrorO db "Digite un numero de operacion valido.", 0xA
    longitudErrorO    equ $ - mensajeErrorO

    salto db 0xA, 0xD
    saltolen equ $-salto

    tble db "0123456789ABCDEF", 0xA
   

section .bss
    operacion resb 2            ;espacio reservado para saber que operacion es
    cadena1 resb 21                 ;Espacio reservado para las entradas
    resultadoBinario resb 100            ;Espacio reservado para la transformacion de las entradas
    resultadoOctal resb 100
    resultadoHexadecimal resb 50
    resultadoDecimal resb 50
    cadena2 resb 21
    resultadoResta resb 50  
    respuesta resb 21                ;Espacio reservado para la respuesta del usuario

section .text    

    ;imprime el mensaje de error y vuelve a preguntar por la entrada del usuario
    _error:
        salida longitudError, mensajeError
        call _inicio

    _errorOperacion:
        salida longitudErrorO, mensajeErrorO
        call _inicio

    _chequeo:
        cmp byte[rbx], 0xA
        jne _chequeo1
        ret

    _chequeo1:
        cmp byte[rbx], 49
        jne _chequeo2
        mov r13, 1h
        inc rbx
        jmp _chequeo

    _chequeo2:
        cmp byte[rbx], 50
        jne _chequeo3
        mov r13, 2h
        inc rbx
        jmp _chequeo

    _chequeo3:
        cmp byte[rbx], 51
        jne _chequeo4
        mov r13, 3h
        inc rbx
        jmp _chequeo

    _chequeo4:
        cmp byte[rbx], 52
        jne _errorOperacion
        mov r13, 4h
        inc rbx
        jmp _chequeo
        

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
    

    _Binario:
        xor rcx, rcx
        xor r11, r11
        xor r10, r10
        xor rax, rax
        mov r11, 19
        mov rax, rbx
        mov rcx, 2
        jmp _conversionB

        _conversionB:
            xor rdx, rdx
               
            div rcx 	;rax/rcx
            mov r10b, byte[tble+rdx]
            mov byte[resultadoBinario+r11], r10b   ;guardamos el resultado
            dec r11     ; de atras ara adelante para que se imprima bien
            cmp rax, 0  ;si llegamos a 0, no hay nada mas que dividir
            je _imprimirresultadoB
                        
            jmp _conversionB

    _imprimirresultadoB:
        call _imprimeSalto
        xor r12, r12
        mov r12, rbx
        salida longitudS, mensajeS
        xor rbx, rbx
        mov rbx, r12

        xor rax, rax
	    mov rax, 1
	    mov rdi, 1
	    mov rsi, resultadoBinario 
	    mov rdx, 20
	    syscall
        
        call _Octal

    _Octal:
        xor rcx, rcx
        xor r11, r11
        xor r10, r10
        xor rax, rax
        mov r11, 19
        mov rax, rbx
        mov rcx, 8
        jmp _conversionO

        _conversionO:
            xor rdx, rdx
               
            div rcx 	;rax/rcx
            mov r10b, byte[tble+rdx]
            mov byte[resultadoOctal+r11], r10b   ;guardamos el resultado
            dec r11     ; de atras ara adelante para que se imprima bien
            cmp rax, 0  ;si llegamos a 0, no hay nada mas que dividir
            je _imprimirresultadoO
                        
            jmp _conversionO

    _imprimirresultadoO:
        call _imprimeSalto
        salida longitudD, mensajeD
        xor rbx, rbx
        mov rbx, r12

        xor rax, rax
	    mov rax, 1
	    mov rdi, 1
	    mov rsi, resultadoOctal
	    mov rdx, 20
	    syscall
        
        call _Hexadecimal

    _Hexadecimal:
        xor rcx, rcx
        xor r11, r11
        xor r10, r10
        xor rax, rax
        mov r11, 19
        mov rax, rbx
        mov rcx, 16
        jmp _conversionH

        _conversionH:
            xor rdx, rdx
               
            div rcx 	;rax/rcx
            mov r10b, byte[tble+rdx]
            mov byte[resultadoHexadecimal+r11], r10b   ;guardamos el resultado
            dec r11     ; de atras ara adelante para que se imprima bien
            cmp rax, 0  ;si llegamos a 0, no hay nada mas que dividir
            je _imprimirresultadoH
                        
            jmp _conversionH

    _imprimirresultadoH:
        call _imprimeSalto
        salida longitudH, mensajeH
        xor rbx, rbx
        mov rbx, r12

        xor rax, rax
	    mov rax, 1
	    mov rdi, 1
	    mov rsi, resultadoHexadecimal 
	    mov rdx, 20
	    syscall
        
        call _Decimal


    _Decimal:
        xor rcx, rcx
        xor r11, r11
        xor r10, r10
        xor rax, rax
        mov r11, 19
        mov rax, rbx
        mov rcx, 10
        jmp _conversionD

        _conversionD:
            xor rdx, rdx
               
            div rcx 	;rax/rcx
            mov r10b, byte[tble+rdx]
            mov byte[resultadoDecimal+r11], r10b   ;guardamos el resultado
            dec r11     ; de atras ara adelante para que se imprima bien
            cmp rax, 0  ;si llegamos a 0, no hay nada mas que dividir
            je _imprimirresultadoD
                        
            jmp _conversionD

    _imprimirresultadoD:
        call _imprimeSalto
        salida longitudF, mensajeF
        xor rbx, rbx
        mov rbx, r12

        xor rax, rax
	    mov rax, 1
	    mov rdi, 1
	    mov rsi, resultadoDecimal
	    mov rdx, 20
	    syscall
        
        call _salir

    
             
    global _start          ;definimos el punto de entrada
_start:

      _inicio:
      salida longitud, mensaje      ; Imprime primer mensaje
      call _imprimeSalto
      salida longitud2, mensaje2      ; Imprime primer mensaje
      salida longitud3, mensaje3      ; Imprime primer mensaje
      salida longitud4, mensaje4      ; Imprime primer mensaje
      salida longitud5, mensaje5      ; Imprime primer mensaje

      mov eax, 3
      mov ebx, 2
      mov rcx, operacion              ; recibe la operacion por realizar
      mov edx, 21
      int 0x80

      mov rbx, operacion
      xor r13, r13
      call _chequeo

      _Proceso:
        call _imprimeSalto
        salida lenOperando, primerOperando

        mov eax, 3
        mov ebx, 2
        mov rcx, cadena1              ; recibe el primer operando
        mov edx, 21
        int 0x80

        mov rbx, cadena1
        call _extremoIzquierdo        ;chequea que el primero sea entero

        salida lenOperando2, SegOperando

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
	        je _saltos

	        sub r11, '0' ;convirtiendolo a numero
	        imul rcx, 10 
	        add rcx, r11
	        inc r10
	        jmp .next


        _saltos:
            cmp r13, 1h                   ;verifica si el usuario escogio suma
            je _Suma
            cmp r13, 2h                   ;verifica si el usuario escogio resta
            je _Resta
            cmp r13, 3h                   ;verifica si el usuario escogio Multiplicacion
            je _Multiplicacion            
            cmp r13, 4h                   ;verifica si el usuario escogio Division
            je _Division

      _Suma:
        add rbx, rcx        ; la suma queda en rbx
        call _imprimeSalto
        
        call _Binario

      _Resta:
        sub rbx, rcx
        call _imprimeSalto

        call _Binario

      _Multiplicacion:
        mov rax, rcx
        mul rbx
        xor rbx, rbx
        mov rbx, rax

        call _imprimeSalto
        call _Binario

      _Division:
        cmp rbx, rcx
        jl _primeroMenor
        ;mov rax, rbx
        ;div rbx
        mov rdx, 0
        mov rax, rbx
        div rcx
        mov rbx, rax
        call _imprimeSalto
        call _Binario

        _primeroMenor:
        
        call _imprimeSalto
        call _Binario

     _salir:
        call _imprimeSalto
	    mov rax, 60
	    mov rdi, 0
	    syscall	
