MISMATCH: "%macro salida 2"
    movl $%1, %edx  #EDX=lon. de la cadena
    movl $%2, %ecx   #ECX=cadena a imprimir
    movl $1,%ebx          #EBX=manejador de fichero (STDOUT)
    movl $4,%eax          #EAX=funcion sys_write() del kernel
    int $0x80             #interrupc. 80 (llamada al kernel)
MISMATCH: "    %endmacro"
.data                       #Solo se utilizo para los mensajes por imprimir en la terminal 
MISMATCH: "    mensaje     db "Que operacion desea Realizar: ", 0xA"
MISMATCH: "    longitud    equ $ - mensaje"

MISMATCH: "    mensaje2     db "1. Suma.", 0xA"
MISMATCH: "    longitud2    equ $ - mensaje2"

MISMATCH: "    mensaje3     db "2. Resta", 0xA"
MISMATCH: "    longitud3    equ $ - mensaje3"

MISMATCH: "    mensaje4     db "3. Multiplicacion.", 0xA"
MISMATCH: "    longitud4    equ $ - mensaje4"

MISMATCH: "    mensaje5     db "4. Division.", 0xA"
MISMATCH: "    longitud5    equ $ - mensaje5"

MISMATCH: "    primerOperando db "Digite el primer operando: ", 0xA"
MISMATCH: "    lenOperando     equ $ - primerOperando"

MISMATCH: "    SegOperando db "Digite el segundo operando: ", 0xA"
MISMATCH: "    lenOperando2     equ $ - SegOperando"

MISMATCH: "    mensajeS     db "Binario: ", 0xA"
MISMATCH: "    longitudS    equ $ - mensajeS"

MISMATCH: "    mensajeD db "Octal: ", 0xA"
MISMATCH: "    longitudD    equ $ - mensajeD"

MISMATCH: "    mensajeH db "Hexadecimal: ", 0xA"
MISMATCH: "    longitudH    equ $ - mensajeH"

MISMATCH: "    mensajeF db "Decimal: ", 0xA"
MISMATCH: "    longitudF    equ $ - mensajeF"

MISMATCH: "    mensajeError db "Entrada invalida, por favor intentelo otra vez.", 0xA"
MISMATCH: "    longitudError    equ $ - mensajeError"

MISMATCH: "    mensajeErrorO db "Digite un numero de operacion valido.", 0xA"
MISMATCH: "    longitudErrorO    equ $ - mensajeErrorO"

MISMATCH: "    salto db 0xA, 0xD"
    .equ     saltolen, $-salto

MISMATCH: "    tble db "0123456789ABCDEF", 0xA"


.bss
MISMATCH: "    operacion resb 2            "
MISMATCH: "    cadena1 resb 21                 "
MISMATCH: "    resultadoBinario resb 100            "
MISMATCH: "    resultadoOctal resb 100"
MISMATCH: "    resultadoHexadecimal resb 50"
MISMATCH: "    resultadoDecimal resb 50"
MISMATCH: "    cadena2 resb 21"
MISMATCH: "    resultadoResta resb 50  "
MISMATCH: "    respuesta resb 21                "

.text

    #imprime el mensaje de error y vuelve a preguntar por la entrada del usuario
    _error: 
MISMATCH: "        salida longitudError, mensajeError"
        call _inicio

    _errorOperacion: 
MISMATCH: "        salida longitudErrorO, mensajeErrorO"
        call _inicio

    _chequeo: 
        cmpb $0xA,(%rbx)
        jne _chequeo1
        ret

    _chequeo1: 
        cmpb $49,(%rbx)
        jne _chequeo2
MISMATCH: "        mov r13, 1h"
        incq %rbx
        jmp _chequeo

    _chequeo2: 
        cmpb $50,(%rbx)
        jne _chequeo3
MISMATCH: "        mov r13, 2h"
        incq %rbx
        jmp _chequeo

    _chequeo3: 
        cmpb $51,(%rbx)
        jne _chequeo4
MISMATCH: "        mov r13, 3h"
        incq %rbx
        jmp _chequeo

    _chequeo4: 
        cmpb $52,(%rbx)
        jne _errorOperacion
MISMATCH: "        mov r13, 4h"
        incq %rbx
        jmp _chequeo


    #proceso para verificar si es un entero    
    _ciclo: 
        cmpb $0xA,(%rbx)
        jne _extremoIzquierdo
        ret
    _fin: 
        movl $0,%ebx          #EBX=codigo de salida al SO
        movl $1,%eax          #EAX=funcion sys_exit() del kernel
        int $0x80             #interrupc. 80 (llamada al kernel)  

    #checkea que el valor ascii no sea menor que el del cero
    _extremoIzquierdo: 
        cmpb $48,(%rbx)
        jl _error       # si es menor da error
        jge _extremoDerecho

    #chequea que el valor asciii de la entrada no sea mayor al del 9
    _extremoDerecho: 
        cmpb $57,(%rbx)
        jg _error       # si es mayor da error
        incq %rbx       # avanzamos al siguiente caracter
        jmp _ciclo

    #imprime un salto de linea en la terminal
    _imprimeSalto: 
        movq $1,%rax
            movq $1,%rdi
            movq $salto, %rsi
            movq $saltolen, %rdx
MISMATCH: "            syscall"
        ret

    #imprime el mensaje de la suma
    _imprimeMensajeS: 
        call _imprimeSalto

        movq $1,%rax
            movq $1,%rdi
            movq $mensajeS, %rsi
            movq $longitudS, %rdx
MISMATCH: "            syscall"
        ret


    #imprime el mensaje de la diferencia
    _imprimeMensajeR: 
        call _imprimeSalto

        movq $1,%rax
            movq $1,%rdi
            movq $mensajeD, %rsi
            movq $longitudD, %rdx
MISMATCH: "            syscall"
        ret


    _Binario: 
        xorq %rcx,%rcx
MISMATCH: "        xor r11, r11"
MISMATCH: "        xor r10, r10"
        xorq %rax,%rax
MISMATCH: "        mov r11, 19"
        movq %rbx,%rax
        movq $2,%rcx
        jmp _conversionB

        _conversionB: 
            xorq %rdx,%rdx

            divq %rcx   #rax/rcx
MISMATCH: "            mov r10b, byte[tble+rdx]"
MISMATCH: "            mov byte[resultadoBinario+r11], r10b   "
MISMATCH: "            dec r11     "
            cmpq $0,%rax #si llegamos a 0, no hay nada mas que dividir
            je _imprimirresultadoB

            jmp _conversionB

    _imprimirresultadoB: 
        call _imprimeSalto
MISMATCH: "        xor r12, r12"
        movq %rbx, $r12
MISMATCH: "        salida longitudS, mensajeS"
        xorq %rbx,%rbx
        movq $r12, %rbx

        xorq %rax,%rax
            movq $1,%rax
            movq $1,%rdi
            movq $resultadoBinario, %rsi
            movq $20,%rdx
MISMATCH: "            syscall"

        call _Octal

    _Octal: 
        xorq %rcx,%rcx
MISMATCH: "        xor r11, r11"
MISMATCH: "        xor r10, r10"
        xorq %rax,%rax
MISMATCH: "        mov r11, 19"
        movq %rbx,%rax
        movq $8,%rcx
        jmp _conversionO

        _conversionO: 
            xorq %rdx,%rdx

            divq %rcx   #rax/rcx
MISMATCH: "            mov r10b, byte[tble+rdx]"
MISMATCH: "            mov byte[resultadoOctal+r11], r10b   "
MISMATCH: "            dec r11     "
            cmpq $0,%rax #si llegamos a 0, no hay nada mas que dividir
            je _imprimirresultadoO

            jmp _conversionO

    _imprimirresultadoO: 
        call _imprimeSalto
MISMATCH: "        salida longitudD, mensajeD"
        xorq %rbx,%rbx
        movq $r12, %rbx

        xorq %rax,%rax
            movq $1,%rax
            movq $1,%rdi
            movq $resultadoOctal, %rsi
            movq $20,%rdx
MISMATCH: "            syscall"

        call _Hexadecimal

    _Hexadecimal: 
        xorq %rcx,%rcx
MISMATCH: "        xor r11, r11"
MISMATCH: "        xor r10, r10"
        xorq %rax,%rax
MISMATCH: "        mov r11, 19"
        movq %rbx,%rax
        movq $16,%rcx
        jmp _conversionH

        _conversionH: 
            xorq %rdx,%rdx

            divq %rcx   #rax/rcx
MISMATCH: "            mov r10b, byte[tble+rdx]"
MISMATCH: "            mov byte[resultadoHexadecimal+r11], r10b   "
MISMATCH: "            dec r11     "
            cmpq $0,%rax #si llegamos a 0, no hay nada mas que dividir
            je _imprimirresultadoH

            jmp _conversionH

    _imprimirresultadoH: 
        call _imprimeSalto
MISMATCH: "        salida longitudH, mensajeH"
        xorq %rbx,%rbx
        movq $r12, %rbx

        xorq %rax,%rax
            movq $1,%rax
            movq $1,%rdi
            movq $resultadoHexadecimal, %rsi
            movq $20,%rdx
MISMATCH: "            syscall"

        call _Decimal


    _Decimal: 
        xorq %rcx,%rcx
MISMATCH: "        xor r11, r11"
MISMATCH: "        xor r10, r10"
        xorq %rax,%rax
MISMATCH: "        mov r11, 19"
        movq %rbx,%rax
        movq $10,%rcx
        jmp _conversionD

        _conversionD: 
            xorq %rdx,%rdx

            divq %rcx   #rax/rcx
MISMATCH: "            mov r10b, byte[tble+rdx]"
MISMATCH: "            mov byte[resultadoDecimal+r11], r10b   "
MISMATCH: "            dec r11     "
            cmpq $0,%rax #si llegamos a 0, no hay nada mas que dividir
            je _imprimirresultadoD

            jmp _conversionD

    _imprimirresultadoD: 
        call _imprimeSalto
MISMATCH: "        salida longitudF, mensajeF"
        xorq %rbx,%rbx
        movq $r12, %rbx

        xorq %rax,%rax
            movq $1,%rax
            movq $1,%rdi
            movq $resultadoDecimal, %rsi
            movq $20,%rdx
MISMATCH: "            syscall"

        call _salir



    .global _start         #definimos el punto de entrada
_start: 

      _inicio: 
MISMATCH: "      salida longitud, mensaje      "
      call _imprimeSalto
MISMATCH: "      salida longitud2, mensaje2      "
MISMATCH: "      salida longitud3, mensaje3      "
MISMATCH: "      salida longitud4, mensaje4      "
MISMATCH: "      salida longitud5, mensaje5      "

      movl $3,%eax
      movl $2,%ebx
      movq $operacion, %rcx           # recibe la operacion por realizar
      movl $21,%edx
      int $0x80

      movq $operacion, %rbx
MISMATCH: "      xor r13, r13"
      call _chequeo

      _Proceso: 
        call _imprimeSalto
MISMATCH: "        salida lenOperando, primerOperando"

        movl $3,%eax
        movl $2,%ebx
        movq $cadena1, %rcx           # recibe el primer operando
        movl $21,%edx
        int $0x80

        movq $cadena1, %rbx
        call _extremoIzquierdo        #chequea que el primero sea entero

MISMATCH: "        salida lenOperando2, SegOperando"

        movl $3,%eax
        movl $2,%ebx
        movq $cadena2, %rcx           # recibe el segundo operando
        movl $101,%edx
        int $0x80

        movq $cadena2, %rbx
        call _extremoIzquierdo        #chequea que el segundo sea entero

        _atoi:      #ascii to integer
MISMATCH: "                xor r10, r10  "
                xorq %rbx,%rbx # vamos a guardar el numero
MISMATCH: "                xor r11, r11 "
MISMATCH: "                mov r10, cadena1 "
            _atoi.next: 
MISMATCH: "                movzx r11, byte[r10]"
MISMATCH: "                cmp r11, 0xA "
                je _atoi2

MISMATCH: "                sub r11, '0' "
                imulq $10,%rbx
                addq $r11, %rbx
MISMATCH: "                inc r10"
                jmp _atoi.next

        _atoi2:      #ascii to integer
MISMATCH: "                xor r10, r10  "
                xorq %rcx,%rcx # vamos a guardar el numero
MISMATCH: "                xor r11, r11 "
MISMATCH: "                mov r10, cadena2 "
        _atoi2.next: 
MISMATCH: "                movzx r11, byte[r10]"
MISMATCH: "                cmp r11, 0xA "
                je _saltos

MISMATCH: "                sub r11, '0' "
                imulq $10,%rcx
                addq $r11, %rcx
MISMATCH: "                inc r10"
                jmp _atoi2.next


        _saltos: 
MISMATCH: "            cmp r13, 1h                   "
            je _Suma
MISMATCH: "            cmp r13, 2h                   "
            je _Resta
MISMATCH: "            cmp r13, 3h                   "
            je _Multiplicacion
MISMATCH: "            cmp r13, 4h                   "
            je _Division

      _Suma: 
        addq %rcx,%rbx      # la suma queda en rbx
        call _imprimeSalto

        call _Binario

      _Resta: 
        subq %rcx,%rbx
        call _imprimeSalto

        call _Binario

      _Multiplicacion: 
        movq %rcx,%rax
        mulq %rbx
        xorq %rbx,%rbx
        movq %rax,%rbx

        call _imprimeSalto
        call _Binario

      _Division: 
        cmpq %rcx,%rbx
        jl _primeroMenor
        #mov rax, rbx
        #div rbx
        movq $0,%rdx
        movq %rbx,%rax
        divq %rcx
        movq %rax,%rbx
        call _imprimeSalto
        call _Binario

        _primeroMenor: 

        call _imprimeSalto
        call _Binario

     _salir: 
        call _imprimeSalto
            movq $60,%rax
            movq $0,%rdi
MISMATCH: "            syscall     "

