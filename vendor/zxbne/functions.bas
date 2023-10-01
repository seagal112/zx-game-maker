function isPair(number as ubyte) as ubyte
    if number bAND 1 = 0
        return 1
    else
        return 0
    end if
end function

sub pauseUntilPressKey()
    WHILE INKEY$<>"":WEND
    WHILE INKEY$="":WEND
end sub
