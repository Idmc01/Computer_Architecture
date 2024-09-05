%macro salida 2
    mov edx, %1     ;EDX=lon. de la cadena
    mov ecx, %2      ;ECX=cadena a imprimir
    mov ebx, 1            ;EBX=manejador de fichero (STDOUT)
    mov eax, 4            ;EAX=funcion sys_write() del kernel
    int 0x80              ;interrupc. 80 (llamada al kernel)
    %endmacro 
;El archivo debe estar en la misma carpeta que el codigo para solo poner el nombre
;de otra manera debera especificar la ruta del archivo de prueba
;se adjunto un archivo de prueba para la tarea llamado prueba.txt
section .data
    mensajeA     db "Inserte el nombre del archivo con el formato 'nombre.txt': ", 0xA
    longitudA    equ $ - mensajeA

    mensaje     db "Cantidad de palabras: ", 0xA
    longitud    equ $ - mensaje

    mensajeErrorO db "El texto supera la cantidad maxima de 1024 caracteres.", 0xA
    longitudErrorO    equ $ - mensajeErrorO

    mensajeErrorA db "Se produjo un error con el archivo.", 0xA
    longitudErrorA    equ $ - mensajeErrorA

    salto db 0xA, 0xD
    saltolen equ $-salto

    ;filename db 'prueba.txt', 0

    tamnoContenido equ 2048

    tble db "0123456789ABCDEF", 0xA


section .bss

    Contenido resb tamnoContenido
    palabras resb 10 
    auxili resb 2048
    nombreArchivo resb 100
    nombreArchivo2 resb 100


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
        cmp rbx, 1024
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
    mov rcx, 0
    _NombreArchivo:
        mov r10b, byte[rsi]
        cmp byte[rsi], 0xA
        je _AbrirArchivo
        mov [nombreArchivo2+rcx], r10b
        inc rsi
        inc rcx
        jmp _NombreArchivo


    _AbrirArchivo:
        ; abrir el archivo
        mov rax, 2       ; numero de la funcion 'open'
        mov rdi, nombreArchivo2
        mov rsi, 0       ; modo de apertura: lectura
        mov rdx, 0       ; permisos: por defecto
        syscall
        mov r10, rax      ; guardar el descriptor de archivo en r10

        cmp r10, 0
        jl _ErrorArchivo

        ; leer el archivo en el bufer
        mov rax, 0       ; numero de la funcion 'read'
        mov rdi, r10      ; descriptor de archivo
        mov rsi, Contenido
        mov rdx, tamnoContenido
        syscall
        mov rbx, rax     ; cantidad de bytes leidos

        call _chequeoCaracteres

    _previa:
        mov rsi, Contenido          ; el contenido del archivo
        xor rcx, rcx                ; guardar la cantidad de palabras
        mov al, ' '                 ; se usa para comparar cada caracter con el espacio en balnco
        mov rcx, 0
        _proceso:
            cmp rbx, 0              ; saber si ya se leyo todo el archivo
            je _chequeoUltimoCaracter
            cmp rbx, 1              ; caso en el que hayan muchos espacios en el final del documento
            je _terminar
            cmp byte[rsi], al       ; chequea que no sea un espacio blanco
            je _palabraN
            inc rsi                 ; pasa al siguiente caracter
            dec rbx                 
            jmp _proceso

        _palabraN: 
            cmp byte[rsi+1], al     ; por si hay un espacio despues de un espacio
            je _Espacios            
            inc rcx                 ; sube el contador de palabaras
            inc rsi                 ; avanza al otro caracter
            dec rbx
            jmp _proceso

    _Espacios:                      ; si hay otro espacio no sube el contador de palabras
        inc rsi
        dec rbx
        jmp _proceso

    _chequeoUltimoCaracter:         ; si el ultimo caracter no es un espacio agrega una palabra
        cmp byte[rsi], al
        je _itoa
        inc rcx                     ; incrementa el contador de palabras
        jmp _itoa

    _terminar:                      ; caso cuando hay un esoacio al final que no suba al contador de palabras
        cmp byte[rsi], al
        je _Espacios
        inc rsi
        dec rbx
        jmp _proceso

    _itoa:                      ; prepara el resultado para mostrar en panatalla
        mov rax, rcx            ; aqui esta la cantidad de palabras
        xor rcx, rcx ;vamos a poner el divisor
        
        xor r8, r8 ;movimientos
        xor r9, r9 ;iterar por 2da variable
        mov r9, 2
        mov rcx, 10 ;nuestro divisor
        
    .next:
        xor rdx, rdx ;aqui vamos a guardar el residuo
        
        div rcx     ;rax/rcx
        mov r8b, byte[tble+rdx]
        mov byte[palabras+r9], r8b
        dec r9
        cmp rax, 0   ;si llegamos a 0, no hay nada mas que dividir
        je _mostrarCantidad

        jmp .next


    _mostrarCantidad:
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


