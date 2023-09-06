sub musicStart()
    asm
    halt
    call 52000      ; start AY player
    ld hl,52005
    ld (61947),hl   ; set play address
    ld a,$cd        ; instruction "CALL"
    ld (61946),a    ; play automatically every interrupt
    end asm
end sub

sub musicStop()
    asm
    halt
    ld      a,$21                   ; instruction "LD HL"
    ld      (61946),a               ; disable playing automatically
    call    52000                   ; stop AY player
    end asm
end sub