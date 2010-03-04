; move a dot with the joystick by Szymon "b.YISK" Barczak based on Kirk Israel's code

	processor 6502
	include vcs.h
	include macro.h
	org $F000

YPosFromBot = $80;
VisibleMissileLine = $81;
Figurelock = $82;
COLUBK2 = $83;
COLUP02	= $84;

Start
	CLEAN_START

	lda #$70
	sta COLUBK
	sta COLUBK2
	lda #10
	sta COLUP0
	sta COLUP02
	lda #50
	sta YPosFromBot	;Initial Y Position
	lda #$30
	sta NUSIZ0	;Quad Width
	lda #2
	sta Figurelock

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

;TestLock
;	lda Lock
;	cmp #1
;	bne TestFigurelock
;	jsr WaitForVblankEnd 
;	dec Lockcounter
;	bne MainLoop
;	lda #6
;	sta Lockcounter
;	inc Lock
;	jmp MainLoop

TestFigurelock
	lda Figurelock
	cmp #1
	bne ChangePosition
	jmp ChangeColor

ChangePosition
	ldx #0
	stx HMM0
	jsr TestLeft
	bne NoLeft
	ldx #$10
	stx HMM0
	jmp WaitForVblankEnd 
NoLeft	jsr TestRight
	bne NoRight
	ldx #$F0
	stx HMM0 
	jmp WaitForVblankEnd 
NoRight	jsr TestDown
	bne NoDown
	inc YPosFromBot
	inc YPosFromBot
	jmp WaitForVblankEnd 
NoDown	jsr TestUp
	bne NoUp
	dec YPosFromBot
	dec YPosFromBot
	jmp WaitForVblankEnd 
NoUp	lda INPT4	
	bmi Jump
	dec Figurelock
	
Jump
	jmp WaitForVblankEnd


ChangeColor
	jsr TestLeft
	bne NoLeft2
	dec COLUP02
	lda COLUP02
	sta COLUP0
	jmp WaitForVblankEnd 
NoLeft2	jsr TestRight
	bne NoRght2
	inc COLUP02
	lda COLUP02
	sta COLUP0
	jmp WaitForVblankEnd 
NoRght2 jsr TestDown
	bne NoDown2
	dec COLUBK2
	lda COLUBK2
	sta COLUBK
	jmp WaitForVblankEnd 
NoDown2	jsr TestUp
	bne NoUp2
	inc COLUBK2
	lda COLUBK2
	sta COLUBK
	jmp WaitForVblankEnd 
NoUp2	lda INPT4
	bmi Jump2
	inc Figurelock
Jump2
	jmp WaitForVblankEnd 

TestLeft
	lda #%01000000
	bit SWCHA
	rts

TestRight
	lda #%10000000
	bit SWCHA
	rts	

TestDown
	lda #%00010000	;Down?
	bit SWCHA
	rts

TestUp
	lda #%00100000	;Up?
	bit SWCHA
	rts

;EnableLock
;	dec Figurelock
;	jmp TestLock

;Other stuff

;	lda INPT4		;read button input
;	bmi ButtonNotPressed	;skip if button not pressed
;	lda YPosFromBot		;must be pressed, get YPos
;	sta COLUBK		;load into bgcolor
;	lda #2
;	sta DoLockLoop
;	dec WidCnt
;	bne ButtonNotPressed
;changes	lda WidVal
;	cmp #1
;	beq changeto30
;changeto20	lda #1
;	sta WidVal
;	lda #$20
;	sta NUSIZ0
;	jmp reset
;changeto30	lda #2
;	sta WidVal
;	lda #$30
;	sta NUSIZ0
;reset	lda #25
;	sta WidCnt
;ButtonNotPressed



WaitForVblankEnd
	lda INTIM
	bne WaitForVblankEnd
	ldy #227		; changed from 192 to make it PAL
	sta WSYNC
	sta VBLANK

	sta WSYNC
	sta HMOVE

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
	jmp MainLoop

	org $FFFC
	.word Start
	.word Start

