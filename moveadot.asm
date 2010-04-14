; move a dot with the joystick by Szymon "b.YISK" Barczak based on Kirk Israel's code

	processor 6502
	include vcs.h
	include macro.h
	org $F000

; If a value in any of non-default registers is set to a "2", it means that a function is disabled
; if it is a "1", a function is enabled.
 
YPosFromBot = $80;
VisibleMissileLine = $81;
SquareHeight = $82;
Figurelock = $83;
; Figurelock is used to check if a lock for figure is enabled. If that situation happens, a player can't move a figure
COLUBK2 = $84;
COLUP02	= $85;
; COLUP02 and COLUBK2 are used because to decrease and increase COLUP0 and COLUBK values, which cannot be made in normal way,
; because registers are cleared every time a frame is drawn on the screen.
Lock = $86;
Lockcounter = $87;
; These variables below were used to Easter Egg
; SmallSquareSwitch = $87;
; COLUBKBACKUPED = $89;
CounterLeft = $88;
CounterRight = $89;

Start
	CLEAN_START

	lda #$70
	sta COLUBK
	sta COLUBK2
;	sta COLUBKBACKUPED
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
;	sta SmallSquareSwitch
	lda #15
	sta SquareHeight
	lda #0
	sta CounterLeft
	sta CounterRight
	lda #13

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
	lda #0
	sta AUDC0
	sta AUDF0
	sta AUDV0



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

; Keeping real the idea of KISS, I moved all the tests to subroutines, because both ChangePosition and ChangeColor
; functions check for a player's interaction.  

ChangePosition
	jsr TestLeft
	bne NoLeft
	inc CounterLeft
	lda #12
	sta AUDC0
	sta AUDF0
	sta AUDV0
;	jmp EnableLockForPositionChanges 
NoLeft	jsr TestRight
	bne NoRight
	inc CounterRight 
	lda #10
	sta AUDC0
	sta AUDF0
	sta AUDV0
;	jmp EnableLockForPositionChanges
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

MoveLeft
	ldy CounterLeft
	beq MoveRight

MoveLeftLoop
	ldx #$20
	stx HMM0
	dec CounterLeft
	jmp WaitForVblankEnd
	lda #0
	sta CounterLeft

MoveRight
	ldy CounterRight
	beq NoHorizontalMoves

MoveRightLoop
	ldx #$E0
	stx HMM0
	dec CounterRight
	jmp WaitForVblankEnd
	lda #0
	sta CounterRight

NoHorizontalMoves
	lda #1
	sta Figurelock
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

;	This jump to subroutine is made to run an Easter Egg. Bitch ain't work.
;	jsr TestColorSimilarity	

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

; That shit below is kinda Easter Egg, but it doesn't work

;TestColorSimilarity			
;	lda COLUBKBACKUPED
;	cmp COLUP0
;	bne TestColorSimilarityEnd
;	lda SmallSquareSwitch
;	cmp #1
;	bne MakeItBigger
;
;MakeItSmaller
;	lda #20
;	sta NUSIZ0
;	lda #10
;	sta SquareHeight
;	dec SmallSquareSwitch
;	jmp TestColorSimilarityEnd
;
;MakeItBigger
;	lda #30
;	sta NUSIZ0
;	lda #18
;	sta SquareHeight
;	inc SmallSquareSwitch
;
;TestColorSimilarityEnd
;	rts

WaitForVblankEnd
	lda COLUBK2
;	sta COLUBKBACKUPED
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
	lda SquareHeight		; Here the square width is taken and given to VisibleMissleLine register to drawn
	sta VisibleMissileLine		; the same number of lines, so it will be a square
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

