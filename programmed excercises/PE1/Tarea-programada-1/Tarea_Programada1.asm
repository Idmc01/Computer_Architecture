%macro salida 2
    mov edx, %1     ;EDX=lon. de la cadena
    mov ecx, %2      ;ECX=cadena a imprimir
    mov ebx, 1            ;EBX=manejador de fichero (STDOUT)
    mov eax, 4            ;EAX=funcion sys_write() del kernel
    int 0x80              ;interrupc. 80 (llamada al kernel)
    %endmacro 

section .data
    mensajeA     db "Ecuacion: ", 0xA
    longitudA    equ $ - mensajeA

    mensaje     db "Resultado: ", 0xA
    longitud    equ $ - mensaje

    mensajeErrorO db "La ecuacion supera la cantidad maxima de 1024 caracteres.", 0xA
    longitudErrorO    equ $ - mensajeErrorO

    mensajeErrorA db "No se reconocio la ecuacion como una valida.", 0xA
    longitudErrorA    equ $ - mensajeErrorA

    mensajeErrorV db "Supera el limite de diez variables.", 0xA
    longitudErrorV    equ $ - mensajeErrorV

    salto db 0xA, 0xD
    saltolen equ $-salto


    tble db "0123456789ABCDEF", 0xA


section .bss

    Contenido resb 1026
    Ecuacion resb 1026
    Numero resb 1026
    Operando1 resb 10
    Operando2 resb 10
    palabras resb 20
    Variable resb 2
    Variable1 resb 2
    Variable2 resb 2
    Variable3 resb 2
    Variable4 resb 2
    Variable5 resb 2
    Variable6 resb 2
    Variable7 resb 2
    Variable8 resb 2
    Variable9 resb 2
    Valor resb 10
    Valor1 resb 10
    Valor2 resb 10
    Valor3 resb 10
    Valor4 resb 10
    Valor5 resb 10
    Valor6 resb 10
    Valor7 resb 10
    Valor8 resb 10
    Valor9 resb 10
    
section .text

    _salir:
        call _imprimeSalto

	    mov rax, 60
	    mov rdi, 0
	    syscall	

    _error:                 ;Imprime mensaje de error cuando sobre pase los caracteres  
        mov rax, 1
	    mov rdi, 1
	    mov rsi, mensajeErrorO
	    mov rdx, longitudErrorO
	    syscall
        call _salir

    _error2:                 ;Imprime mensaje de error cuando sobre pase los caracteres  
        mov rax, 1
	    mov rdi, 1
	    mov rsi, mensajeErrorA
	    mov rdx, longitudErrorA
	    syscall
        call _salir

    
    _error3:                 ;Imprime mensaje de error cuando sobre pase los caracteres  
        mov rax, 1
	    mov rdi, 1
	    mov rsi, mensajeErrorV
	    mov rdx, longitudErrorV
	    syscall
        call _salir


    _chequeoCaracteres:         ;chequea que no se haya pasado de las 1024 caracteres
        cmp rbx, 2048
        jle _previa
        call _error

     _imprimeSalto:             ; imprime un salto de linea
        mov rax, 1
	    mov rdi, 1
	    mov rsi, salto
	    mov rdx, saltolen
	    syscall
        ret
    
    global _start

_start:

    salida longitudA, mensajeA  
    xor r9, r9
    ;------------------------------------------------------------------------------------------------------
    ;Recibir la ecuacion 
    ;------------------------------------------------------------------------------------------------------
    _entrada:

        xor r10, r10
        mov [Contenido], r10

        mov eax, 3
        mov ebx, 2
        mov rcx, Contenido              ; recibe la ecuacion
        mov edx, 1026
        int 0x80
        xor rbx, rbx
        jmp _entrada2

    ;------------------------------------------------------------------------------------------------------
    ;Ciclo por si el usuario digita enters, seguir pidiendo la ecuacion hasta encontrar una coma
    ;------------------------------------------------------------------------------------------------------
    _entrada2:

        mov r8b, byte[Contenido+rbx]
        cmp r8b, 0xA
        je _entrada
        mov byte[Ecuacion+r9], r8b
        cmp r8b, 2Ch
        je _cantidad
        inc rbx
        inc r9
        jmp _entrada2


    ;------------------------------------------------------------------------------------------------------
    ; Verifica que la ecuacion no sea nula y que esta no supere los 1024 caracteres
    ;------------------------------------------------------------------------------------------------------
    _cantidad:
        mov ah, byte[Ecuacion+1]
        cmp ah, 0x0
        je _error2
        mov ah, byte[Ecuacion+1026]
        je _error
        jmp _Variables


    ;------------------------------------------------------------------------------------------------------
    ;hace una llamada a sistema para recibir las variables
    ;------------------------------------------------------------------------------------------------------
    _Variables:
        xor r10, r10
        mov [Contenido], r10

        mov eax, 3
        mov ebx, 2
        mov rcx, Contenido              ; recibe las variables
        mov edx, 1026
        int 0x80
        xor rbx, rbx
        mov rbx, 0
        jmp _guardar


    ;------------------------------------------------------------------------------------------------------
    ; ciclo para leer y guardar los valores de las variables
    ; el puntero hacia la entrada lo va a llevar rbx
    ;------------------------------------------------------------------------------------------------------
    _guardar:
        mov r8b, byte[Contenido+rbx]
        cmp r8b, 0xA
        je _previa
        cmp rbx, 0
        je _etiqueta
        ;cmp r8b, 2Ch
        ;je _Variables
        ;inc rdx
        jmp _guardar

    ;------------------------------------------------------------------------------------------------------
    ; Guarda la letra en la primera variable, sino va a la segunda
    ;------------------------------------------------------------------------------------------------------
    _etiqueta:

        cmp r8b, 0xA
        je _previa

        cmp byte[Variable+0], 0
        jg _etiqueta1

        mov byte[Variable], r8b
        inc rbx
        jmp _valor

    ;------------------------------------------------------------------------------------------------------
    ; Guarda la letra de la segunda variable, si el registro ya almacena una variable pasa a la siguiente
    ;------------------------------------------------------------------------------------------------------
    _etiqueta1:
        cmp byte[Variable1], 0
        jg _etiqueta2

        mov byte[Variable1], r8b
        inc rbx
        jmp _valor1

    ;------------------------------------------------------------------------------------------------------
    ; Guarda la letra de la tercera variable, si el registro ya almacena una variable pasa a la siguiente
    ;------------------------------------------------------------------------------------------------------
    _etiqueta2:
        cmp byte[Variable2], 0
        jg _etiqueta3

        mov byte[Variable2], r8b
        inc rbx
        jmp _valor2

    ;------------------------------------------------------------------------------------------------------
    ; Guarda la letra de la cuarta variable, si el registro ya almacena una variable pasa a la siguiente
    ;------------------------------------------------------------------------------------------------------
    _etiqueta3:
        cmp byte[Variable3], 0
        jg _etiqueta4

        mov byte[Variable3], r8b
        inc rbx
        jmp _valor3

    ;------------------------------------------------------------------------------------------------------
    ; Guarda la letra de la quinta variable, si el registro ya almacena una variable pasa a la siguiente
    ;------------------------------------------------------------------------------------------------------
    _etiqueta4:
        cmp byte[Variable4], 0
        jg _etiqueta5

        mov byte[Variable4], r8b
        inc rbx
        jmp _valor4

    ;------------------------------------------------------------------------------------------------------
    ; Guarda la letra de la sexta variable, si el registro ya almacena una variable pasa a la siguiente
    ;------------------------------------------------------------------------------------------------------
    _etiqueta5:
        cmp byte[Variable5], 0
        jg _etiqueta6

        mov byte[Variable5], r8b
        inc rbx
        jmp _valor5

    ;------------------------------------------------------------------------------------------------------
    ; Guarda la letra de la setima variable, si el registro ya almacena una variable pasa a la siguiente
    ;------------------------------------------------------------------------------------------------------
    _etiqueta6:
        cmp byte[Variable6], 0
        jg _etiqueta7

        mov byte[Variable6], r8b
        inc rbx
        jmp _valor6

    ;------------------------------------------------------------------------------------------------------
    ; Guarda la letra de la octava variable, si el registro ya almacena una variable pasa a la siguiente
    ;------------------------------------------------------------------------------------------------------
    _etiqueta7:
        cmp byte[Variable7], 0
        jg _etiqueta8

        mov byte[Variable7], r8b
        inc rbx
        jmp _valor7

    ;------------------------------------------------------------------------------------------------------
    ; Guarda la letra de la novena variable, si el registro ya almacena una variable pasa a la siguiente
    ;------------------------------------------------------------------------------------------------------
    _etiqueta8:
        cmp byte[Variable8], 0
        jg _etiqueta9

        mov byte[Variable8], r8b
        inc rbx
        jmp _valor8


    ;------------------------------------------------------------------------------------------------------
    ; Guarda la letra de la decima variable, si el registro ya almacena una variable da error
    ;------------------------------------------------------------------------------------------------------
    _etiqueta9:
        cmp byte[Variable9], 0
        jg _error3

        mov byte[Variable9], r8b
        inc rbx
        jmp _valor9


    ;------------------------------------------------------------------------------------------------------
    ; Ciclo para encontrar el valor numerico de la primera variable, el contador lo sigue llevando rbx
    ;------------------------------------------------------------------------------------------------------
    _valor:
        mov r8b, byte[Contenido+rbx]
        cmp r8b, 2Fh
        jg _atoi
        inc rbx
        jmp _valor

    _atoi:
        mov r8b, byte[Contenido+rbx]
        cmp r8b, 2Ch
        je _Insertar
        cmp r8b, 0xA
        je _previa
        sub r8b, 30h
        imul r11, 10
        add r11, r8
        inc rbx
        jmp _atoi


    ;------------------------------------------------------------------------------------------------------
    ; Ciclo para encontrar el valor numerico de la segunda variable, el contador lo sigue llevando rbx
    ;------------------------------------------------------------------------------------------------------
    _valor1:
        mov r8b, byte[Contenido+rbx]
        cmp r8b, 2Fh
        jg _atoi1
        inc rbx
        jmp _valor1

    _atoi1:
        mov r8b, byte[Contenido+rbx]
        cmp r8b, 2Ch
        je _Insertar1
        cmp r8b, 0xA
        je _previa
        sub r8b, 30h
        imul r11, 10
        add r11, r8
        inc rbx
        jmp _atoi1

    ;------------------------------------------------------------------------------------------------------
    ; Ciclo para encontrar el valor numerico de la tercera variable, el contador lo sigue llevando rbx
    ;------------------------------------------------------------------------------------------------------
    _valor2:
        mov r8b, byte[Contenido+rbx]
        cmp r8b, 2Fh
        jg _atoi2
        inc rbx
        jmp _valor2

    _atoi2:
        mov r8b, byte[Contenido+rbx]
        cmp r8b, 2Ch
        je _Insertar2
        cmp r8b, 0xA
        je _previa
        sub r8b, 30h
        imul r11, 10
        add r11, r8
        inc rbx
        jmp _atoi2


    ;------------------------------------------------------------------------------------------------------
    ; Ciclo para encontrar el valor numerico de la cuarta variable, el contador lo sigue llevando rbx
    ;------------------------------------------------------------------------------------------------------
    _valor3:
        mov r8b, byte[Contenido+rbx]
        cmp r8b, 2Fh
        jg _atoi3
        inc rbx
        jmp _valor3

    _atoi3:
        mov r8b, byte[Contenido+rbx]
        cmp r8b, 2Ch
        je _Insertar3
        cmp r8b, 0xA
        je _previa
        sub r8b, 30h
        imul r11, 10
        add r11, r8
        inc rbx
        jmp _atoi3


    ;------------------------------------------------------------------------------------------------------
    ; Ciclo para encontrar el valor numerico de la quinta variable, el contador lo sigue llevando rbx
    ;------------------------------------------------------------------------------------------------------
    _valor4:
        mov r8b, byte[Contenido+rbx]
        cmp r8b, 2Fh
        jg _atoi4
        inc rbx
        jmp _valor4

    _atoi4:
        mov r8b, byte[Contenido+rbx]
        cmp r8b, 2Ch
        je _Insertar4
        cmp r8b, 0xA
        je _previa
        sub r8b, 30h
        imul r11, 10
        add r11, r8
        inc rbx
        jmp _atoi4


    ;------------------------------------------------------------------------------------------------------
    ; Ciclo para encontrar el valor numerico de la sexta variable, el contador lo sigue llevando rbx
    ;------------------------------------------------------------------------------------------------------
    _valor5:
        mov r8b, byte[Contenido+rbx]
        cmp r8b, 2Fh
        jg _atoi5
        inc rbx
        jmp _valor5

    _atoi5:
        mov r8b, byte[Contenido+rbx]
        cmp r8b, 2Ch
        je _Insertar5
        cmp r8b, 0xA
        je _previa
        sub r8b, 30h
        imul r11, 10
        add r11, r8
        inc rbx
        jmp _atoi5


    ;------------------------------------------------------------------------------------------------------
    ; Ciclo para encontrar el valor numerico de la setima variable, el contador lo sigue llevando rbx
    ;------------------------------------------------------------------------------------------------------
    _valor6:
        mov r8b, byte[Contenido+rbx]
        cmp r8b, 2Fh
        jg _atoi6
        inc rbx
        jmp _valor6

    _atoi6:
        mov r8b, byte[Contenido+rbx]
        cmp r8b, 2Ch
        je _Insertar6
        cmp r8b, 0xA
        je _previa
        sub r8b, 30h
        imul r11, 10
        add r11, r8
        inc rbx
        jmp _atoi6


    ;------------------------------------------------------------------------------------------------------
    ; Ciclo para encontrar el valor numerico de la octava variable, el contador lo sigue llevando rbx
    ;------------------------------------------------------------------------------------------------------
    _valor7:
        mov r8b, byte[Contenido+rbx]
        cmp r8b, 2Fh
        jg _atoi7
        inc rbx
        jmp _valor7

    _atoi7:
        mov r8b, byte[Contenido+rbx]
        cmp r8b, 2Ch
        je _Insertar7
        cmp r8b, 0xA
        je _previa
        sub r8b, 30h
        imul r11, 10
        add r11, r8
        inc rbx
        jmp _atoi7


    ;------------------------------------------------------------------------------------------------------
    ; Ciclo para encontrar el valor numerico de la novena variable, el contador lo sigue llevando rbx
    ;------------------------------------------------------------------------------------------------------
    _valor8:
        mov r8b, byte[Contenido+rbx]
        cmp r8b, 2Fh
        jg _atoi8
        inc rbx
        jmp _valor8

    _atoi8:
        mov r8b, byte[Contenido+rbx]
        cmp r8b, 2Ch
        je _Insertar8
        cmp r8b, 0xA
        je _previa
        sub r8b, 30h
        imul r11, 10
        add r11, r8
        inc rbx
        jmp _atoi8


    ;------------------------------------------------------------------------------------------------------
    ; Ciclo para encontrar el valor numerico de la decima variable, el contador lo sigue llevando rbx
    ;------------------------------------------------------------------------------------------------------
    _valor9:
        mov r8b, byte[Contenido+rbx]
        cmp r8b, 2Fh
        jg _atoi9
        inc rbx
        jmp _valor9

    _atoi9:
        mov r8b, byte[Contenido+rbx]
        cmp r8b, 2Ch
        je _Insertar9
        cmp r8b, 0xA
        je _previa
        sub r8b, 30h
        imul r11, 10
        add r11, r8
        inc rbx
        jmp _atoi9


    ;------------------------------------------------------------------------------------------------------
    ; Realiza un atoi al valor de la primera variable y guarda el resultado
    ;------------------------------------------------------------------------------------------------------
    _Insertar:
        mov [Valor], r11
        xor rbx, rbx
        xor r11, r11
        xor r8, r8

        jmp _Variables


    ;------------------------------------------------------------------------------------------------------
    ; Realiza un atoi al valor de la primera variable y guarda el resultado
    ;------------------------------------------------------------------------------------------------------
    _Insertar1:
        mov [Valor1], r11
        xor rbx, rbx
        xor r11, r11
        xor r8, r8

        jmp _Variables


    ;------------------------------------------------------------------------------------------------------
    ; Realiza un atoi al valor de la primera variable y guarda el resultado
    ;------------------------------------------------------------------------------------------------------
    _Insertar2:
        mov [Valor2], r11
        xor rbx, rbx
        xor r11, r11
        xor r8, r8

        jmp _Variables


;------------------------------------------------------------------------------------------------------
    ; Realiza un atoi al valor de la primera variable y guarda el resultado
    ;------------------------------------------------------------------------------------------------------
    _Insertar3:
        mov [Valor3], r11
        xor rbx, rbx
        xor r11, r11
        xor r8, r8

        jmp _Variables


    ;------------------------------------------------------------------------------------------------------
    ; Realiza un atoi al valor de la primera variable y guarda el resultado
    ;------------------------------------------------------------------------------------------------------
    _Insertar4:
        mov [Valor4], r11
        xor rbx, rbx
        xor r11, r11
        xor r8, r8

        jmp _Variables


    ;------------------------------------------------------------------------------------------------------
    ; Realiza un atoi al valor de la primera variable y guarda el resultado
    ;------------------------------------------------------------------------------------------------------
    _Insertar5:
        mov [Valor5], r11
        xor rbx, rbx
        xor r11, r11
        xor r8, r8

        jmp _Variables


    ;------------------------------------------------------------------------------------------------------
    ; Realiza un atoi al valor de la primera variable y guarda el resultado
    ;------------------------------------------------------------------------------------------------------
    _Insertar6:
        mov [Valor6], r11
        xor rbx, rbx
        xor r11, r11
        xor r8, r8

        jmp _Variables  


    ;------------------------------------------------------------------------------------------------------
    ; Realiza un atoi al valor de la primera variable y guarda el resultado
    ;------------------------------------------------------------------------------------------------------
    _Insertar7:
        mov [Valor7], r11
        xor rbx, rbx
        xor r11, r11
        xor r8, r8

        jmp _Variables


    ;------------------------------------------------------------------------------------------------------
    ; Realiza un atoi al valor de la primera variable y guarda el resultado
    ;------------------------------------------------------------------------------------------------------
    _Insertar8:
        mov [Valor8], r11
        xor rbx, rbx
        xor r11, r11
        xor r8, r8

        jmp _Variables


    ;------------------------------------------------------------------------------------------------------
    ; Realiza un atoi al valor de la primera variable y guarda el resultado
    ;------------------------------------------------------------------------------------------------------
    _Insertar9:
        mov [Valor9], r11
        xor rbx, rbx
        xor r11, r11
        xor r8, r8

        jmp _Variables

    
    ;------------------------------------------------------------------------------------------------------
    ; Prepara los registros para el cehqueo de la ecuacion
    ;------------------------------------------------------------------------------------------------------
    _previa:

        xor r8, r8
        xor r9, r9              ; contador parentesis abierto
        xor r10, r10            ; contador parenesis cerrado
        xor rax, rax
        xor rcx, rcx
        xor rbx, rbx
        mov rbx, 0
        mov rcx, 0

        jmp _revisar

    ;------------------------------------------------------------------------------------------------------
    ; ciclo sobre la ecuacion para saber si tiene una forma correcta, el puntero del contenido de la ecuacuacion
    ; se guarda en rcx y se utiliza r8b para ir byte por byte
    ;------------------------------------------------------------------------------------------------------
    _revisar:
        mov r8b, byte[Ecuacion+rcx]
        ;cmp r8b, 40h
        ;jg _Variables

        cmp r8b, 2Fh
        je _signoDiv

        cmp r8b, 2Dh
        je _signoMenos

        cmp r8b, 2Bh
        je _signos

        cmp r8b, 2Ah
        je _signos

        cmp r8b, 28h
        je _ParentesisA

        cmp r8b, 29h
        je _ParentesisC

        cmp r8b, 2Ch
        je _finalrevision


        inc rcx
        jmp _revisar

    ;------------------------------------------------------------------------------------------------------
    ; Chequea lo que esta adelante de un menos, si es vacio, otro signo o un parentesis cerrado da error
    ;------------------------------------------------------------------------------------------------------
    _signoMenos:
        xor r8, r8
        mov rax, rcx
        mov rbx, rax
        dec rax
        inc rbx
        mov r8b, byte[Ecuacion+rbx]
        cmp r8b, 2Fh
        je _error2
        cmp r8b, 2Dh
        je _error2
        cmp r8b, 2Bh
        je _error2
        cmp r8b, 2Ah
        je _error2
        cmp r8b, 2Ch
        je _error2
        cmp r8b, 0xA
        je _error2

        mov r8b, byte[Ecuacion+rax]
        cmp r8b, 28h
        je _error2

        xor r8, r8
        inc rcx
        jmp _revisar
        

    ;------------------------------------------------------------------------------------------------------
    ; Ceheque lo que estantes y despues del signo div, si es un cero, vacio, otro signo o un parentesis cerrado da error
    ;------------------------------------------------------------------------------------------------------
    _signoDiv:
        xor r8, r8
        mov rax, rcx
        mov rbx, rax
        dec rax
        inc rbx
        mov r8b, byte[Ecuacion+rbx]
        cmp r8b, 30h
        je _error2
        cmp r8b, 2Fh
        je _error2
        cmp r8b, 2Dh
        je _error2
        cmp r8b, 2Bh
        je _error2
        cmp r8b, 2Ah
        je _error2
        cmp r8b, 2Ch
        je _error2
        cmp r8b, 0xA
        je _error2

        mov r8b, byte[Ecuacion+rax]
        cmp r8b, 30h
        je _error2
        cmp r8b, 28h
        je _error2

        cmp rcx, 0
        je _error2

        xor r8, r8
        inc rcx
        jmp _revisar

    ;------------------------------------------------------------------------------------------------------
    ; Chequea los signo suma y multiplicacion, lo que esta adelante no puede ser un vacio, otro signo, la coma 
    ; o un parentesis cerrado
    ;------------------------------------------------------------------------------------------------------
    _signos:
        xor r8, r8
        mov rax, rcx
        mov rbx, rax
        dec rax
        inc rbx
        mov r8b, byte[Ecuacion+rbx]
        cmp r8b, 2Fh
        je _error2
        cmp r8b, 2Dh
        je _error2
        cmp r8b, 2Bh
        je _error2
        cmp r8b, 2Ah
        je _error2
        cmp r8b, 2Ch
        je _error2
        cmp r8b, 0xA
        je _error2

        mov r8b, byte[Ecuacion+rax]
        cmp r8b, 28h
        je _error2

        cmp rcx, 0
        je _error2

        xor r8, r8
        inc rcx
        jmp _revisar

    ;------------------------------------------------------------------------------------------------------
    ; Cuenta la cantidad de parentesis Abiertos, el contador esta en r9
    ;------------------------------------------------------------------------------------------------------
    _ParentesisA:
        inc r9
        inc rcx
        jmp _revisar

    ;------------------------------------------------------------------------------------------------------
    ; Cuenta la cantidad de parentesis Cerrados, el contador esta en r10
    ;------------------------------------------------------------------------------------------------------
    _ParentesisC:
        inc r10
        inc rcx
        jmp _revisar

    ;------------------------------------------------------------------------------------------------------
    ; Compara la cantidad de parentesis cerrados y abiertos, si esta no es igual da un error
    ;------------------------------------------------------------------------------------------------------
    _finalrevision: 
        cmp r9, r10
        je _ordenar

        jmp _error2

    ;------------------------------------------------------------------------------------------------------
    ; prepara los registros para transformar la ecuaciona a una postfija
    ;------------------------------------------------------------------------------------------------------
    _ordenar:
        xor rax, rax
        xor rbx, rbx
        xor rcx, rcx
        xor r8, r8
        xor r9, r9
        xor r10, r10
        xor r11, r11
        mov rbx, 2Ch
        push rbx
        mov rcx, 0
        mov rbx, 0
        
        jmp _postfija


    ;------------------------------------------------------------------------------------------------------
    ; Compara cada elemento de la ecuacion y dependiendo de su contenido decide como procesarlo
    ;------------------------------------------------------------------------------------------------------
    _postfija:
        mov r8b, byte[Ecuacion+rcx]

        cmp r8b, 60h
        jg _letra

        cmp r8b, 2Fh
        je _mayorprecedencia

        cmp r8b, 2Dh
        je _simbolo

        cmp r8b, 2Bh
        je _simbolo

        cmp r8b, 2Ah
        je _mayorprecedencia

        cmp r8b, 28h
        je _pAbierto

        cmp r8b, 29h
        je _pCerrado

        cmp r8b, 2Fh
        jg _numero

        cmp r8b, 2Ch
        je _finalrevision1


        inc rcx
        jmp _postfija


    ;------------------------------------------------------------------------------------------------------
    ; Administra cuando llega un menos o un mas
    ;------------------------------------------------------------------------------------------------------
    _simbolo:
        pop r10
        cmp r10, 2Fh
        je _sacar
        cmp r10, 2Ah
        je _sacar
        cmp r10, 2Bh
        je _cambiar
        cmp r10, 2Dh
        je _cambiar

        push r10
        push r8
        inc rcx
        jmp _postfija


    ;------------------------------------------------------------------------------------------------------
    ; Administra cuando llega una division o una multiplicacion
    ;------------------------------------------------------------------------------------------------------
    _mayorprecedencia:
        pop r10
        cmp r10, 2Fh
        je  _cambiar
        cmp r10, 2Ah
        je _cambiar
        cmp r10, 2Bh
        je _push
        cmp r10, 2Dh
        je _push

        push r10
        push r8
        inc rcx
        jmp _postfija
    

    ;------------------------------------------------------------------------------------------------------
    ; Agrega los numeros al string final
    ;------------------------------------------------------------------------------------------------------
    _numero:

        inc rcx
        mov [Numero+rbx], r8b
        mov r8b, byte[Ecuacion+rcx]
        cmp r8b, 60h
        jg _implicita
        cmp r8b, 30h
        jl _guardaNumero
        cmp r8b, 39h
        jg _guardaNumero
        inc rbx
        jmp _numero

    ;------------------------------------------------------------------------------------------------------
    ; Agrega una variable al string final
    ;------------------------------------------------------------------------------------------------------
    _letra:
        mov [Numero+rbx], r8b
        inc rcx
        jmp _guardaNumero


    ;------------------------------------------------------------------------------------------------------
    ; Administra la pila cuando hay una multiplicacion implicita y agrega la variable al string final
    ;------------------------------------------------------------------------------------------------------
    _implicita:
        mov rax, 2Ah
        pop r10
        cmp r10, 2Fh
        je _cambiarI
        cmp r10, 2Ah
        je _cambiarI
        cmp r10, 2Bh
        je _pushI
        cmp r10, 2Dh
        je _pushI

        push r10
        push rax

        inc rbx
        mov r8b, 20h
        mov [Numero+rbx], r8b
        inc rbx
        mov r8b, byte[Ecuacion+rcx]
        mov [Numero+rbx], r8b
        inc rcx
        jmp _guardaNumero

    
    ;------------------------------------------------------------------------------------------------------
    ; Administra la pila cuando llegan operadores de igual precedencia, mete el nuevo a la pila y el que 
    ; pertenecia lo coloca en el string final
    ;------------------------------------------------------------------------------------------------------
    _cambiar:
        push r8
        mov [Numero+rbx], r10b
        inc rbx
        inc rcx
        jmp _postfija

    ;------------------------------------------------------------------------------------------------------
    ; Administra la pila cuando llega un operador con mayor precendencia, guarda ambos en la pila
    ;------------------------------------------------------------------------------------------------------
    _push:
        push r10
        push r8
        inc rcx
        jmp _postfija

    ;------------------------------------------------------------------------------------------------------
    ; Administra cuando llega un parentesis abierto a la pila
    ;------------------------------------------------------------------------------------------------------
    _pAbierto:
        push r8
        inc rcx
        jmp _postfija

    ;------------------------------------------------------------------------------------------------------
    ; Administra la pila cuando llega una multiplicacion implicita y hay un operador de igual precedencia
    ;------------------------------------------------------------------------------------------------------
    _cambiarI:
        push rax
        inc rbx
        mov [Numero+rbx], r10b
        inc rbx
        mov [Numero+rbx], r8b
        inc rbx
        inc rcx
        jmp _postfija

    ;------------------------------------------------------------------------------------------------------
    ; Administra la pila cuando llega una multiplicacion implicita y hay un operador de menor precedencia
    ;------------------------------------------------------------------------------------------------------
    _pushI:
        push r10
        push rax
        inc rbx
        mov rax, 20h
        mov [Numero+rbx], rax
        inc rbx
        mov [Numero+rbx], r8b
        inc rbx
        inc rcx
        jmp _postfija

    ;------------------------------------------------------------------------------------------------------
    ; Administra la pila cuando llega un operador de menor precendencia, vacia la pila
    ;------------------------------------------------------------------------------------------------------
    _sacar:
        pop r11
        cmp r11, 28h
        je _unElemento
        cmp r11, 2Ch
        je _unElemento

        mov [Numero+rbx], r10b
        inc rbx
        mov [Numero+rbx], r11b
        inc rbx
        push r8
        inc rcx
        jmp _postfija

    ;------------------------------------------------------------------------------------------------------
    ; situacion donde solo se saca un elemento de la pila
    ;------------------------------------------------------------------------------------------------------
    _unElemento:
        push r11
        mov [Numero+rbx], r10b
        inc rbx
        push r8
        inc rcx
        jmp _postfija

    ;------------------------------------------------------------------------------------------------------
    ; Administra la pila cuando llega un parentesis cerrado, vacia la pila hasta encontrar un parentesis abierto
    ;------------------------------------------------------------------------------------------------------
    _pCerrado:
        pop r10
        cmp r10, 28h
        je _popAbierto
        inc rbx

        mov [Numero+rbx], r10
        inc rbx
        jmp _pCerrado

    ;------------------------------------------------------------------------------------------------------
    ; agrega un espacio en blanco al string final, para reconocer los numeros
    ;------------------------------------------------------------------------------------------------------
    _guardaNumero:
        inc rbx
        mov r8b, 20h
        mov [Numero+rbx], r8b
        inc rbx
        jmp _postfija

    ;------------------------------------------------------------------------------------------------------
    ; saca el parentesis abierto de la pila
    ;------------------------------------------------------------------------------------------------------
    _popAbierto:
        
        mov r8b, 20h
        mov [Numero+rbx], r8b
        inc rbx
        inc rcx
        jmp _postfija

    ;------------------------------------------------------------------------------------------------------
    ; Vacia la pila hasta encontrar una coma que indica el final de la pila
    ;------------------------------------------------------------------------------------------------------
    _finalrevision1:
        pop r10
        cmp r10, 2Ch
        je _preparar
        mov [Numero+rbx], r10
        inc rbx
        jmp _finalrevision1
    
    ;------------------------------------------------------------------------------------------------------
    ; prepara registros para la evaluacion
    ;------------------------------------------------------------------------------------------------------
    _preparar:
        mov r10, 2Ch
        mov [Numero+rbx], r10
        xor rbx, rbx
        xor rcx, rcx
        xor r9, r9
        xor r12, r12
        xor r8, r8
        xor r10, r10
        xor r11, r11
        xor rax, rax
        jmp _Evaluar

    ;------------------------------------------------------------------------------------------------------
    ; compara los elementos de la expresion postfija para manipularlos
    ;------------------------------------------------------------------------------------------------------
    _Evaluar:
        mov r8b, [Numero+rcx]
        cmp r8b, 2Bh
        je _SumaP
        cmp r8b, 2Dh
        je _RestaP
        cmp r8b, 2Ah
        je _MulP
        cmp r8b, 2Fh
        je _Div
        cmp r8b, 2Fh
        jg _Operandos
        cmp r8b, 60h
        jg _Var
        cmp r8b, 2Ch
        je _imp

        inc rcx
        jmp _Evaluar

    ;------------------------------------------------------------------------------------------------------
    ; prepara los registros para hacer un atoi a los operandos antes de la suma
    ;------------------------------------------------------------------------------------------------------
    _SumaP:
        xor rbx, rbx
        xor r9, r9
        xor r12, r12
        xor r10, r10
        xor r11, r11
        mov rbx, 0
        jmp _Suma

    ;------------------------------------------------------------------------------------------------------
    ;Itoa al primer operando
    ;------------------------------------------------------------------------------------------------------
    _Suma:
        mov r9b, byte[Operando1+rbx]
        cmp r9b, 2Ch
        je _Suma2
        sub r9b, 30h
        imul r12, 10
        add r12, r9
        inc rbx
        jmp _Suma

    ;------------------------------------------------------------------------------------------------------
    ;Itoa al segundo operando
    ;------------------------------------------------------------------------------------------------------
    _Suma2:
        mov r9b, byte[Operando2+r10]
        cmp r9b, 2Ch
        je _ProcesarS
        sub r9b, 30h
        imul r11, 10
        add r11, r9
        inc r10
        jmp _Suma2

    ;------------------------------------------------------------------------------------------------------
    ; prepara los registros para hacer un atoi a los operandos antes de la resta
    ;------------------------------------------------------------------------------------------------------
    _RestaP:
        xor rbx, rbx
        xor r9, r9
        xor r12, r12
        xor r10, r10
        xor r11, r11
        jmp _Resta

    ;------------------------------------------------------------------------------------------------------
    ;Itoa al primer operando
    ;------------------------------------------------------------------------------------------------------
    _Resta:
        mov r9b, byte[Operando1+rbx]
        cmp r9b, 2Ch
        je _Resta2
        sub r9b, 30h
        imul r12, 10
        add r12, r9
        inc rbx
        jmp _Resta

    ;------------------------------------------------------------------------------------------------------
    ;Itoa al segundo operando
    ;------------------------------------------------------------------------------------------------------
    _Resta2:
        mov r9b, byte[Operando2+r10]
        cmp r9b, 2Ch
        je _ProcesarR
        sub r9b, 30h
        imul r11, 10
        add r11, r9
        inc r10
        jmp _Resta2

    ;------------------------------------------------------------------------------------------------------
    ; prepara los registros para hacer un atoi a los operandos antes de la multiplcacion
    ;------------------------------------------------------------------------------------------------------
    _MulP:
        xor rbx, rbx
        xor r9, r9
        xor r12, r12
        xor r10, r10
        xor r11, r11
        jmp _Mul

    ;------------------------------------------------------------------------------------------------------
    ;Itoa al primer operando
    ;------------------------------------------------------------------------------------------------------
    _Mul:
        mov r9b, byte[Operando1+rbx]
        cmp r9b, 2Ch
        je _Mul2
        sub r9b, 30h
        imul r12, 10
        add r12, r9
        inc rbx
        jmp _Mul

    ;------------------------------------------------------------------------------------------------------
    ;Itoa al segundo operando
    ;------------------------------------------------------------------------------------------------------
    _Mul2:
        mov r9b, byte[Operando2+r10]
        cmp r9b, 2Ch
        je _ProcesarM
        sub r9b, 30h
        imul r11, 10
        add r11, r9
        inc r10
        jmp _Mul2

    ;------------------------------------------------------------------------------------------------------
    ; prepara los registros para hacer un atoi a los operandos antes de la division
    ;------------------------------------------------------------------------------------------------------
    _DivP:
        xor rbx, rbx
        xor r9, r9
        xor r12, r12
        xor r10, r10
        xor r11, r11
        xor rax, rax
        jmp _Div

    ;------------------------------------------------------------------------------------------------------
    ;Itoa al primer operando
    ;------------------------------------------------------------------------------------------------------
    _Div:
        mov r9b, byte[Operando1+rbx]
        cmp r9b, 2Ch
        je _Div2
        sub r9b, 30h
        imul r12, 10
        add r12, r9
        inc rbx
        jmp _Div

    ;------------------------------------------------------------------------------------------------------
    ;Itoa al segundo operando
    ;------------------------------------------------------------------------------------------------------
    _Div2:
        mov r9b, byte[Operando2+r11]
        cmp r9b, 2Ch
        je _ProcesarD
        sub r9b, 30h
        imul rax, 10
        add rax, r9
        inc r11
        jmp _Div2
    _ProcesarS:
        add r12, r11
        jmp _itoa
    _ProcesarR:
        sub r12, r11
        jmp _itoa

    _ProcesarM:
        imul r12, r11
        jmp _itoa

    _ProcesarD:
        div r12

    ;------------------------------------------------------------------------------------------------------
    ;pregunta si el primer operadno esta vacio y prepara los registros
    ;------------------------------------------------------------------------------------------------------
    _Operandos:
        push rcx
        inc rcx
        xor r10, r10
        cmp r8b, 60h
        jg _Var

        cmp byte[Operando1], 0
        jg _Operando2

        jmp _Ins

    ;------------------------------------------------------------------------------------------------------
    ;guarda el primer operando
    ;------------------------------------------------------------------------------------------------------
    _Ins:
        mov [Operando1+r10], r8b
        mov r8b, [Numero+rcx]
        cmp r8b, 30h
        jl _poneComas
        inc r10
        jmp _Ins

    ;------------------------------------------------------------------------------------------------------
    ;pregunta si el primer operadno esta vacio y prepara los registros
    ;------------------------------------------------------------------------------------------------------
    _Operando2:
        xor r11, r11
        cmp byte[Operando2], 0
        jg _Sobreescribir

        jmp _Ins2

    ;------------------------------------------------------------------------------------------------------
    ;guarda el segundo operando y si este ya esta lleno llama para sobreescribir el primero
    ;------------------------------------------------------------------------------------------------------
    _Ins2:
        mov byte[Operando2+r11], r8b
        mov r8b, byte[Numero+rcx]
        cmp r8b, 30h
        jl _poneComas2
        inc r11
        jmp _Ins2

    ;------------------------------------------------------------------------------------------------------
    ;sobreescribe el primer operando
    ;------------------------------------------------------------------------------------------------------
    _Sobreescribir:
        xor r10, r10
        mov [Operando1], r10
        mov r10, Operando2
        mov [Operando1], r10
        xor r10, r10
        mov [Operando2], r10
        jmp _Operando2

    ;------------------------------------------------------------------------------------------------------
    ;pregunta si el primer operadno esta vacio y prepara los registros, en el caso de una variable
    ;------------------------------------------------------------------------------------------------------
    _Var:
    inc rcx
        jmp _Evaluar
    ;    xor r11, r11
    ;    cmp byte[Operando1], 0
    ;    jg _Operando2V

     ;   mov r14b, Variable
     ;   cmp r8, r14
    ;    je _V
    ;    mov r14b, Variable1
    ;    cmp r8, r14
    ;    je _V1
    ;    mov r14b, Variable2
     ;   cmp r8, r14
    ;    je _V2
    ;    mov r14b, Variable3
    ;    cmp r8, r14
    ;    je _V3
    ;    mov r14b, Variable4
    ;    cmp r8, r14
    ;    je _V4
    ;    mov r14b, Variable5
    ;    cmp r8, r14
    ;    je _V5
    ;    mov r14b, Variable6
    ;    cmp r8, r14
    ;    je _V6
    ;    mov r14b, Variable7
    ;    cmp r8, r14
    ;    je _V7
    ;    mov r14b, Variable8
    ;    cmp r8, r14
     ;   je _V8
    ;    mov r14b, Variable9
    ;    cmp r8, r14
    ;    je _V9

    ;------------------------------------------------------------------------------------------------------
    ;guarda el primer operando segun la variable 
    ;------------------------------------------------------------------------------------------------------
    ;_V:
    ;    mov r14b, byte[Valor+r11]
    ;    cmp r14b, 0
    ;    je _poneComas
    ;    mov byte[Operando1+r11], r14b
    ;    inc r11
    ;    jmp _V    

    ;_V1:
     ;   mov r14b, byte[Valor1+r11]
     ;   cmp r14b, 0
    ;    je _poneComas
    ;    mov byte[Operando1+r11], r14b
    ;    inc r11
    ;    jmp _V1 
    ;_V2:
    ;    mov r14b, byte[Valor2+r11]
    ;    cmp r14b, 0
    ;    je _poneComas
    ;    mov byte[Operando1+r11], r14b
    ;    inc r11
    ;    jmp _V2 
    ;_V3:
    ;    mov r14b, byte[Valor3+r11]
    ;    cmp r14b, 0
    ;    je _poneComas
    ;    mov byte[Operando1+r11], r14b
    ;    inc r11
    ;    jmp _V3 
    ;_V4:
    ;    mov r14b, byte[Valor4+r11]
     ;   cmp r14b, 0
    ;    je _poneComas
    ;    mov byte[Operando1+r11], r14b
    ;    inc r11
    ;    jmp _V4 
    ;_V5:
    ;    mov r14b, byte[Valor5+r11]
    ;    cmp r14b, 0
    ;    je _poneComas
     ;   mov byte[Operando1+r11], r14b
    ;    inc r11
    ;    jmp _V5 
    ;_V6:
    ;    mov r14b, byte[Valor6+r11]
    ;    cmp r14b, 0
    ;    je _poneComas
    ;   mov byte[Operando1+r11], r14b
    ;    inc r11
    ;    jmp _V6 
    ;_V7:
    ;    mov r14b, byte[Valor7+r11]
    ;    cmp r14b, 0
    ;    je _poneComas
    ;    mov byte[Operando1+r11], r14b
    ;    inc r11
    ;    jmp _V7
    ;_V8:
    ;   mov r14b, byte[Valor8+r11]
    ;    cmp r14b, 0
    ;    je _poneComas
    ;    mov byte[Operando1+r11], r14b
    ;    inc r11
    ;    jmp _V8 
    ;_V9:
    ;    mov r14b, byte[Valor9+r11]
    ;    cmp r14b, 0
    ;    je _poneComas
     ;   mov byte[Operando1+r11], r14b
    ;    inc r11
    ;    jmp _V9 

    ;------------------------------------------------------------------------------------------------------
    ;pregunta si el segundo operadno esta vacio y prepara los registros, en el caso de una variable
    ;------------------------------------------------------------------------------------------------------
    ;_Operando2V:
    ;    cmp byte[Operando2], 0
    ;    jg _SobreescribirV

     ;   mov r14b, Variable
     ;   cmp r8, r14
     ;   je _VO
    ;    mov r14b, Variable1
    ;    cmp r8, r14
    ;    je _V1O
    ;    mov r14b, Variable2
    ;    cmp r8, r14
     ;   je _V2O
    ;    mov r14b, Variable3
    ;    cmp r8, r14
    ;    je _V3O
    ;    mov r14b, Variable4
    ;    cmp r8, r14
    ;    je _V4O
    ;    mov r14b, Variable5
    ;    cmp r8, r14
    ;    je _V5O
    ;    mov r14b, Variable6
    ;    cmp r8, r14
     ;   je _V6O
    ;    mov r14b, Variable7
    ;    cmp r8, r14
    ;    je _V7O
    ;    mov r14b, Variable8
       ; cmp r8, r14
      ;  je _V8O
     ;   mov r14b, Variable9
     ;   cmp r8, r14
     ;   je _V9O

    ;------------------------------------------------------------------------------------------------------
    ;guarda la segundo operando segun la variable especifica
    ;------------------------------------------------------------------------------------------------------
    ;_VO:
    ;    mov r14b, byte[Valor+r11]
    ;    cmp r14b, 0
    ;    je _poneComas2
    ;    mov byte[Operando2+r11], r14b
    ;    inc r11
    ;    jmp _VO    

    ;_V1O:
    ;    mov r14b, byte[Valor1+r11]
    ;   cmp r14b, 0
    ;    je _poneComas2
    ;    mov byte[Operando2+r11], r14b
    ;    inc r11
    ;    jmp _V1O 
    ;_V2O:
    ;    mov r14b, byte[Valor2+r11]
    ;    cmp r14b, 0
    ;    je _poneComas2
    ;    mov byte[Operando2+r11], r14b
    ;    inc r11
    ;    jmp _V2O 
    ;_V3O:
    ;    mov r14b, byte[Valor3+r11]
    ;   cmp r14b, 0
    ;    je _poneComas2
    ;    mov byte[Operando2+r11], r14b
    ;    inc r11
    ;    jmp _V3O 
    ;_V4O:
    ;    mov r14b, byte[Valor4+r11]
    ;    cmp r14b, 0
    ;    je _poneComas2
    ;    mov byte[Operando2+r11], r14b
    ;    inc r11
    ;    jmp _V4O 
    ;_V5O:
    ;    mov r14b, byte[Valor5+r11]
    ;    cmp r14b, 0
    ;   je _poneComas2
    ;    mov byte[Operando2+r11], r14b
    ;    inc r11
    ;    jmp _V5O 
    ;_V6O:
    ;    mov r14b, byte[Valor6+r11]
    ;    cmp r14b, 0
    ;    je _poneComas2
    ;    mov byte[Operando2+r11], r14b
    ;    inc r11
   ;     jmp _V6O 
    ;_V7O:
    ;    mov r14b, byte[Valor7+r11]
    ;    cmp r14b, 0
    ;    je _poneComas2
    ;    mov byte[Operando2+r11], r14b
    ;    inc r11
    ;    jmp _V7O
    ;_V8O:
    ;    mov r14b, byte[Valor8+r11]
    ;    cmp r14b, 0
    ;    je _poneComas2
    ;    mov byte[Operando2+r11], r14b
    ;    inc r11
    ;    jmp _V8O 
    ;_V9O:
    ;    mov r14b, byte[Valor9+r11]
    ;    cmp r14b, 0
    ;    je _poneComas2
    ;    mov byte[Operando2+r11], r14b
    ;    inc r11
    ;    jmp _V9O
    
    ;------------------------------------------------------------------------------------------------------
    ;Sobreescribe el primer operando con el segundo en el caso de que sea una varibalo
    ;------------------------------------------------------------------------------------------------------
    ;_SobreescribirV:
     ;   xor r10, r10
      ;  mov [Operando1], r10
       ; mov r10, Operando2
        ;mov [Operando1], r10
        ;xor r10, r10
        ;mov [Operando2], r10
        ;jmp _Operando2V

    ;------------------------------------------------------------------------------------------------------
    ;pone comas al final del primer operando
    ;------------------------------------------------------------------------------------------------------
    _poneComas:
        mov r9, r11
        inc r9
        mov byte[Operando1+r9], 2Ch
        jmp _Evaluar

    ;------------------------------------------------------------------------------------------------------
    ;pone comas al final del segundo operando
    ;------------------------------------------------------------------------------------------------------
    _poneComas2:
        mov r9, r11
        inc r9
        mov byte[Operando2+r9], 2Ch
        jmp _Evaluar
    _imp:
        mov rax, 1
	    mov rdi, 1
	    mov rsi, Numero
	    mov rdx, 1026
	    syscall

        mov rax, 1
	    mov rdi, 1
	    mov rsi, palabras
	    mov rdx, longitudErrorO
	    syscall
        call _salir
    ;------------------------------------------------------------------------------------------------------
    ;Proceso itoa para el resultado entre los operandos
    ;------------------------------------------------------------------------------------------------------
    _itoa:       
        jmp _imp               ; prepara el resultado para mostrar en panatalla
        mov rax, r12            ; aqui esta la cantidad de palabras
        xor rbx, rbx            ; vamos a poner el divisor
        
        xor r10, r10              ; movimientos
        xor r12, r12
        xor r14, r14
        xor r9, r9              ; iterar por 2da variable
        mov r9, 8
        mov rbx, 10             ; nuestro divisor
        mov [palabras], rbx
        
    .next:
        xor rdx, rdx            ; aqui vamos a guardar el residuo
        
        div rbx                 ; rax/rcx
        mov r10b, byte[tble+rdx]
        mov byte[palabras+r9], r10b
        dec r9
        inc r12
        cmp rax, 0              ; si llegamos a 0, no hay nada mas que dividir
        je _imp

        jmp .next