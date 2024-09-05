.data
str: .asciz "hola mundo!\n"
len = .-str

.text
.global _start
_start:
mov r0, #1
ldr r1, =str
ldr r2, =len
mov r7, #4
swi 0

mov r7, #1
swi 0
