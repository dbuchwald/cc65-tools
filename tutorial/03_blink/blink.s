
  .import VIA_DDRB
  .import VIA_PORTB

  .code

reset:
  lda #$ff
  sta VIA_DDRB

  lda #$50
  sta VIA_PORTB

loop:
  ror
  sta VIA_PORTB

  jmp loop

  .segment "VECTORS"
  .word $0000
  .word reset
  .word $0000