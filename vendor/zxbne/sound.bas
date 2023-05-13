sub damageSound()
    portOut(254, 16)
    portOut(254, 16)
    portOut(254, 0)
    portOut(254, 16)
    portOut(254, 16)
    portOut(254, 0)
end sub

sub portOut(port as UBYTE, value as UBYTE)
    asm
        ld hl,2
        add hl,sp
        ld a, (hl)
        inc hl
        inc hl
        ld c, (hl)
        inc hl
        ld b, (hl)
        out (c),a
    end asm
end sub