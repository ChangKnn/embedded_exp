@ File: helloworld.s
@ Author: Kun Chang
        .equ SWI_PrStr, 0x69
        .equ SWI_Exit, 0x11
        .equ Stdout, 1
        .text
        .global _start

_start:
@ Print "Hello world!"
      mov r0, #Stdout
      ldr r1, =Message1
      swi SWI_PrStr

      swi SWI_Exit  @ stop executing: end of program
      .data
Message1: .asciz "Hello World!"
      .end
