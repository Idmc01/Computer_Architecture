%macro salida 2
    mov edx, %1     ;EDX=lon. de la cadena
    mov ecx, %2      ;ECX=cadena a imprimir
    mov ebx, 1            ;EBX=manejador de fichero (STDOUT)
    mov eax, 4            ;EAX=funcion sys_write() del kernel

    int 0x80              ;interrupc. 80 (llamada al kernel)
    %endmacro
section .data               ;Solo se utilizo para los mensajes por imprimir en la terminal 
    mensaje     db "Digite el primer operando: ", 0xA
    longitud    equ $ - mensaje

    mensaje2     db "Digite el segundo operando: ", 0xA
    longitud2    equ $ - mensaje2

    mensajeS     db "La suma es: ", 0xA
    longitudS    equ $ - mensajeS

    mensajeD db "La diferencia es: ", 0xA
    longitudD    equ $ - mensajeD

    mensajeError db "la entrada no es un entero", 0xA
    longitudError    equ $ - mensajeError
   

section .bss
    numero1 resb 101
    numero2 resb 101
    cadena1 resb 101                 ;Espacio reservado para las entradas
    cadenaTrans1 resb 101            ;Espacio reservado para la transformacion de las entradas
    cadena2 resb 101
    cadenatrans2 resb 101
    respuesta resb 3                ;Espacio reservado para la respuesta del usuario

section .text    



    _error:
        salida longitudError, mensajeError
        call _fin
    _ciclo:
        cmp byte[rbx], 0xA
        jne _extremoIzquierdo
        ret
    _fin:
        mov ebx, 0            ;EBX=codigo de salida al SO
        mov eax, 1            ;EAX=funcion sys_exit() del kernel
        int 0x80              ;interrupc. 80 (llamada al kernel)  

    _extremoIzquierdo:
        cmp byte[rbx], 48     ;Chequea que no sea menor a cero
        jl _error
        jge _extremoDerecho   ; manda a validar el siguiente extremo

    _extremoDerecho:
        cmp byte[rbx], 57     ;Chequea que no sea mayor a nuever
        jg _error
        inc rbx
        jmp _ciclo



             
    global _start          ;definimos el punto de entrada
_start:
      
      salida longitud, mensaje      ; Imprime primer mensaje

      mov eax, 3
      mov ebx, 2
      mov rcx, cadena1              ; recibe el primer operando
      mov edx, 101
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

      _atoi:
      xor rbx, rbx                 ;limpia el RBX
      xor rax, rax                 ;limpia el RAX 
      _proceso:
      mov rax, [rcx]               ;mueve el valor contenido en rcx a rax
      cmp rax, 0xA                 ;verifica que no sea un caracter erroneo 
      je _atoi2                     

      sub rax, 48
      imul rbx, 10
      add rbx, rax

      inc rcx
      jmp _proceso


      _atoi2:
      xor rcx, rcx               ;limpia el rcx
      xor rdx, rdx               ;limpia el rdx
      _proceso2:
      mov rax, [rcx]             ;mueve el valor contenido en rcx a rax
      cmp rax, 0xA                ;verifica que no sea un caracter erroneo 
      je _suma                    ;llama a la funcion que suma ambos digitos

      sub rax, 48
      imul rdx, 10
      add rdx, rax

      inc rcx
      jmp _proceso2
      
      _suma:
        mov rcx, rbx        ;guardar valor para la resta
        add rdx, rbx        


      _resta:
        cmp rcx, rdx
        jg _resta2
        sub rdx, rcx

    _resta2:
        sub rcx, rdx

                            ; Falta proceso de itoa
             mov ebx, 0            ;EBX=codigo de salida al SO
        mov eax, 1            ;EAX=funcion sys_exit() del kernel
        int 0x80    

 

