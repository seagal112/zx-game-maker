#include "../../output/maps.bas"
#include "../../output/enemies.bas"

CONST screenHeight AS UBYTE = 11
CONST screenWidth AS UBYTE = 16
CONST screenCount AS UBYTE = 2

Dim currentScreen as UBYTE = 0

function getCell(row as UBYTE, col as UBYTE) AS UBYTE
	return screens(currentScreen, row, col) - 1
end function

sub mapDraw()
	dim counter as ubyte = 0
	for row=0 to screenHeight - 1
		for col=0 to screenWidth - 1
		    dim cell as UBYTE = getCell(row, col)
			' if counter mod 4 = 0
			' 	NIRVANAhalt()
			' end if
			counter = counter + 1
			if cell = 0
				NIRVANAfillT(0, (row + 1) * 16, col * 2)
			else
				NIRVANAdrawT(cell, (row + 1) * 16, col * 2)
			end if
		next col
	next row
end sub

sub enemiesDraw()
	for key=0 TO 1
		if enemies(key, 7) = currentScreen
			NIRVANAhalt()
			NIRVANAspriteT(1, enemies(key, 0), (enemies(key, 2) + 1) * 16, enemies(key, 1) * 2)
		end if
	next key
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
	' NIRVANAfillT(1, lin, col)
	if cell = 29
		NIRVANAfillT(0, lin, col)
	else
		NIRVANAdrawT(cell, lin, col)
	end if
end sub

sub drawToScr(lin as UBYTE, col as UBYTE, isColPair AS UBYTE)
	' drawCell(getCellByNirvanaPosition(lin, col), lin, col)
	if isColPair
		drawCell(getCellByNirvanaPosition(lin, col), lin, col)
	else
		drawCell(getCellByNirvanaPosition(lin, col - 1), lin, col - 1)
		drawCell(getCellByNirvanaPosition(lin, col + 1), lin, col + 1)
	end if
end sub