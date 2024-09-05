%macro salida 2
    mov edx, %1     ;EDX=lon. de la cadena
    mov ecx, %2      ;ECX=cadena a imprimir
    mov ebx, 1            ;EBX=manejador de fichero (STDOUT)
    mov eax, 4            ;EAX=funcion sys_write() del kernel
    int 0x80              ;interrupc. 80 (llamada al kernel)
    %endmacro 
;El archivo debe estar en la misma carpeta que el codigo para solo poner el nombre
;de otra manera debera especificar la ruta del archivo de prueba
;
section .data
    mensajeA     db "Inserte el nombre del archivo con el formato 'nombre.txt': ", 0xA
    longitudA    equ $ - mensajeA

    mensaje     db "Cantidad de palabras: ", 0xA
    longitud    equ $ - mensaje

    mensajeErrorO db "El texto supera la cantidad maxima de 2048 caracteres.", 0xA
    longitudErrorO    equ $ - mensajeErrorO

    mensajeErrorA db "Se produjo un error con el archivo.", 0xA
    longitudErrorA    equ $ - mensajeErrorA

    salto db 0xA, 0xD
    saltolen equ $-salto

    filename db 'prueba.txt', 0

    tamnoContenido equ 2060

    tble db "0123456789ABCDEF", 0xA


section .bss

    Contenido resb tamnoContenido
    palabras resb 10 
    nombreArchivo resb 100
    nombreArchivo2 resb 100
    guardaPalabra resb 25
    guardaLetra resb 2
section .text

    _salir:
        call _imprimeSalto
        mov rax, 3       ; numero de la funcion 'close'
        mov rdi, r10      ; descriptor de archivo
        syscall

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

    _ErrorArchivo:          ;Imprime mensaje de erros con el manejo del archivo
        mov rax, 1
	    mov rdi, 1
	    mov rsi, mensajeErrorA
	    mov rdx, longitudErrorA
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
    mov eax, 3                
    mov ebx, 2                
    mov rcx, nombreArchivo              ; recibe el nombre del archivo
    mov edx, 100
    int 0x80

    xor rsi, rsi
    mov rsi, nombreArchivo
    xor rcx, rcx                     
    mov rcx, 0                         ;Se inicializan los contadores
    _NombreArchivo:                     ; ciclo para poder utilizar el nombre del archivo dado por el usuario
        mov r10b, byte[rsi]
        cmp byte[rsi], 0xA
        je _AbrirArchivo
        mov [nombreArchivo2+rcx], r10b
        inc rsi
        inc rcx
        jmp _NombreArchivo


    _AbrirArchivo:
        ; abrir el archivo
        mov rax, 2          ; numero de la funcion 'open'
        mov rdi, nombreArchivo2
        mov rsi, 0          ; modo de apertura: lectura
        mov rdx, 0          ; permisos: por defecto
        syscall
        mov r10, rax        ; guardar el descriptor de archivo en r10

        cmp r10, 0          ; si en el descriptor da un valor negativo ocurrio un problema con el archivo
        jl _ErrorArchivo

        ; leer el archivo en el bufer
        mov rax, 0          ; numero de la funcion 'read'
        mov rdi, r10        ; descriptor de archivo
        mov rsi, Contenido
        mov rdx, tamnoContenido
        syscall
        mov rbx, rax        ; cantidad de bytes leidos

        xor r12, r12                
        xor r14, r14
        mov r12, 40h                ; comprar con las mayusculas
        mov r13, 60h                ; comprar con las minusculas
        mov r14, rax                ; variable auxiliar para guardar cantidad de bytes
        call _chequeoCaracteres

        _previa:
        inc r12                     ; avanza a la siguiente letra del abecedario
        inc r13
        cmp r12, 5Bh                ; saber si ya se recorrio todo el abecedario
        jg _itoa

        xor rcx, rcx                ; guardar la cantidad de palabras
        xor rdx, rdx                ; guarda el primer caracter de una palabra
        xor r8, r8                  ; guardar longitud de palabra
        xor r9, r9                  ; guarda el contenido del archivo
        xor r11, r11                ; guarda temporalmente los caracteres de una palabra
        xor ah, ah                  ; saber si es la primera letra
        mov al, ' '                 ; se usa para comparar cada caracter con el espacio en balnco
        mov ah, 0
        mov rcx, 0
        mov r8, 0
        mov r9, Contenido
        
        
        _proceso:
            xor r11, r11                        ; limpia la letra ya procesada
            cmp rbx, 0                          ; saber si ya se leyo todo el archivo
            je _chequeoUltimoCaracter
            cmp rbx, 1                          ; caso en el que hayan muchos espacios en el final del documento
            je _terminar
            cmp byte[r9], al                    ; chequea que no sea un espacio blanco
            je _palabraN
            mov r11b, byte[r9]                  ; almacena temporalmente un caracter
            cmp ah, 0                           ; saber si es la prmera letra
            je _primeraLetra
            mov [guardaPalabra+r8], r11b        ; almacena la palabra
            inc r9                              ; pasa al siguiente caracter
            inc r8                              ; posicionamiento del caracter en la palabra
            dec rbx                             ; recorre el archivo
            jmp _proceso    

        _palabraN:
            cmp r8, ' '             ; caso en el que hayan muchos espacios
            jne _Ordenar 
                        
            _cantidadPalabras:
                mov ah, 0                       ; el proximo caracter sera tomado como el primero de una palabra
                xor r8, r8
                mov [guardaPalabra], r8         ; vacia la variable donde se almaceno una palabra
                mov r8, ' '
                cmp byte[r9+1], al              ; por si hay un espacio despues de un espacio
                je _Espacios            
                inc rcx                         ; sube el contador de palabaras
                inc r9                          ; avanza al otro caracter
                dec rbx
                jmp _proceso

    _Espacios:                      ; si hay otro espacio no sube el contador de palabras
        inc r9
        dec rbx
        jmp _proceso

    _chequeoUltimoCaracter:         ; si el ultimo caracter no es un espacio agrega una palabra
        mov rbx, r14                ; pasa el tamano del archivo para recorrerlo con la siguiente letra
        cmp ah, 0
        je _ultimaLetra
        cmp byte[r9], al
        je _Ordenar2
        inc rcx                     ; incrementa el contador de palabras
        jmp _Ordenar2

    _terminar:                      ; caso cuando hay un espacio al final que no suba al contador de palabras
        cmp byte[r9], al
        je _Espacios
        mov r11b, byte[r9] 
        mov [guardaPalabra+r8], r11b
        inc r9
        inc r8
        dec rbx
        mov r11b, byte[r9] 
        mov [guardaPalabra+r8], r11b
        jmp _proceso

    _primeraLetra:                  ; almacenar la primera letra de una palabra para ordenarla alfabeticamente 
        xor r8, r8
        mov r8, 0                   
        xor rdx, rdx
        mov rdx, r11                ; almacenar la primera letra en rdx
        inc ah                      ; indicar que los proximos caracteres no son una primera letra
        jmp _proceso

    _Ordenar:
        cmp rdx, r12                ; comparar con las mayusculas
        je _muestraPalabra
        cmp rdx, r13                ; comparar con las minusculas
        je _muestraPalabra

        xor r8, r8
        mov r8, 0
        jmp _cantidadPalabras


    _muestraPalabra:                ; imprime la palabra almacenada
        call _imprimeSalto
        mov rax, 1
	    mov rdi, 1
	    mov rsi, guardaPalabra
	    mov rdx, r8
	    syscall

        xor rax, rax
        xor rsi, rsi
        xor rdx, rdx
        mov al, ' '                 ; pasa los valores necesitados para el funcionamiento del ciclo
        mov ah, 0

        jmp _cantidadPalabras

    _ultimaLetra:
        xor rdx, rdx
        mov rdx, r11
        inc rcx
        mov r8, 2
        jmp _Ordenar2
        

    _Ordenar2:
        cmp rdx, r12                ; comparar con las mayusculas
        je _muestraPalabra2
        cmp rdx, r13                ; comparar con las minusculas
        je _muestraPalabra2

        xor r8, r8
        mov r8, 0
        jmp _previa


    _muestraPalabra2:                ; imprime la palabra almacenada
        call _imprimeSalto
        mov rax, 1
	    mov rdi, 1
	    mov rsi, guardaPalabra
	    mov rdx, r8
	    syscall

        xor rax, rax
        xor rsi, rsi
        xor rdx, rdx
        mov al, ' '                 ; pasa los valores necesitados para el funcionamiento del ciclo
        mov ah, 0

        jmp _previa
    

    _itoa:                      ; prepara el resultado para mostrar en panatalla
        mov rax, rcx            ; aqui esta la cantidad de palabras
        xor rcx, rcx            ; vamos a poner el divisor
        
        xor r8, r8              ; movimientos
        xor r9, r9              ; iterar por 2da variable
        mov r9, 2
        mov rcx, 10             ; nuestro divisor
        
    .next:
        xor rdx, rdx            ; aqui vamos a guardar el residuo
        
        div rcx                 ; rax/rcx
        mov r8b, byte[tble+rdx]
        mov byte[palabras+r9], r8b
        dec r9
        cmp rax, 0              ; si llegamos a 0, no hay nada mas que dividir
        je _mostrarCantidad

        jmp .next


    _mostrarCantidad:           ; muestra la cantidad de palabras en decimal 
        call _imprimeSalto
        
        mov rax, 1
	    mov rdi, 1
	    mov rsi, mensaje
	    mov rdx, longitud
	    syscall

        call _imprimeSalto

        mov rax, 1
	    mov rdi, 1
	    mov rsi, palabras           ;imprime el resultado en pantalla
	    mov rdx, 4
	    syscall
        call _salir



