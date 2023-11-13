def getSpritesBas(tiles):
    strDeclarationsOut = ""
    strInitializationsOut = ""
    tiles.append([0,0,0,0,0,0,0,0])
    tiles.append([0,0,0,0,0,0,0,0])

    for index, tile in enumerate(tiles):
        strDeclarationsOut += "dim sprite" + str(index) + "(" + str(len(tile) - 1) + ") as ubyte = {"
        iStr = [str(tile) for tile in tile]
        strDeclarationsOut += ",".join(iStr)
        strDeclarationsOut += "}\n"
        if index < 32:
            strInitializationsOut += "spritesSet(" + str(index) + ") = Create2x2Sprite(@sprite" + str(index) + ")\n"
        else:
            strInitializationsOut += "spritesSet(" + str(index) + ") = Create1x1Sprite(@sprite" + str(index) + ")\n"

    return strDeclarationsOut + "\n" + "dim spritesSet(33) as ubyte\n" + strInitializationsOut

def getTilesBas(tiles, attr = {}):
    strOut = "dim tileSet(" + str(len(tiles) - 1) + ",7) as ubyte = { _\n"
    for index, tile in enumerate(tiles):
        strOut += "\t{"
        iStr = [str(tile) for tile in tile] 
        strOut += ",".join(iStr)
        if index != len(tiles) - 1:
            strOut += "}, _\n"
        else:
            strOut += "} _\n"
    strOut += "}\n\n"

    strOut += "dim attrSet(" + str(len(attr) - 1) + ") as ubyte = {"
    iStr = [str(attr) for attr in attr] 
    strOut += ",".join(iStr)
    strOut += "}"
    return strOut