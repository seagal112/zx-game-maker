def getSpritesBas(tiles):
    strDeclarationsOut = ""
    strInitializationsOut = ""
    tiles.append([0,0,0,0,0,0,0,0])
    tiles.append([0,0,0,0,0,0,0,0])

    counter = 0
    for i in range(0, 16):
        tile = tiles[counter]
        strDeclarationsOut += "dim sprite" + str(counter) + "(" + str(len(tile) - 1) + ") as ubyte = {"
        iStr = [str(tile) for tile in tile]
        strDeclarationsOut += ",".join(iStr)
        strDeclarationsOut += "}\n"
        strInitializationsOut += "spritesSet(" + str(counter) + ") = Create2x2Sprite(@sprite" + str(counter) + ")\n"
        counter += 1
    
    for i in range(16, 32):
        tile = tiles[i]
        strDeclarationsOut += "dim sprite" + str(i) + "(" + str(len(tile) - 1) + ") as ubyte = {"
        iStr = [str(tile) for tile in tile]
        strDeclarationsOut += ",".join(iStr)
        strDeclarationsOut += "}\n"
        strInitializationsOut += "spritesSet(" + str(i) + ") = Create2x2Sprite(@sprite" + str(i) + ")\n"
        counter += 1
        if counter % 2 == 0:
            tile = tiles[i - 1]
            tile0HorizontalFlip = reorderArray([flip_byte(b) for b in tile])
            strDeclarationsOut += "dim sprite" + str(i + 15) + "(" + str(len(tile) - 1) + ") as ubyte = {"
            iStr = [str(tile) for tile in tile0HorizontalFlip]
            strDeclarationsOut += ",".join(iStr)
            strDeclarationsOut += "}\n"
            strInitializationsOut += "spritesSet(" + str(i + 15) + ") = Create2x2Sprite(@sprite" + str(i + 15) + ")\n"
            counter += 1

            tile = tiles[i]
            tile0HorizontalFlip = reorderArray([flip_byte(b) for b in tile])
            strDeclarationsOut += "dim sprite" + str(i + 15 + 1) + "(" + str(len(tile) - 1) + ") as ubyte = {"
            iStr = [str(tile) for tile in tile0HorizontalFlip]
            strDeclarationsOut += ",".join(iStr)
            strDeclarationsOut += "}\n"
            strInitializationsOut += "spritesSet(" + str(i + 15 + 1) + ") = Create2x2Sprite(@sprite" + str(i + 15 + 1) + ")\n"
            counter += 1

    
    for i in range(32, 34):
        tile = tiles[i]
        strDeclarationsOut += "dim sprite" + str(counter) + "(" + str(len(tile) - 1) + ") as ubyte = {"
        iStr = [str(tile) for tile in tile]
        strDeclarationsOut += ",".join(iStr)
        strDeclarationsOut += "}\n"
        strInitializationsOut += "spritesSet(" + str(counter) + ") = Create1x1Sprite(@sprite" + str(counter) + ")\n"
        counter += 1

    return strDeclarationsOut + "\n" + "dim spritesSet(49) as ubyte\n" + strInitializationsOut

def flip_byte(b):
    return int('{:08b}'.format(b)[::-1], 2)

def reorderArray(sprite):
    return [sprite[16], sprite[17], sprite[18], sprite[19], sprite[20], sprite[21], sprite[22], sprite[23], sprite[24], sprite[25], sprite[26], sprite[27], sprite[28], sprite[29], sprite[30], sprite[31], sprite[0], sprite[1], sprite[2], sprite[3], sprite[4], sprite[5], sprite[6], sprite[7], sprite[8], sprite[9], sprite[10], sprite[11], sprite[12], sprite[13], sprite[14], sprite[15]]

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