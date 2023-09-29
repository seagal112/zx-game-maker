const drawToHalt as ubyte = 3

dim drawCounter as ubyte = 0

sub drawTile(tile, lin, col)
    if drawCounter = drawToHalt
        drawCounter = 0
        NIRVANAhalt()
    end if
    NIRVANAdrawT(tile, lin, col)
    drawCounter = drawCounter + 1
end sub