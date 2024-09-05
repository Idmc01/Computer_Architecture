.macro salida p, p1
 movl \p, %edx     ;#EDX=lon. de la cadena
 movl \p1, %ecx      ;#ECX=cadena a imprimir
 movl $1, %ebx            ;#EBX=manejador de fichero (STDOUT)
 movl $4, %eax            ;#EAX=funcion sys_write() del kernel
 int $0x80              ;#interrupc. 80 (llamada al kernel)
 .endm

.section .data               ;#Solo se utilizo para los mensajes por imprimir en la terminal 
    mensaje: .ascii "Digite el texto por transformar a minusculas:"
    longitud = .  - mensaje

    mensajeM:     .ascii "Digite el texto por transformar a mayusuculas:"
    longitudM = .  - mensajeM

    mensajeExito: .ascii "Texto transformado: "
    longitudExito = .  - mensajeExito

    mensajeError: .ascii "Texto contiene caracteres invalidos"
    longitudError = .  - mensajeError

    Primermensaje: .ascii "Transformar de minusculas a mayusculas? Responder con si o no, de responer no se realizara el proceso inverso "
    longitudE = .  - Primermensaje

  

.section .bss
    cadena resb 101                 ;#Espacio reservado para las entradas
    cadenaTrans resb 101            ;#Espacio reservado para la transformacion delas entradas
    respuesta resb 3                ;#Espacio reservado para la respuesta del usuario

.section .text                    
    .globl _inicio          ;#definimos el punto de entrada
_inicio:
      salida longitudE, Primermensaje      ;# llamada a la macro para imprimir en pantalla
      
      movl $3,%eax                            ;# llamadas a systema para obtener datos de la terminal
      movl $2,%ebx
      movl $respuesta,%ecx                   ;# longitud
      movl $3,%edx                           ;# cantidad de teclas por reservar
      int $0x80

      cld
      movl $3,%ecx
      movl $respuesta,%edi
      movl $'s',al

      repne scasb                           ;# nos permite iterar sobre la cadena capturada y buscar una s en la respuesta
      je minusculasAmayusculas                               ;# de encontrar una s saltara al ciclo que permite pasar de minusculas a mayusculas

      salida longitud, mensaje      ;# mayusculas a minusculas

      movl $3,%eax
      movl $2,%ebx
      movl $cadena,%ecx
      movl $101,%edx
      int $0x80

      cld
      movl $101,%ecx                      ;#longitud del texto
      movl $cadena,%esi                   ;#indice fuente y se le asigna los datos capturados
      movl $cadenaTrans,%edi              ;#indice destino

      ciclo:
        lodsb                           ;#  envia un dato al al y aumenta de forma automatica
        add 20h,%al                     ;#  pasa las letras a mayusuculas
        stosb                           ;#  lo carga en la nueva variable
      loop ciclo                        
      jmp termina                       ;#  evita que se ejecuten los dos ciclos

      
      minusculasAmayusculas:
      salida longitudM, mensajeM   ;#minusculas a mayusculas

      movl $3,%eax
      movl $2,%ebx
      movl $cadena,%ecx
      movl $101,%edx
      int $0x80

      cld
      movl $101,%ecx
      movl $cadena,%esi
      movl $cadenaTrans,%edi

      cicloM:                           ;# mismo ciclo que el anterior solo que este le resta la diferencica para producir mayusculas
        lodsb
        sub 20h,%al
        stosb   
      loop cicloM

      termina:
        salida longitudExito, mensajeExito    ;# llamada a la macro para imprimir en pantalla
        salida '101', cadenaTrans           ;# llamada a la macro para imprimir en pantalla

      movl $0,%ebx           ;#EBX=codigo de salida al SO
      movl $1,%eax            ;#EAX=funcion sys_exit() del kernel
      int $0x80              ;#interrupc. 80 (llamada al kernel)    