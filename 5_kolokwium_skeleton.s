	AREA	MAIN_CODE, CODE, READONLY
		GET		6_LPC213x.s
		
		ENTRY
__main
__use_two_region_memory
		EXPORT			__main
		EXPORT			__use_two_region_memory
		
DIGIT_0 RN R8
DIGIT_1 RN R9
DIGIT_2 RN R10
DIGIT_3 RN R11
CURRENT_DIGIT RN R12
	;ustawienie pinów sterujacych wyswietlaczem na wyjsciowe	
	LDR     R4, =IODIR0
    LDR     R5, =(1<<16)|(1<<17)|(1<<18)|(1<<19)
    STR     R5, [R4]

	LDR     R4, =IODIR1
    LDR     R5, =(1<<16)|(1<<17)|(1<<18)|(1<<19)|(1<<20)|(1<<21)|(1<<22)|(1<<23)
    STR     R5, [R4]
	;inicjalizacja licznika dekadowego
	mov DIGIT_0, #0
	mov DIGIT_1, #0
	mov DIGIT_2, #0
	mov DIGIT_3, #0
	;wyzerowanie licznika cyfr
	mov CURRENT_DIGIT, #0
		
main_loop
	;wygaszenie wyswietlacza przed zmiana cyfry
	LDR R4, =IOCLR0
    LDR R5, =(1<<16)|(1<<17)|(1<<18)|(1<<19)
    STR R5, [R4]

	LDR R4, =IOCLR1
    LDR R5, =(1<<16)|(1<<17)|(1<<18)|(1<<19)|(1<<20)|(1<<21)|(1<<22)|(1<<23)
    STR R5, [R4]	
	;wlaczenie cyfry o numerze podanym w CURR_DIG
	LDR R4, =IOSET0
    LDR R5, =(1<<19)
	LSR R5, R5, CURRENT_DIGIT
    STR R5, [R4]
	;R6 <= DIGIT_X, gdzie X=CURR_DIG
	cmp	CURRENT_DIGIT, #0
	moveq R6, DIGIT_0
	cmp	CURRENT_DIGIT, #1
	moveq R6, DIGIT_1
	cmp	CURRENT_DIGIT, #2
	moveq R6, DIGIT_2
	cmp	CURRENT_DIGIT, #3
	moveq R6, DIGIT_3
	;zamiana R6 na kod siedmiosegmentowy
	ADR R4, SegCode
    add R4, R6
    LDRB R6, [R4]
	;wpisanie kodu siedmiosegmentowego R6 do segmentow
	LDR R4, =IOSET1
	LSL R6, R6, #16
    STR R6, [R4]
	;inkrementacja licznika dekadowego (DIGIT_0 ... DIGIT_3)
	add DIGIT_0, #1
	cmp DIGIT_0, #10
	moveq DIGIT_0, #0
	addeq DIGIT_1, #1
	
	cmp DIGIT_1, #10
	moveq DIGIT_1, #0
	addeq DIGIT_2, #1
	
	cmp DIGIT_2, #10
	moveq DIGIT_2, #0
	addeq DIGIT_3, #1
	
	cmp DIGIT_3, #10
	moveq DIGIT_3, #0
	;inkrementacja licznika cyfr modulo 4
	add CURRENT_DIGIT, #1
	cmp CURRENT_DIGIT, #4
	moveq CURRENT_DIGIT, #0
	;opoznienie
	ldr R0, = 40
	bl delay_in_ms
		
	b	main_loop
; delay_in_ms 
delay_in_ms
	ldr R1, = 3000
	mul R0, R1, R0
Loop
	subs R0, #1
	bne Loop
	
	bx lr
; tablica kodów siedmiosegmentowych  
SegCode DCB 0x3f,0x06,0x5B,0x4F,0x66,0x6d,0x7D,0x07,0x7f,0x6f

	END