@ File: LES.s
@ Author: Kun Chang
        .equ SEG_A,0x80   @patterns for 8 segment display
        .equ SEG_B,0x40
        .equ SEG_C,0x20
        .equ SEG_D,0x08
        .equ SEG_E,0x04
        .equ SEG_F,0x02
        .equ SEG_G,0x01
        .equ SEG_P,0x10
        .equ state1, 0x00
        .equ state2, 0xFF
        .equ SWI_CheckBlcak, 0x202    @check black button
        .equ SWI_SETSEG8, 0x200   @display on 8 Segment
        .equ SWI_SETLED, 0x201    @LEDs on/off
        .equ SWI_GetTicks, 0x6d   @get start time
        .equ LEFT_LED, 0x01   @bit patterns for LED lights
        .equ RIGHT_LED, 0X02
        .equ LEFT_BLACK_BUTTON, 0x01    @bit patterns for black buttons
        .equ RIGHT_BLACK_BUTTON, 0x02
        .text
        .global _start

_start:
        mov   r2, #state1
LB1:
        cmp   r2, #state2
        beq   ST2       @1:2
        @state1 2:1
        mov   r0, #LEFT_LED
        swi   SWI_SETLED
        ldr   r3, =1000     @delay  1000ms
        bl    Wait
        mov   r0, #RIGHT_LED
        swi   SWI_SETLED
        ldr   r3, =500      @delay  500ms
        bl    Wait
        bal   CHECK

ST2:    @state2 1:2
        mov   r0, #LEFT_LED
        swi   SWI_SETLED
        ldr   r3, =500      @delay  500ms
        bl    Wait
        mov   r0, #RIGHT_LED
        swi   SWI_SETLED
        ldr   r3, =1000      @delay  1000ms
        bl    Wait

CHECK:  swi   SWI_CheckBlcak
        cmp   r0, #0        @no button pressed
        beq   LB1
        cmp   r0, #RIGHT_BLACK_BUTTON
        beq   RD1

        @default state1
        ldr   r0, =SEG_B|SEG_C   @1
        swi   SWI_SETSEG8
        mov   r2, #state1
        bal   LB1

        @state2
RD1:    ldr   r0, =SEG_A|SEG_B|SEG_F|SEG_E|SEG_D   @2
        swi   SWI_SETSEG8
        mov   r2, #state2

        bal   LB1


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
        .end
