  .code

reset:
  lda #$ff
  sta $6002

  lda #$50
  sta $6000

loop:
  ror
  sta $6000

  jmp loop

  .segment "VECTORS"
  .word $0000
  .word reset
  .word $0000