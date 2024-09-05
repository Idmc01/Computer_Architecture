.data
str1: .asciz "Seleccione una opción de mensaje\na. hola mundo!!!\nb. Feliz día del amor y la amistad!!!\nc. Feliz Navidad!!!\nd. Feliz dia de la independencia!!!\ne. Otro (ingrese su propio mensaje)\nf. Finalizar programa\n"
len1 = .-str1
str2: .asciz "hola mundo!!!\n"
len2 = .-str2
str3: .asciz "Feliz día del amor y la amistad!!!\n"
len3 = .-str3
str4: .asciz "Feliz Navidad!!!\n"
len4 = .-str4
str5: .asciz "Feliz dia de la independencia!!!\n"
len5 = .-str5
str6: .asciz "Desea imprimir otro mensaje? \na. Sí\nb. No\nSeleccióne una opción\n"
len6 = .-str6
str7: .asciz "Escriba el mensaje que desea mostrar(maximo 20 letras, cuentan espacios):\n"
len7 = .-str7
input1: .asciz "Seleccione una opción:\n"
leninput1 = .-input1
opcion: .word 0
opcion2: .word 0
mensaje:.space 100
.text
.global _start
_start:
mov r0, #1
ldr r1, =str1
ldr r2, =len1
mov r7, #4
swi 0

mov r0, #1
ldr r1, =input1
ldr r2, =leninput1
mov r7, #4
swi 0

ldr r0, =0
ldr r1, =opcion
ldr r2, =4
mov r7, #3

swi 0


ldrb r1, [r1]
ldr r2, =97
cmp r1, r2
beq imprime1


ldr r2, =98
cmp r1,r2
beq imprime2

ldr r2, =99
cmp r1,r2
beq imprime3


ldr r2, =100
cmp r1,r2
beq imprime4


ldr r2, =101
cmp r1,r2
beq imprimemensaje


ldr r2, =102
cmp r1,r2
beq salir

imprime1:
mov r0, #1
ldr r1, =str2
ldr r2, =len2
mov r7, #4
swi 0
b ciclo

imprime2:
mov r0, #1
ldr r1, =str3
ldr r2, =len3
mov r7, #4
swi 0
b ciclo

imprime3:
mov r0, #1
ldr r1, =str4
ldr r2, =len4
mov r7, #4
swi 0
b ciclo

imprime4:
mov r0, #1
ldr r1, =str5
ldr r2, =len5
mov r7, #4
swi 0
b ciclo

imprimemensaje:
mov r0, #1
ldr r1, =str7
ldr r2, =len7
mov r7, #4
swi 0

mov r7, #3
mov r0, #0
mov r2, #100
ldr r1, =mensaje
swi 0

mov r7,#4
mov r0, #1
mov r2, #100
ldr r1, =mensaje
swi 0
mov r7, #1
b ciclo

ciclo:
mov r0, #1
ldr r1, =str6
ldr r2, =len6
mov r7, #4
;swi 0
mov r7, #3
ldr r0, =0
ldr r1, =opcion2
ldr r2, =4
swi 0

ldrb r1, [r1]
ldr r2, =97
cmp r1, r2
beq _start
cmp r1,r2
beq salir
;b salir



salir:
mov r7, #1
mov r0, #0
swi 0
