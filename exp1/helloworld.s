@ File: helloworld.s
        .equ SWI_PrStr, 0x69
        .equ SWI_Exit, 0x11
        .equ Stdout, 1
        .text
        .global _start

_start:
@ Print "Hello world!"
      mov R0, #Stdout
      ldr R1, =Message1
      swi SWI_PrStr

      swi SWI_Exit  @ stop executing: end of program
      .data
Message1: .asciz "Hello World!"
      .end
