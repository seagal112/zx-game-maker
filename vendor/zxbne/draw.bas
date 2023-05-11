#include "../../output/maps.bas"
#include "helper.bas"

CONST screenHeight AS UBYTE = 11
CONST screenWidth AS UBYTE = 16
CONST screenCount AS UBYTE = 2

Dim currentScreen as UBYTE = 0

function getCell(row as UBYTE, col as UBYTE) AS UBYTE
	return screens(currentScreen, row, col)
end function

sub mapDraw()
	for row=0 to screenHeight - 1
		for col=0 to screenWidth - 1
		    dim cell as UBYTE = getCell(row, col)
			if cell = 1
				NIRVANAfillT(0, (row + 1) * 16, col * 2)
			else
				NIRVANAdrawT(cell - 1, (row + 1) * 16, col * 2)
			end if
		next col
	next row
end sub

function getCellByNirvanaPosition(lin as UBYTE, col as UBYTE) AS UBYTE
	lin = (lin / 16) - 1
	col = col / 2

	return getCell(lin, col)
end function

SUB drawCell(cell as UBYTE, lin as UBYTE, col as UBYTE)
	if col > 30 OR lin < 2 OR lin > 160
		return
	end if

	if lin mod 2 > 0
		return
	end if
	
	NIRVANAhalt()
	if cell = 29
		NIRVANAfillT(0, lin, col)
	else
		NIRVANAdrawT(cell, lin, col)
	end if
end sub

sub drawToScr(lin as UBYTE, col as UBYTE, isColPair AS UBYTE)
	if isColPair
		drawCell(getCellByNirvanaPosition(lin, col) - 1, lin, col)
	else
		drawCell(getCellByNirvanaPosition(lin, col - 1) - 1, lin, col - 1)
		drawCell(getCellByNirvanaPosition(lin, col + 1) - 1, lin, col + 1)
	end if
end sub