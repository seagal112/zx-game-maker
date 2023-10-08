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

function xToCol(x as ubyte) as ubyte
    return x / 2
end function

function yToLin(y as ubyte) as ubyte
    return y / 4
end function

function secureXIncrement(x as integer, increment as integer) as integer
    dim result = x + increment

    if result < 0 and result > 60
        return x
    end if

    return result
end function

function secureYIncrement(y as integer, increment as integer) as integer
    dim result = y + increment

    if result < 0 or result > MAX_LINE + 4
        return y
    else
        return result
    end if
end function