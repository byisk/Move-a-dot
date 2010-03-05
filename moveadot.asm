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
Lock = $85;
Lockcounter = $86;
SmallSquareSwitch = $87;
SquareHeight = $88;
COLUBKBACKUPED = $89;

Start
	CLEAN_START

	lda #$70
	sta COLUBK
	sta COLUBK2
	sta COLUBKBACKUPED
	lda #10
	sta COLUP0
	sta COLUP02
	lda #50
	sta YPosFromBot	
	lda #$30
	sta NUSIZ0
	lda #2
	sta Figurelock
	sta Lock
	sta Lockcounter
	sta SmallSquareSwitch
	lda #18
	sta SquareHeight

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

TestLock
	ldx #0
	stx HMM0
	lda Lock
	cmp #1
	bne TestFigurelock
	dec Lockcounter
	beq DisableLock
	jmp WaitForVblankEnd

DisableLock
	inc Lock
	jmp WaitForVblankEnd

TestFigurelock
	lda Figurelock
	cmp #1
	bne ChangePosition
	jmp ChangeColor

ChangePosition
	jsr TestLeft
	bne NoLeft
	ldx #$20
	stx HMM0
	jmp EnableLockForPositionChanges 
NoLeft	jsr TestRight
	bne NoRight
	ldx #$E0
	stx HMM0 
	jmp EnableLockForPositionChanges
NoRight	jsr TestDown
	bne NoDown
	inc YPosFromBot
	inc YPosFromBot
	jmp EnableLockForPositionChanges
NoDown	jsr TestUp
	bne NoUp
	dec YPosFromBot
	dec YPosFromBot
	jmp EnableLockForPositionChanges
NoUp	lda INPT4	
	bmi Jump
	dec Figurelock

EnableLockForPositionChanges
	lda #1
	sta Lockcounter
	dec Lock

Jump
	jmp WaitForVblankEnd

ChangeColor
	jsr TestLeft
	bne NoLeft2
	dec COLUP02
	lda COLUP02
	sta COLUP0
	jmp EnableLockForColorChanges
NoLeft2	jsr TestRight
	bne NoRght2
	inc COLUP02
	lda COLUP02
	sta COLUP0
	jmp EnableLockForColorChanges
NoRght2 jsr TestDown
	bne NoDown2
	dec COLUBK2
	lda COLUBK2
	sta COLUBK
	jmp EnableLockForColorChanges
NoDown2	jsr TestUp
	bne NoUp2
	inc COLUBK2
	lda COLUBK2
	sta COLUBK
	jmp EnableLockForColorChanges
NoUp2	lda INPT4
	bmi Jump2
	inc Figurelock
	jsr TestColorSimilarity	
	jmp EnableLockForPositionChanges

Jump2
	jmp WaitForVblankEnd 

EnableLockForColorChanges
	lda #6
	sta Lockcounter
	dec Lock
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

TestColorSimilarity
	lda COLUBKBACKUPED
	cmp COLUP0
	bne TestColorSimilarityEnd
	lda SmallSquareSwitch
	cmp #1
	bne MakeItBigger

MakeItSmaller
	lda #20
	sta NUSIZ0
	lda #10
	sta SquareHeight
	dec SmallSquareSwitch
	jmp TestColorSimilarityEnd

MakeItBigger
	lda #30
	sta NUSIZ0
	lda #18
	sta SquareHeight
	inc SmallSquareSwitch

TestColorSimilarityEnd
	rts

WaitForVblankEnd
	lda COLUBK2
	sta COLUBKBACKUPED
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
	lda SquareHeight
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

