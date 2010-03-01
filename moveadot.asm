; move a dot with the joystick by Kirk Israel

	processor 6502
	include vcs.h
	include macro.h
	org $F000

YPosFromBot = $80;
VisibleMissileLine = $81;

;generic start up stuff...
Start
	CLEAN_START


	lda #$00
	sta COLUBK	;start with black background
	lda #66
	sta COLUP0
;Setting some variables...
	lda #80
	sta YPosFromBot	;Initial Y Position

	lda #$20
	sta NUSIZ0	;Quad Width


;VSYNC time
MainLoop
	lda #2
	sta VSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	lda #43
	sta TIM64T
	lda #0
	sta VSYNC


;Main Computations; check down, up, left, right
;general idea is to do a BIT compare to see if
;a certain direction is pressed, and skip the value
;change if we're not moving that way

;
;Not the most efficient code, but gets the job done,
;including diagonal movement
;

; for up and down, we INC or DEC
; the Y Position

	lda #%00010000	;Down?
	bit SWCHA
	bne SkipMoveDown
	inc YPosFromBot
SkipMoveDown

	lda #%00100000	;Up?
	bit SWCHA
	bne SkipMoveUp
	dec YPosFromBot
SkipMoveUp

; for left and right, we're gonna
; set the horizontal speed, and then do
; a single HMOVE.  We'll use X to hold the
; horizontal speed, then store it in the
; appropriate register


;assum horiz speed will be zero
	ldx #0

	lda #%01000000	;Left?
	bit SWCHA
	bne SkipMoveLeft
	ldx #$10	;a 1 in the left nibble means go left
SkipMoveLeft

	lda #%10000000	;Right?
	bit SWCHA
	bne SkipMoveRight
	ldx #$F0	;a -1 in the left nibble means go right...
SkipMoveRight
			;(in 4 bits, using "two's complement
			; notation", binary 1111 = decimal -1
			; (which we write there as hex "F" --
			; remember?))


	stx HMM0	;set the move for missile 0


; while we're at it, change the color of the background
; if the button is pressed (making sure D6 of VBLANK has
; appropriately set above) We'll set the background color
; to the vertical position, since that will be changing
; a lot but we can still control it.

	lda INPT4		;read button input
	bmi ButtonNotPressed	;skip if button not pressed
	lda YPosFromBot		;must be pressed, get YPos
	sta COLUBK		;load into bgcolor
ButtonNotPressed



WaitForVblankEnd
	lda INTIM
	bne WaitForVblankEnd
	ldy #191
	sta WSYNC
	sta VBLANK

	sta WSYNC
	sta HMOVE

;main scanline loop...
;
;(this probably ends the "new code" section of today's
; lesson...)


ScanLoop
	sta WSYNC

; here the idea is that VisibleMissileLine
; is zero if the line isn't being drawn now,
; otherwise it's however many lines we have to go

CheckActivateMissile
	cpy YPosFromBot
	bne SkipActivateMissile
	lda #8
	sta VisibleMissileLine
SkipActivateMissile

;turn missile off then see if it's turned on
	lda #0
	sta ENAM0
;
;if the VisibleMissileLine is non zero,
;we're drawing it
;
	lda VisibleMissileLine
	beq FinishMissile
IsMissileOn
	lda #2
	sta ENAM0
	dec VisibleMissileLine
FinishMissile


	dey
	bne ScanLoop

	lda #2
	sta WSYNC
	sta VBLANK
	ldx #30
OverScanWait
	sta WSYNC
	dex
	bne OverScanWait
	jmp  MainLoop

	org $FFFC
	.word Start
	.word Start

