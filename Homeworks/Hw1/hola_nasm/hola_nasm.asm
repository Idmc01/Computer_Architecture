section .data
    mensaje db "hola mundo", 0xA
    longitut equ $ - mensaje
section .text
    global _inicio      ;definimos el punto de entrada
_inicio:
    mov edx,longitut    ;EDX=long. de la cadena
    mov ecx,mensaje     ;ECX=cadena a imprimir
    mov ebx,1           ;EBX=manejador de fichero (STDOUT)
    mov eax,4           ;EAX=función sys_write() del kernel
    int 0x80            ;interrupc. 80 (llamada al kernel)

    mov ebx,0           ;EBX=código de salida al SO
    mov eax,1           ;EAX=función sys_exit() del kernel
    int 0x80            ;interrupc. 80 (llamada al kernel)