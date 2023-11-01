function isEven(number as ubyte) as ubyte
    return number bAND 1 = 0
end function

sub pauseUntilPressKey()
    WHILE INKEY$<>"":WEND
    WHILE INKEY$="":WEND
end sub

function xToCol(x as ubyte) as ubyte
    return x / 2
end function

function yToLin(y as ubyte) as ubyte
    return y / 4
end function

function secureXIncrement(x as integer, increment as integer) as integer
    dim result = x + increment

    if result < 0 or result > 60
        return x
    end if

    return result
end function

function secureYIncrement(y as integer, increment as integer) as integer
    dim result = y + increment

    if result < 0 or result > MAX_LINE + 4
        return y
    end if
    
    return result
end function

SUB clearBox(x as uByte, y as uByte, width as uByte, height as uByte)
' This subroutine will blank the pixels for a box, measured in Character Squares
' from print positions X,Y to X + Width, Y + height.
'
' Expected to be useful for clearing a window of space - perhaps in a game.
' because of this THE ERROR CHECKING IS NONEXISTENT.
' Please make sure you send sensible data -
' 0 < x < 32, 0 < y < 23, x + width < 32 and y + height < 23
' Britlion 2012.

ASM
    ld b,(IX+5)     ;' get x value
    ld c,(IX+7)     ;' get y value

    ld a, c         ;' Set HL to screen byte for this character.
    and 24
    or 64
    ld h, a
    ld a, c
    and 7
    rra
    rra
    rra
    rra
    add a, b
    ld l, a

    ld b, (IX+11)   ;' get height
    ld c,(IX+9)     ;' get width

clearbox_outer_loop:
    xor a
    push bc       ;' save height.
    push hl       ;' save screen address.
    ld d, 8       ;' 8 rows to a character.

clearbox_mid_loop:
    ld e,l        ;' save screen byte lower half.
    ld b,c        ;' get width.

clearbox_inner_loop:
    ld (hl), a    ;' write out a zero to the screen.

    inc l         ;' go right.
    djnz clearbox_inner_loop    ;' repeat.

    ld l,e        ;' recover screen byte
    inc h         ;' down a row

    dec d
    jp nz, clearbox_mid_loop  ;' repeat for this row.

    pop hl        ;' get back address at start of line
    pop bc        ;' get back char count.

    ld a, 32      ;' Go down to next character row.
    add a, l
    ld l, a
    jp nc, clearbox_row_skip

    ld a, 8
    add a, h
    ld h, a

clearbox_row_skip:
    djnz clearbox_outer_loop
END ASM
END SUB