@ File: snake.s
        .equ  SWI_CLEAR_DISPLAY, 0x206    @clear LCD
        .equ  SWI_DRAW_CHAR, 0x207    @display a char on LCD

        .equ SWI_GetTicks, 0x6d   @get start time

        .equ BLUE_KEY_00, 0x01 @button(0)
        .equ BLUE_KEY_01, 0x02 @button(1)
        .equ BLUE_KEY_02, 0x04 @button(2)
        .equ BLUE_KEY_03, 0x08 @button(3)
        .equ BLUE_KEY_04, 0x10 @button(4)
        .equ BLUE_KEY_05, 0x20 @button(5)
        .equ BLUE_KEY_06, 0x40 @button(6)
        .equ BLUE_KEY_07, 0x80 @button(7)
        .equ BLUE_KEY_00, 1<<8 @button(8) - different way to set
        .equ BLUE_KEY_01, 1<<9 @button(9)
        .equ BLUE_KEY_02, 1<<10 @button(10)
        .equ BLUE_KEY_03, 1<<11 @button(11)
        .equ BLUE_KEY_04, 1<<12 @button(12)
        .equ BLUE_KEY_05, 1<<13 @button(13)
        .equ BLUE_KEY_06, 1<<14 @button(14)
        .equ BLUE_KEY_07, 1<<15 @button(15)
        .text
        .global _start

_start:
        @ initial
        swi   SWI_CLEAR_DISPLAY
        mov   r7, #0       @Length
        mov   r6, #4       @direction   Up--1; Down--2; Left--3; Right--4
        mov   r5, #0       @count cycles

        ldr   r0, =AddressX     @x
        ldr   r1, [r0]

        ldr   r0, =AddressY     @y
        ldr   r2, [r0]

        mov   r3, #20
        strb  r3, [r1]        @ start X
        mov   r3, #8
        strb  r3, [r2]        @ start Y


L1:
        @Read
        ldr   r3, =AddressX     @x
        ldr   r1, [r3]
        ldrb   r0, [r1, r7]     @get X of head
        ldr   r3, =AddressY     @y
        ldr   r1, [r3]
        ldrb   r1, [r1, r7]     @get Y of head

        cmp   r5, #5
        bne   CRUISE
        @ increase length
        add   r7, r7, #1
        bl    CGXOY
        mov   r2, #'*
        swi   SWI_DRAW_CHAR


CRUISE: mov   r2, #0X20
        swi   SWI_DRAW_CHAR

        bl    CGXOY

DR:     mov   r2, #'*
        swi   SWI_DRAW_CHAR

        @Write
        ldr   r3, =AddressX     @x
        ldr   r2, [r3]
        ldr   r3, =AddressY     @y
        ldr   r3, [r3]
        strb  r0, [r2,r7]        @ start X
        strb  r1, [r3,r7]        @ start Y

        add   r5, r5, #1        @count++

        @ldr   r3, =500
        @bl    Wait

        cmp   r5, #5          @whether increase
        bne   RU
        add   r7, r7, #1      @increase length
        mov   r5, #0

RU:     add   r5, r5, #1


        bAl   L1



@ ====== Change XoY (x:r0, y:r1, dic:r6)
@ Change coordinates according to direction
CGXOY:
        stmfd sp!,{lr}
        cmp   r6, #1
        beq   UP
        cmp   r6, #2
        beq   DOWN
        cmp   r6, #3
        beq   LEFT
        @ default direction: right
        add   r0, r0, #1
        bal   XCGXOY

UP:     sub   r1, r1, #1
        bal   XCGXOY    @draw new point
DOWN:   add   r1, r1, #1
        bal   XCGXOY
LEFT:   sub   r0, r0, #1
XCGXOY:
        ldmfd sp!,{pc}



@ ====== Wait (Dealy:r3) wait for r3 milliseconds
@ Delays for the amount of time stored in r3 for a 15-bit timer
Wait:
        stmfd sp!,{r0-r5,lr}
        ldr   r4, =0x00007FFF   @mask for 15-bit timer
        swi   SWI_GetTicks
        and   r1,r0,r4
Wloop:
        swi   SWI_GetTicks
        and   r2,r0,r4
        cmp   r2,r1
        blt   Roll    @ T2 - T1 < 0
        sub   r5,r2,r1
        bal   CmpLoop   @ T2 - T1 >= 0
Roll:
        sub   r5,r4,r1
        add   r5,r5,r2
CmpLoop:
        cmp   r5,r3   @is elapsed time < delay?
        blt   Wloop
XWait:
        ldmfd sp!,{r0-r5,pc}
@ ===========================================================

        .data
Length: .word 0
AddressX:   .word 0x2000
AddressY:   .word 0x6000
        .end
