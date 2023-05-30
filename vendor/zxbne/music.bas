sub Music_Init()
    asm
    halt
    call 52000
    ld hl,52005
    ld (61947),hl
    ld a,$cd
    ld (61946),a
    end asm
end sub