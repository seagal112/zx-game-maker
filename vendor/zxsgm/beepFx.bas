SUB FASTCALL BeepFX_Play(sound as ubyte)
    ASM
      push ix ; Guardamos ix
      ld [49153],a ; Cargamos el sonido a reproducir
      call 49152 ; Reproducimos el sonido
      pop ix ; Recuperamos ix
    END ASM
END SUB