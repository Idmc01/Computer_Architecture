MISMATCH: "%macro salida 2"
    movl $%1, %edx  #EDX=lon. de la cadena
    movl $%2, %ecx   #ECX=cadena a imprimir
    movl $1,%ebx          #EBX=manejador de fichero (STDOUT)
    movl $4,%eax          #EAX=funcion sys_write() del kernel
    int $0x80             #interrupc. 80 (llamada al kernel)
MISMATCH: "    %endmacro"
.data                       #Solo se utilizo para los mensajes por imprimir en la terminal 
MISMATCH: "    mensaje     db "Digite el primer numero: ", 0xA"
MISMATCH: "    longitud    equ $ - mensaje"

MISMATCH: "    mensaje2     db "Digite el segundo numero: ", 0xA"
MISMATCH: "    longitud2    equ $ - mensaje2"

MISMATCH: "    mensajeS     db "Suma en bases numericas de la 16 a base 2: ", 0xA"
MISMATCH: "    longitudS    equ $ - mensajeS"

MISMATCH: "    mensajeD db "Diferencia en bases numericas de la 16 a base 2: ", 0xA"
MISMATCH: "    longitudD    equ $ - mensajeD"

MISMATCH: "    mensajeError db "Entrada invalida, por favor intentelo otra vez.", 0xA"
MISMATCH: "    longitudError    equ $ - mensajeError"

MISMATCH: "    salto db 0xA, 0xD"
    .equ     saltolen, $-salto

MISMATCH: "    tble db "0123456789ABCDEF", 0xA"


.bss
MISMATCH: "    cadena1 resb 21                 "
MISMATCH: "    resultadoSuma resb 50            "
MISMATCH: "    cadena2 resb 21"
MISMATCH: "    resultadoResta resb 50  "
MISMATCH: "    respuesta resb 21                "

.text

    #imprime el mensaje de error y vuelve a preguntar por la entrada del usuario
    _error: 
MISMATCH: "        salida longitudError, mensajeError"
        call _inicio

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


    .global _start         #definimos el punto de entrada
_start: 

      _inicio: 
MISMATCH: "      salida longitud, mensaje      "

      movl $3,%eax
      movl $2,%ebx
      movq $cadena1, %rcx           # recibe el primer operando
      movl $21,%edx
      int $0x80

      movq $cadena1, %rbx
      call _extremoIzquierdo        #chequea que el primero sea entero

MISMATCH: "      salida longitud2, mensaje2      "

      movl $3,%eax
      movl $2,%ebx
      movq $cadena2, %rcx           # recibe el segundo operando
      movl $101,%edx
      int $0x80

      movq $cadena2, %rbx
      call _extremoIzquierdo        #chequea que el segundo sea entero

      _atoi:      #ascii to integer
MISMATCH: "            xor r10, r10  "
            xorq %rbx,%rbx # vamos a guardar el numero
MISMATCH: "            xor r11, r11 "
MISMATCH: "            mov r10, cadena1 "
      _atoi.next: 
MISMATCH: "            movzx r11, byte[r10]"
MISMATCH: "            cmp r11, 0xA "
            je _atoi2

MISMATCH: "            sub r11, '0' "
            imulq $10,%rbx
            addq $r11, %rbx
MISMATCH: "            inc r10"
            jmp _atoi.next

    _atoi2:      #ascii to integer
MISMATCH: "            xor r10, r10  "
            xorq %rcx,%rcx # vamos a guardar el numero
MISMATCH: "            xor r11, r11 "
MISMATCH: "            mov r10, cadena2 "
     _atoi2.next: 
MISMATCH: "            movzx r11, byte[r10]"
MISMATCH: "            cmp r11, 0xA "
            je _sumar

MISMATCH: "            sub r11, '0' "
            imulq $10,%rcx
            addq $r11, %rcx
MISMATCH: "            inc r10"
            jmp _atoi2.next

      _sumar: 
MISMATCH: "        xor r12, r12"
MISMATCH: "        mov r12, 17         "
MISMATCH: "        xor r13, r13"
MISMATCH: "        mov r13, 17         "
MISMATCH: "        xor r8, r8          "
MISMATCH: "        xor r9, r9"
        movq %rcx, $r8
        movq %rbx, $r9
        addq %rcx,%rbx      # La suma queda en rbx
        call _imprimeMensajeS
        jmp _itoa           #llama al ciclo para procesar las sumas

        # compara las entradas para ver cual es mayor
      _resta: 
        call _imprimeSalto
        call _imprimeMensajeR
        xorq %rbx,%rbx
MISMATCH: "        cmp r8, r9"
        jle _resta2     # si la almacenada en r8 en menor o igual va a ir a la otra funcion

MISMATCH: "        sub r8, r9      "
        movq $r8, %rbx  #se la pasamos A rbx para que se pueda procesar en el ciclo
        jmp _itoaResta  # llama al ciclo para convertir la diferencia a otras bases

      _resta2: 
MISMATCH: "        sub r9, r8      "
        movq $r9, %rbx #se la pasamos A rbx para que se pueda procesar en el ciclo
        jmp _itoaResta


      _itoa:    #integer to ascii de todas las bases
        xorq %rax,%rax
            xorq %rcx,%rcx #vamos a poner el divisor
            xorq %rdx,%rdx #aqui vamos a guardar el residuo
MISMATCH: "            xor r10, r10 "
MISMATCH: "            xor r11, r11 "
MISMATCH: "        mov r11, 19   "
        jmp _todasLasBases

        # primer ciclo para iteral sobre las bases numericas
      _todasLasBases: 

        movq %rbx,%rax
        movq $r12, %rcx
        decq %rcx       # rcx lleva la base por la que va el ciclo
        movq %rcx, $r12 #guardamos por donde va la iteracion
        cmpq $2,%rcx    # cuando lleguemos a la base dos frenamos
        jl _resta

        jmp _conversion

        # ciclo interno que itera sobre el numero para pasarlo a su respectiva bse
        _conversion: 
            xorq %rdx,%rdx

            divq %rcx   #rax/rcx
MISMATCH: "            mov r10b, byte[tble+rdx]"
MISMATCH: "            mov byte[resultadoSuma+r11], r10b   "
MISMATCH: "            dec r11     "
            cmpq $0,%rax #si llegamos a 0, no hay nada mas que dividir
            je _imprimirresultado

            jmp _conversion

        #preparamos todas la variables que se van a utilixzar en el proceso de itoa y de conversiones
      _itoaResta: 
        xorq %rax,%rax
        xorq %rcx,%rcx #lleva la base por la que va el ciclo
        xorq %rdx,%rdx
MISMATCH: "        xor r10, r10  "
MISMATCH: "        xor r11, r11 "
MISMATCH: "        mov r11, 19 "

        jmp _todasLasBasesResta

      _todasLasBasesResta: 
        movq %rbx,%rax #rax tiene el numero en base diez 
        movq $r13, %rcx # alimentamos por donde va el contador
        decq %rcx
        movq %rcx, $r13 #guardamos el contador para la siguiente operacion
        cmpq $2,%rcx    #cuando lleg a la ue=ltima base termian el programa
        jl _salir

        jmp _conversionResta

        #ciclo interno para convertir e imorimir cada numero en su base
        _conversionResta: 
            xorq %rdx,%rdx

            divq %rcx   #rax/rcx
MISMATCH: "            mov r10b, byte[tble+rdx]"
MISMATCH: "            mov byte[resultadoResta+r11], r10b"
MISMATCH: "            dec r11"
            cmpq $0,%rax #si llegamos a 0, no hay nada mas que dividir
            je _imprimirresultadoResta

            jmp _conversionResta

        # imprime el resultado de la suma en las bases y vuelve a llamar al ciclo
      _imprimirresultado: 
        call _imprimeSalto
        call _imprimeSalto
        xorq %rax,%rax
            movq $1,%rax
            movq $1,%rdi
            movq $resultadoSuma, %rsi
            movq $20,%rdx
MISMATCH: "            syscall"

        call _itoa      #llama al ciclo para ir por la sigueinte base

        # Imprime el resultado de la diferencia en las diferentes bases
     _imprimirresultadoResta: 
        call _imprimeSalto
        call _imprimeSalto
        xorq %rax,%rax
            movq $1,%rax
            movq $1,%rdi
            movq $resultadoResta, %rsi
            movq $20,%rdx
MISMATCH: "            syscall"

        call _itoaResta     # llama al ciclo para ir or la siguente conversiom

    #proceso para terminar el programa
    _salir: 
        call _imprimeSalto
            movq $60,%rax
            movq $0,%rdi
MISMATCH: "            syscall     "
