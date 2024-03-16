@ File: snake.s
@ Author: Kun Chang
        .equ SWI_CheckBlcak, 0x202    @check black button
        .equ  SWI_CheckBlue, 0x203    @check press Blue button
        .equ  SWI_DRAW_STRING, 0x204    @display a string on LCD
        .equ SWI_DRAW_INT, 0x205     @display an int on LCD
        .equ  SWI_CLEAR_DISPLAY, 0x206    @clear LCD
        .equ  SWI_DRAW_CHAR, 0x207    @display a char on LCD
        .equ SWI_Exit, 0x11
        .equ SWI_GetTicks, 0x6d   @get start time
        .equ LEFT_BLACK_BUTTON, 0x01    @bit patterns for black buttons
        .equ RIGHT_BLACK_BUTTON, 0x02
        .equ BLUE_KEY_00, 0x01 @button(0)
        .equ BLUE_KEY_01, 0x02 @button(1)
        .equ BLUE_KEY_02, 0x04 @button(2)
        .equ BLUE_KEY_03, 0x08 @button(3)
        .equ BLUE_KEY_04, 0x10 @button(4)
        .equ BLUE_KEY_05, 0x20 @button(5)
        .equ BLUE_KEY_06, 0x40 @button(6)
        .equ BLUE_KEY_07, 0x80 @button(7)
        .text
        .global _start

_start:
        @ initial
INITIAL:
        swi   SWI_CLEAR_DISPLAY
        mov   r7, #0       @Length - 1
        mov   r6, #4       @direction   Up--1; Down--2; Left--3; Right--4
        mov   r5, #0       @count cycles
        mov   r4, #0       @fruit count

        ldr   r3, =SC     @Score+5
        ldr   r1, [r3]
        mov   r1, #0
        strb  r1, [r3]

        ldr   r0, =AddressX     @x
        ldr   r1, [r0]
        mov   r3, #0
        strb  r3, [r1]        @ start X

        ldr   r0, =AddressY     @y
        ldr   r2, [r0]
        mov   r3, #8
        strb  r3, [r2]        @ start Y

        ldr   r0, =FruitX     @Fruit-x
        ldrb  r0, [r0]
        ldr   r1, =FruitY     @Fruit-x
        ldrb  r1, [r1]
        mov   r2, #'#
        swi   SWI_DRAW_CHAR



L1:     swi   SWI_CheckBlue
        cmp   r0, #BLUE_KEY_01    @Up
        beq   ONE
        cmp   r0, #BLUE_KEY_05    @Down
        beq   FIVE
        cmp   r0, #BLUE_KEY_04    @Left
        beq   FOUR
        cmp   r0, #BLUE_KEY_06    @Right
        beq   SIX
        bal   M1

ONE:    cmp   r6, #2        @ When move up, can't move down
        beq   M1
        mov   r6, #1
        bal   M1
FIVE:   cmp   r6, #1
        beq   M1
        mov   r6, #2
        bal   M1
FOUR:   cmp   r6, #4
        beq   M1
        mov   r6, #3
        bal   M1
SIX:    cmp   r6, #3
        beq   M1
        mov   r6, #4
        @bal   M1


M1:     cmp   r5, #5
        bne   CRUISE

        @ increase length

        bl    CGXOY
        cmp   r6, #0
        beq   OVER

        bl    CKFruit
        cmp   r4, #6
        beq   WIN

        mov   R5, #0
        add   r7, r7, #1
        @Write
        ldr   r3, =AddressX     @x
        ldr   r2, [r3]
        ldr   r3, =AddressY     @y
        ldr   r3, [r3]
        strb  r0, [r2,r7]        @ start X
        strb  r1, [r3,r7]        @ start Y

        ldr   r3, =SC     @Score+5
        ldr   r1, [r3]
        add   r1, r1, #5
        strb  r1, [r3]

        ldr   r3, =300
        bl    Wait

        bal   L1

CRUISE:

        @Read
        ldr   r3, =AddressX     @x
        ldr   r1, [r3]
        ldrb   r0, [r1]     @get X of toil
        ldr   r3, =AddressY     @y
        ldr   r1, [r3]
        ldrb   r1, [r1]     @get Y of toil

        mov   r2, #0X20
        swi   SWI_DRAW_CHAR

        bl    Flush

        bl    CGXOY
        cmp   r6, #0
        beq   OVER
        bl    CKFruit
        cmp   r4, #6
        beq   WIN


        @Write
        ldr   r3, =AddressX     @x
        ldr   r2, [r3]
        ldr   r3, =AddressY     @y
        ldr   r3, [r3]
        strb  r0, [r2,r7]        @ start X
        strb  r1, [r3,r7]        @ start Y

        add   r5, r5, #1        @count++

        ldr   r3, =300
        bl    Wait


        bal   L1


WIN:    swi   SWI_CLEAR_DISPLAY
        mov   r0, #12
        mov   r1, #5
        ldr   r2, =Win
        swi   SWI_DRAW_STRING

        mov   r0, #5
        mov   r1, #7
        ldr   r2, =Eat
        swi   SWI_DRAW_STRING

        mov   r0, #12
        mov   r1, #9
        ldr   r2, =Score
        swi   SWI_DRAW_STRING

        ldr   r3, =SC     @x
        ldr   r2, [r3]
        mov   r0, #19
        mov   r1, #9
        swi   SWI_DRAW_INT

        mov   r0, #1
        mov   r1, #11
        ldr   r2, =Restart
        swi   SWI_DRAW_STRING
        bal   CKBLK


OVER:   swi   SWI_CLEAR_DISPLAY
        mov   r0, #12
        mov   r1, #5
        ldr   r2, =Die
        swi   SWI_DRAW_STRING

        mov   r0, #12
        mov   r1, #7
        ldr   r2, =Score
        swi   SWI_DRAW_STRING

        ldr   r3, =SC     @x
        ldr   r2, [r3]
        mov   r0, #19
        mov   r1, #7
        swi   SWI_DRAW_INT

        mov   r0, #1
        mov   r1, #9
        ldr   r2, =Restart
        swi   SWI_DRAW_STRING

CKBLK:  swi   SWI_CheckBlcak
        cmp   r0, #LEFT_BLACK_BUTTON
        beq   INITIAL
        bal   CKBLK

        swi   SWI_Exit


@ ====== Check Fruit (r0:x, r1:y)
@ Determining whether fruit is obtained
CKFruit:
        stmfd sp!,{r0-r3,lr}

        @Read
        ldr   r2, =FruitX     @Fruit-x
        ldrb  r2, [r2, r4]
        cmp   r0, r2
        bne   XCKFruit
        ldr   r3, =FruitY     @Fruit-x
        ldrb  r3, [r3, r4]
        cmp   r1, r3
        bne   XCKFruit

        @Clear old fruit
        mov   r0, r2
        mov   r1, r3
        mov   r2, #'*       @*
        swi   SWI_DRAW_CHAR

        add   r4, r4, #1

        ldr   r3, =SC     @Score+10
        ldr   r1, [r3]
        add   r1, r1, #10
        strb  r1, [r3]

        @Display new fruit
        ldr   r0, =FruitX     @Fruit-x
        ldrb  r0, [r0, r4]
        ldr   r1, =FruitY     @Fruit-x
        ldrb  r1, [r1, r4]
        mov   r2, #'#
        swi   SWI_DRAW_CHAR

XCKFruit:
        ldmfd sp!,{r0-r3,pc}
@ ===========================================================

@ ====== Flush Memory (len:r7)
@ Change coordinates of snake's body
Flush:
        stmfd sp!,{r0-r7,lr}

        mov   r5, #0
LP1:    cmp   r5, r7
        bge   XFlush            @r5 >= r7

        @Read
        ldr   r3, =AddressX     @x
        ldr   r2, [r3]
        add   r6, r5, #1
        ldrb   r0, [r2, r6]     @get X+1
        ldr   r3, =AddressY     @y
        ldr   r3, [r3]
        ldrb   r1, [r3, r6]    @get Y+1

        @Write
        strb  r0, [r2,r5]        @ start X
        strb  r1, [r3,r5]        @ start Y

        add   r5, r5, #1
        bal   LP1
XFlush:
        ldmfd sp!,{r0-r7,pc}
@ ===========================================================

@ ====== Change XoY (x:r0, y:r1, dic:r6)
@ Change coordinates according to direction
CGXOY:
        stmfd sp!,{lr}
        @Read
        ldr   r3, =AddressX     @x
        ldr   r1, [r3]
        ldrb   r0, [r1, r7]     @get X of head
        ldr   r3, =AddressY     @y
        ldr   r1, [r3]
        ldrb   r1, [r1, r7]     @get Y of head

        cmp   r6, #1
        beq   UP
        cmp   r6, #2
        beq   DOWN
        cmp   r6, #3
        beq   LEFT
        @ default direction: right
        cmp   r0, #39
        beq   GG
        add   r0, r0, #1
        bl    Collide
        bal   XCGXOY

UP:     cmp   r1, #0
        beq   GG
        sub   r1, r1, #1
        bl    Collide
        bal   XCGXOY    @draw new point
DOWN:   cmp   r1, #14
        beq   GG
        add   r1, r1, #1
        bl    Collide
        bal   XCGXOY
LEFT:   cmp   r0, #0
        beq   GG
        sub   r0, r0, #1
        bl    Collide

XCGXOY:
        mov   r2, #'*
        swi   SWI_DRAW_CHAR
        ldmfd sp!,{pc}

GG:     mov   r6, #0
        ldmfd sp!,{pc}

@ ===========================================================
@ ====== Search (x:r0, y:r1, len:r7)
@ Check whether collide
Collide:
        stmfd sp!,{r0-r5,r7,lr}

        mov   r3, r0        @r3 <-- x
        mov   r4, r1        @r4 <-- y

        mov   r5, #0
LP2:    cmp   r5, r7
        bge   XCollide            @r5 >= r7

        @Read
        ldr   r2, =AddressX     @x
        ldr   r2, [r2]
        ldrb   r0, [r2, r5]     @get X

        cmp   r0, r3
        bne   LP3

        ldr   r2, =AddressY     @y
        ldr   r2, [r2]
        ldrb   r1, [r2, r5]    @get Y

        cmp   r1, r4
        beq   CED

LP3:
        add   r5, r5, #1
        bal   LP2
XCollide:
        ldmfd sp!,{r0-r5,r7,pc}

CED:    mov   r6, #0
        ldmfd sp!,{r0-r5,r7,pc}
@ ===========================================================
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
Win:    .asciz  "!!!WIN!!!"
Eat:    .asciz  "You have eaten all Fruits!"
Die:    .asciz  "You died!"
Score:  .asciz  "Score:"
Restart:.asciz  "Press left black button to restart."
SC:     .word 0
FruitX:
        .byte 29
        .byte 10
        .byte 31
        .byte 32
        .byte 24
FruitY:
        .byte 6
        .byte 7
        .byte 5
        .byte 14
        .byte 10
AddressX:   .word 0x5000
AddressY:   .word 0x6000
        .end
