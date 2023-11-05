import json
import math
from collections import defaultdict
from pprint import pprint

f = open('output/maps.json')

data = json.load(f)

# Screens count per row
screensPerRow = 0

screenWidth = data['editorsettings']['chunksize']['width']
screenHeight = data['editorsettings']['chunksize']['height']
cellsPerScreen = screenWidth * screenHeight

tileHeight = data['tileheight']
tileWidth = data['tilewidth']

screenPixelsWidth = screenWidth * tileWidth
screenPixelsHeight = screenHeight * tileHeight

spriteTileOffset = 0

solidTiles = []
animatedTilesIds = []
screenAnimatedTiles = defaultdict(dict)
keyTile = 0
itemTile = 0
doorTile = 0

for tileset in data['tilesets']:
    if tileset['name'] == 'tiles':
        for tile in tileset['tiles']:
            if tile['type'] == 'solid':
                solidTiles.append(str(tile['id']))
            if tile['type'] == 'key':
                keyTile = str(tile['id'])
            if tile['type'] == 'item':
                itemTile = str(tile['id'])
            if tile['type'] == 'door':
                doorTile = str(tile['id'])
            if tile['type'] == 'animated':
                animatedTilesIds.append(str(tile['id']))
    elif tileset['name'] == 'sprites':
        spriteTileOffset = tileset['firstgid']

if spriteTileOffset == 0:
    print('ERROR: Sprite tileset should be called "sprites"')
    exit

goalItems = 10
for property in data['properties']:
    if property['name'] == 'goalItems':
        goalItems = property['value']

mapStr = "const screenWidth as ubyte = " + str(screenWidth) + "\n"
mapStr += "const screenHeight as ubyte = " + str(screenHeight) + "\n"
mapStr += "const MAX_LINE as ubyte = " + str(screenHeight * 2 - 6) + "\n"
mapStr += "const GOAL_ITEMS as ubyte = " + str(goalItems) + "\n"
mapStr += "dim solidTiles(" + str(len(solidTiles) - 1) + ") as ubyte = {" + ",".join(solidTiles) + "}\n"
mapStr += "dim keyTile as ubyte = " + keyTile + "\n"
mapStr += "dim itemTile as ubyte = " + itemTile + "\n"
mapStr += "dim doorTile as ubyte = " + doorTile + "\n"
mapStr += "const SOLID_TILES_ARRAY_SIZE as ubyte = " + str(len(solidTiles) - 1) + "\n\n"

for layer in data['layers']:
    if layer['type'] == 'tilelayer':
        screensCount = len(layer['chunks'])
        mapRows = layer['chunks'][0]['height']//screenHeight
        mapCols = layer['chunks'][0]['width']//screenWidth
        mapStr += "DIM screens(" + str(screensCount - 1) + ", " + str(screenHeight - 1) + ", " + str(screenWidth - 1) + ") AS UBYTE = { _\n";

        screens = defaultdict(dict)
        screenObjects = defaultdict(dict)

        for idx, screen in enumerate(layer['chunks']):
            screens[idx] = defaultdict(dict)
            screenAnimatedTiles[idx] = []

            screenObjects[idx]['key'] = 0
            screenObjects[idx]['item'] = 0
            screenObjects[idx]['door'] = 0

            if screen['x'] == 0:
                screensPerRow += 1

            for jdx, cell in enumerate(screen['data']):
                mapX = jdx % screen['width']
                mapY = jdx // screen['width']

                tile = str(cell - 1)

                screens[idx][mapY][mapX % screenWidth] = tile

                if tile == keyTile:
                    screenObjects[idx]['key'] = 1
                elif tile == itemTile:
                    screenObjects[idx]['item'] = 1
                elif tile == doorTile:
                    screenObjects[idx]['door'] = 1
                
                if tile in animatedTilesIds:
                    screenAnimatedTiles[idx].append([str(tile), str(mapX), str(mapY)])

        for screen in screens:
            mapStr += '\t{ _\n'
            for row in screens[screen]:
                mapStr += '\t\t{'
                for cell in screens[screen][row]:
                    mapStr += "\t" + str(screens[screen][row][cell]) + ","
                mapStr = mapStr[:-1]
                mapStr += "}, _\n"
            mapStr = mapStr[:-4]
            mapStr += " _\n\t}, _\n"
        mapStr = mapStr[:-4]
        mapStr += " _\n}\n\n"

mapStr += "const MAP_SCREENS_WIDTH_COUNT as ubyte = " + str(screensPerRow) + "\n"
mapStr += "const SCREEN_OBJECT_ITEM_INDEX as ubyte = 0 \n"
mapStr += "const SCREEN_OBJECT_KEY_INDEX as ubyte = 1 \n"
mapStr += "const SCREEN_OBJECT_DOOR_INDEX as ubyte = 2 \n\n"

mapStr += "dim screenObjects(" + str(screensCount - 1) + ", 2) as ubyte\n"
mapStr += "dim screenObjectsInitial(" + str(screensCount - 1) + ", 2) as ubyte = { _\n"
for screen in screenObjects:
    mapStr += '\t{' + str(screenObjects[screen]['item']) + ', ' + str(screenObjects[screen]['key']) + ', ' + str(screenObjects[screen]['door']) + '}, _\n'
mapStr = mapStr[:-4]
mapStr += " _\n}\n\n"

mapStr += "dim screenAnimatedTiles(" + str(screensCount - 1) + ", 2, 3) as ubyte = { _\n"
for screen in screenAnimatedTiles:
    mapStr += "\t{ _\n"
    for i in range(len(screenAnimatedTiles[screen])):
        mapStr += '\t\t{' + screenAnimatedTiles[screen][i][0] + ', ' + screenAnimatedTiles[screen][i][1] + ', ' + screenAnimatedTiles[screen][i][2] + ', 0}, _\n'
    for i in range(3 - len(screenAnimatedTiles[screen])):
        mapStr += '\t\t{0, 0, 0, 0}, _\n'
    mapStr = mapStr[:-4]
    mapStr += " _\n"
    mapStr += '\t}, _\n'
mapStr = mapStr[:-4]
mapStr += "\t} _\n"
mapStr = mapStr[:-4]
mapStr += " _\n}\n\n"

with open("output/maps.bas", "w") as text_file:
    print(mapStr, file=text_file)

# Construct enemies

objects = {}
keys = {}
items = {}

for layer in data['layers']:
    if layer['type'] == 'objectgroup':
        for object in layer['objects']:
            if 'gid' in object:
                xScreenPosition = math.ceil(object['x'] / screenPixelsWidth) - 1
                yScreenPosition = math.ceil(object['y'] / screenPixelsHeight) - 1
                screenId = xScreenPosition + (yScreenPosition * screensPerRow)
                type = 0
                if object['type'] == 'enemy':
                    type = '1'
                elif object['type'] == 'key':
                    type = '2'
                elif object['type'] == 'item':
                    type = '3'
                elif object['type'] == 'door':
                    type = '4'
                objects[str(object['id'])] = {
                    'name': object['name'],
                    'screenId': screenId,
                    'linIni': str((object['y'] % (tileHeight * screenHeight)) // 4),
                    'linEnd': str((object['y'] % (tileHeight * screenHeight)) // 4),
                    'colIni': str((object['x'] % (tileWidth * screenWidth)) // 4),
                    'colEnd': str((object['x'] % (tileWidth * screenWidth)) // 4),
                    'tile': str(object['gid'] - spriteTileOffset),
                    'type': type
                }

for layer in data['layers']:
    if layer['type'] == 'objectgroup':
        for object in layer['objects']:
            if 'point' in object and object['point'] == True:
                objects[str(object['properties'][0]['value'])]['linEnd'] = str((object['y'] % (tileHeight * screenHeight)) // 4)
                objects[str(object['properties'][0]['value'])]['colEnd'] = str((object['x'] % (tileWidth * screenWidth)) // 4)

screenEnemies = defaultdict(dict)

for enemyId in objects:
    enemy = objects[enemyId]
    if len(screenEnemies[enemy['screenId']]) == 0:
        screenEnemies[enemy['screenId']] = []
    screenEnemies[enemy['screenId']].append(enemy)

enemStr = "dim enemies(" + str(screensCount - 1) + ",2,10) as ubyte\n"
enemStr += "dim enemiesInitial(" + str(screensCount - 1) + ",2,10) as ubyte = { _"

for layer in data['layers']:
    if layer['type'] == 'tilelayer':
        for idx, screen in enumerate(layer['chunks']):
            enemStr += "\n\t{ _\n"
            if idx in screenEnemies:
                screen = screenEnemies[idx]
                for i in range(3):
                    if i <= len(screen) - 1:
                        enemy = screen[i]
                        if (enemy['colIni'] < enemy['colEnd']):
                            right = '1'
                        else:
                            right = '0'
                        enemStr += '\t\t{' + enemy['tile'] + ', ' + enemy['linIni'] + ', ' + enemy['colIni'] + ', ' + enemy['linEnd'] + ', ' + enemy['colEnd'] + ', ' + right + ', ' + enemy['linIni'] + ', ' + enemy['colIni'] + ', 1, ' + str(i + 1) + ', ' + enemy['type'] + '}, _\n'
                    else:
                        enemStr += '\t\t{0, 0, 0, 0, 0, 0, 0, 0, 0, ' + str(i + 1) + ', 0}, _\n'
            else:
                enemStr += "\t\t{0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0}, _\n"
                enemStr += "\t\t{0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0}, _\n"
                enemStr += "\t\t{0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0}, _\n"
            enemStr = enemStr[:-4]
            enemStr += " _\n\t}, _"

enemStr = enemStr[:-3]
enemStr += " _\n}"

with open("output/enemies.bas", "w") as text_file:
    print(enemStr, file=text_file)

screenKeys = defaultdict(dict)

for keyId in keys:
    key = keys[keyId]
    if len(screenEnemies[key['screenId']]) == 0:
        screenEnemies[key['screenId']] = []
    screenEnemies[key['screenId']].append(key)

keyStr = "DIM keys(" + str(len(screenEnemies)) + ",2,9) as ubyte = { _\n"

keyStr += '\t{ _\n\t\t{0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, _\n\t\t{0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, _\n\t\t{0, 0, 0, 0, 0, 0, 0, 0, 0, 1} _\n\t}, _\n'

for screenId in screenKeys:
    keyStr += "\t{ _\n"
    screen = screenKeys[screenId]
    for i in range(3):
        if i <= len(screen) - 1:
            enemy = screen[i]
            if (enemy['colIni'] < enemy['colEnd']):
                right = '1'
            else:
                right = '0'
            keyStr += '\t\t{' + enemy['tile'] + ', ' + enemy['linIni'] + ', ' + enemy['colIni'] + ', ' + enemy['linEnd'] + ', ' + enemy['colEnd'] + ', ' + right + ', ' + enemy['linIni'] + ', ' + enemy['colIni'] + ', 1, ' + str(i + 1) + '}, _\n'
        else:
            keyStr += '\t\t{0, 0, 0, 0, 0, 0, 0, 0, 0, ' + str(i + 1) + '}, _\n'
    keyStr = keyStr[:-4]
    keyStr += " _\n\t},"
keyStr = keyStr[:-1]
keyStr += " _\n}"

with open("output/keys.bas", "w") as text_file:
    print(keyStr, file=text_file)