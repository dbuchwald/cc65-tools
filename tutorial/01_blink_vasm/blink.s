; Source code written by Ben Eater, used only for illustration here
; Go to https://eater.net/6502 for more information

  .org $8000

reset:
  lda #$ff
  sta $6002

  lda #$50
  sta $6000

loop:
  ror
  sta $6000

  jmp loop

  .org $fffc
  .word reset
  .word $0000