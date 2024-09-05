%macro salida 2
 mov edx, %1     ;EDX=lon. de la cadena
 mov ecx, %2      ;ECX=cadena a imprimir
 mov ebx, 1            ;EBX=manejador de fichero (STDOUT)
 mov eax, 4            ;EAX=funcion sys_write() del kernel
 int 0x80              ;interrupc. 80 (llamada al kernel)
 %endmacro

section .data               ;Solo se utilizo para los mensajes por imprimir en la terminal 
    mensaje     db "Digite el texto por transformar a minusculas:", 0xA
    longitud    equ $ - mensaje

    mensajeM     db "Digite el texto por transformar a mayusuculas:", 0xA
    longitudM    equ $ - mensajeM

    mensajeExito db "Texto transformado: ", 0xA
    longitudExito    equ $ - mensajeExito

    mensajeError db "Texto contiene caracteres invalidos", 0xA
    longitudError    equ $ - mensajeError

    Primermensaje db "Transformar de minusculas a mayusculas? Responder con si o no, de responer no se realizara el proceso inverso ", 0xA
    longitudE    equ $ - Primermensaje

    salto db 0xA, 0xD
    largoSalto equ $ - salto     

section .bss
    cadena resb 101                 ;Espacio reservado para las entradas
    cadenaTrans resb 101            ;Espacio reservado para la transformacion delas entradas
    respuesta resb 3                ;Espacio reservado para la respuesta del usuario

section .text                    
    global _inicio          ;definimos el punto de entrada
_inicio:
      salida longitudE, Primermensaje      ; llamada a la macro para imprimir en pantalla
      
      mov eax, 3                            ; llamadas a systema para obtener datos de la terminal
      mov ebx, 2
      mov ecx, respuesta                    ; longitud
      mov edx, 3                           ; cantidad de teclas por reservar
      int 0x80

      cld
      mov ecx, 3
      mov edi, respuesta
      mov al, 's'

      repne scasb                           ; nos permite iterar sobre la cadena capturada y buscar una s en la respuesta
      je minusculasAmayusculas                               ; de encontrar una s saltara al ciclo que permite pasar de minusculas a mayusculas

      salida longitud, mensaje      ; mayusculas a minusculas

      mov eax, 3
      mov ebx, 2
      mov ecx, cadena
      mov edx, 101
      int 0x80

      cld
      mov ecx, 101                      ;longitud del texto
      mov esi, cadena                   ;indice fuente y se le asigna los datos capturados
      mov edi, cadenaTrans              ;indice destino

      ciclo:
        lodsb                           ;  envia un dato al al y aumenta de forma automatica
        add al, 20h                     ;  pasa las letras a mayusuculas
        stosb                           ;  lo carga en la nueva variable
      loop ciclo                        
      jmp termina                       ;  evita que se ejecuten los dos ciclos

      
      minusculasAmayusculas:
      salida longitudM, mensajeM   ;minusculas a mayusculas

      mov eax, 3
      mov ebx, 2
      mov ecx, cadena
      mov edx, 101
      int 0x80

      cld
      mov ecx, 101
      mov esi, cadena
      mov edi, cadenaTrans

      cicloM:                           ; mismo ciclo que el anterior solo que este le resta la diferencica para producir mayusculas
        lodsb
        sub al, 20h
        stosb   
      loop cicloM

      termina:
        salida longitudExito, mensajeExito    ; llamada a la macro para imprimir en pantalla
        salida '101', cadenaTrans           ; llamada a la macro para imprimir en pantalla

      mov ebx, 0            ;EBX=codigo de salida al SO
      mov eax, 1            ;EAX=funcion sys_exit() del kernel
      int 0x80              ;interrupc. 80 (llamada al kernel)    