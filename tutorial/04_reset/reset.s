      .code
init:

      .segment "VECTORS"
nmi_vector:
      .word $eaea
reset_vector:
      .word init
irq_vector:
      .word $eaea