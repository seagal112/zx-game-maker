#include "maps.bas"

CONST screenHeight AS UINTEGER = 11
CONST screenWidth AS UINTEGER = 16
CONST screenCount AS UINTEGER = 2

function getCell(row as UINTEGER, col as UINTEGER) AS UINTEGER
	dim index as UINTEGER = (row * screenWidth * screenCount) + col
	return map(index)
end function

sub mapDraw()
	for row=0 to screenHeight - 1
		for col=0 to screenWidth - 1
		    dim cell as UINTEGER = getCell(row, col)
			if cell = 1
				NIRVANAfillT(0, (row + 1) * 16, col * 2)
			else
				NIRVANAdrawT(cell - 1, (row + 1) * 16, col * 2)
			end if
		next col
	next row	
end sub

function getCellByNirvanaPosition(lin as UINTEGER, col as UINTEGER) AS UINTEGER
	lin = (lin / 16) - 1
	col = col / 2

	return getCell(lin, col)
end function

SUB drawCell(cell as UBYTE, unlin as UBYTE, col as UBYTE)
	if col > 30 OR lin < 2 OR lin > 160
		return
	end if

	if lin mod 2 > 0
		return
	end if

	if cell = 30
		NIRVANAfillT(0, lin, col)
	else
		NIRVANAdrawT(cell, lin, col)
	end if
	NIRVANAhalt()
end sub

sub drawToScr(lin as UBYTE, col as UBYTE, isColPair AS UBYTE, protaRight AS UBYTE)
	if isColPair
		drawCell(getCellByNirvanaPosition(lin, col) - 1, lin, col)
	else
		drawCell(getCellByNirvanaPosition(lin, col - 1) - 1, lin, col - 1)
		drawCell(getCellByNirvanaPosition(lin, col + 1) - 1, lin, col + 1)
	end if
end sub