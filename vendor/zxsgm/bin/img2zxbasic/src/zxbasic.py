import os


def prepareTiles(tiles):
    result = []
    mirroredTiles = []
    counter = 0
    for i in range(0, 16):
        result.append(tiles[counter])
        counter += 1

    for i in range(16, 32):
        result.append(tiles[i])
        counter += 1
        if counter % 2 == 0:
            tile = tiles[i - 1]
            tile0HorizontalFlip = reorderArray([flip_byte(b) for b in tile])
            mirroredTiles.append(tile0HorizontalFlip)
            counter += 1

            tile = tiles[i]
            tile0HorizontalFlip = reorderArray([flip_byte(b) for b in tile])
            mirroredTiles.append(tile0HorizontalFlip)
            counter += 1
    
    result += mirroredTiles
    return result

def prepareTilesWithOutMirror(tiles):
    result = []
    counter = 0
    for i in range(0, 48):
        result.append(tiles[counter])
        counter += 1

    return result
    

def getSpritesBas(tiles):
    if len(tiles) == 32:
        tiles = prepareTiles(tiles)
    else:
        tiles = prepareTilesWithOutMirror(tiles)

    with    open("output/sprites.bin", "wb") as f:
        for tile in tiles:
            f.write(bytearray(tile))

def flip_byte(b):
    return int('{:08b}'.format(b)[::-1], 2)

def reorderArray(sprite):
    return [sprite[16], sprite[17], sprite[18], sprite[19], sprite[20], sprite[21], sprite[22], sprite[23], sprite[24], sprite[25], sprite[26], sprite[27], sprite[28], sprite[29], sprite[30], sprite[31], sprite[0], sprite[1], sprite[2], sprite[3], sprite[4], sprite[5], sprite[6], sprite[7], sprite[8], sprite[9], sprite[10], sprite[11], sprite[12], sprite[13], sprite[14], sprite[15]]

def getTilesBas(tiles, attrs = {}):
    if not os.path.exists("output"):
        os.makedirs("output")
        
    # Guardar tiles en fichero bin para cargarlo desde basic
    with open("output/tiles.bin", "wb+") as f:
        for tile in tiles:
            f.write(bytearray(tile))

    # Guardar array de enteros de una dimension attrs en fichero binario para cargarlo desde basic
    attrs = [int(attr) for attr in attrs]

    with open("output/attrs.bin", "wb+") as f:
        for attr in attrs:
            f.write(attr.to_bytes(1, byteorder='big'))
        
            
    # strOut = "dim tileSet2(" + str(len(tiles) - 1) + ",7) as ubyte = { _\n"
    # for index, tile in enumerate(tiles):
    #     strOut += "\t{"
    #     iStr = [str(tile) for tile in tile] 
    #     strOut += ",".join(iStr)
    #     if index != len(tiles) - 1:
    #         strOut += "}, _\n"
    #     else:
    #         strOut += "} _\n"
    # strOut += "}\n\n"

    # strOut = "dim attrSet2(" + str(len(attrs) - 1) + ") as ubyte = {"
    # iStr = [str(attr) for attr in attrs] 
    # strOut += ",".join(iStr)
    # strOut += "}"
    # return strOut