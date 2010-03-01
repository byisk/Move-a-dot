; move a dot with the joystick by Szymon "b.YISK" Barczak based on Kirk Israel's code

	processor 6502
	include vcs.h
	include macro.h
	org $F000

YPosFromBot = $80;
VisibleMissileLine = $81;
WidVal = $82;
WidCnt = $83;

Start
	CLEAN_START

	lda #$70
	sta COLUBK
	lda #10
	sta COLUP0
	lda #80
	sta YPosFromBot	;Initial Y Position
	lda #$20
	sta NUSIZ0	;Quad Width
	lda #5
	sta WidCnt
	lda #1
	sta WidVal

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


;Checking vertical position changes

	lda #%00010000	;Down?
	bit SWCHA
	bne SkipMoveDown
	inc YPosFromBot
	inc YPosFromBot
	inc YPosFromBot
SkipMoveDown

	lda #%00100000	;Up?
	bit SWCHA
	bne SkipMoveUp
	dec YPosFromBot
	dec YPosFromBot
	dec YPosFromBot
SkipMoveUp

;assum horiz speed will be zero
	ldx #0

	lda #%01000000	;Left?
	bit SWCHA
	bne SkipMoveLeft
	ldx #$10		;a 1 in the left nibble means go left
SkipMoveLeft

	lda #%10000000	;Right?
	bit SWCHA
	bne SkipMoveRight
	ldx #$F0		;a -1 in the left nibble means go right...
SkipMoveRight
			;(in 4 bits, using "two's complement
			; notation", binary 1111 = decimal -1
			; (which we write there as hex "F" --
			; remember?))


	stx HMM0	;set the move for missile 0


;Other stuff

	lda INPT4		;read button input
	bmi ButtonNotPressed	;skip if button not pressed
	lda YPosFromBot		;must be pressed, get YPos
	sta COLUBK		;load into bgcolor
	dec WidCnt
	bne ButtonNotPressed
changes	lda WidVal
	cmp #1
	beq changeto30
changeto20	lda #1
	sta WidVal
	lda #$20
	sta NUSIZ0
	jmp reset
changeto30	lda #2
	sta WidVal
	lda #$30
	sta NUSIZ0
reset	lda #25
	sta WidCnt
ButtonNotPressed



WaitForVblankEnd
	lda INTIM
	bne WaitForVblankEnd
	ldy #227		; changed from 192 to make it PAL
	sta WSYNC
	sta VBLANK

	sta WSYNC
	sta HMOVE

;Main scanline loop

ScanLoop
	sta WSYNC

CheckActivateMissile
	cpy YPosFromBot
	bne SkipActivateMissile
	lda #18
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

