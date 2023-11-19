import array
import json
import math
from collections import defaultdict
import os
from pprint import pprint
import subprocess
import sys
import numpy as np

def exitWithErrorMessage(message):
    print('\n\n=====================================================================================')
    sys.exit('ERROR: ' + message + '\n=====================================================================================\n\n')

outputDir = 'output/'

f = open(outputDir + 'maps.json')

data = json.load(f)

# Screens count per row
screenWidth = data['editorsettings']['chunksize']['width']
screenHeight = data['editorsettings']['chunksize']['height']
cellsPerScreen = screenWidth * screenHeight

tileHeight = data['tileheight']
tileWidth = data['tilewidth']

screenPixelsWidth = screenWidth * tileWidth
screenPixelsHeight = screenHeight * tileHeight

spriteTileOffset = 0

maxEnemiesPerScreen = 3
maxAnimatedTilesPerScreen = 3

solidTiles = []
damageTiles = []
animatedTilesIds = []
screenAnimatedTiles = defaultdict(dict)
keyTile = 0
itemTile = 0
doorTile = 0
lifeTile = 0

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
            if tile['type'] == 'life':
                lifeTile = str(tile['id'])
            if tile['type'] == 'animated':
                animatedTilesIds.append(str(tile['id']))
            if tile['type'] == 'damage':
                damageTiles.append(str(tile['id']))
            if tile['type'] == 'animated-damage':
                animatedTilesIds.append(str(tile['id']))
                damageTiles.append(str(tile['id']))
    elif tileset['name'] == 'sprites':
        spriteTileOffset = tileset['firstgid']

if spriteTileOffset == 0:
    print('ERROR: Sprite tileset should be called "sprites"')
    exit

# Global properties

initialLife = 40
goalItems = 10
damageAmount = 5
lifeAmount = 5
bulletDistance = 0
enemiesRespawn = 0
shooting = 1
shouldKillEnemies = 0

initialScreen = 2
initialMainCharacterX = 8
initialMainCharactery = 8

for property in data['properties']:
    if property['name'] == 'goalItems':
        goalItems = property['value']
    elif property['name'] == 'damageAmount':
        damageAmount = property['value']
    elif property['name'] == 'lifeAmount':
        lifeAmount = property['value']
    elif property['name'] == 'initialLife':
        initialLife = property['value']
    elif property['name'] == 'bulletDistance':
        bulletDistance = property['value']
    elif property['name'] == 'enemiesRespawn':
        enemiesRespawn = 1 if property['value'] else 0
    elif property['name'] == 'shooting':
        shooting = 1 if property['value'] else 0
    elif property['name'] == 'shouldKillEnemies':
        shouldKillEnemies = 1 if property['value'] else 0

if len(solidTiles) == 0:
    solidTiles.append('0')

if len(damageTiles) == 0:
    damageTiles.append('0')

solidTilesCount = len(solidTiles) - 1 if len(solidTiles) > 0 else 0 
damageTilesCount = len(damageTiles) - 1 if len(damageTiles) > 0 else 0

mapStr = "const MAX_ENEMIES_PER_SCREEN = " + str(maxEnemiesPerScreen) + "\n"
mapStr += "const screenWidth as ubyte = " + str(screenWidth) + "\n"
mapStr += "const screenHeight as ubyte = " + str(screenHeight) + "\n"
mapStr += "const INITIAL_LIFE as ubyte = " + str(initialLife) + "\n"
mapStr += "const MAX_LINE as ubyte = " + str(screenHeight * 2 - 6) + "\n"
mapStr += "const GOAL_ITEMS as ubyte = " + str(goalItems) + "\n"
mapStr += "const DAMAGE_AMOUNT as ubyte = " + str(damageAmount) + "\n"
mapStr += "const LIFE_AMOUNT as ubyte = " + str(lifeAmount) + "\n"
mapStr += "const BULLET_DISTANCE as ubyte = " + str(bulletDistance) + "\n"
mapStr += "const ENEMIES_RESPAWN as ubyte = " + str(enemiesRespawn) + "\n"
mapStr += "const SHOOTING as ubyte = " + str(shooting) + "\n"
mapStr += "const SHOULD_KILL_ENEMIES as ubyte = " + str(shouldKillEnemies) + "\n"
mapStr += "dim solidTiles(" + str(solidTilesCount) + ") as ubyte = {" + ",".join(solidTiles) + "}\n"
mapStr += "dim damageTiles(" + str(damageTilesCount) + ") as ubyte = {" + ",".join(damageTiles) + "}\n"
mapStr += "dim keyTile as ubyte = " + keyTile + "\n"
mapStr += "dim itemTile as ubyte = " + itemTile + "\n"
mapStr += "dim doorTile as ubyte = " + doorTile + "\n"
mapStr += "dim lifeTile as ubyte = " + lifeTile + "\n"
mapStr += "const SOLID_TILES_ARRAY_SIZE as ubyte = " + str(len(solidTiles) - 1) + "\n\n"
mapStr += "const DAMAGE_TILES_ARRAY_SIZE as ubyte = " + str(len(damageTiles) - 1) + "\n\n"

for layer in data['layers']:
    if layer['type'] == 'tilelayer':
        screensCount = len(layer['chunks'])
        mapRows = layer['height']//screenHeight
        mapCols = layer['width']//screenWidth
        # mapStr += "DIM screens(" + str(screensCount - 1) + ", " + str(screenHeight - 1) + ", " + str(screenWidth - 1) + ") AS UBYTE = { _\n";

        screens = []
        screenObjects = defaultdict(dict)

        for idx, screen in enumerate(layer['chunks']):
            screens.append(array.array('B', screen['data']))
            screenAnimatedTiles[idx] = []

            screenObjects[idx]['key'] = 0
            screenObjects[idx]['item'] = 0
            screenObjects[idx]['door'] = 0
            screenObjects[idx]['life'] = 0

            for jdx, cell in enumerate(screen['data']):
                mapX = jdx % screen['width']
                mapY = jdx // screen['width']

                tile = str(cell - 1)

                # screens[idx][mapY][mapX % screenWidth] = tile

                if tile == keyTile:
                    screenObjects[idx]['key'] = 1
                elif tile == itemTile:
                    screenObjects[idx]['item'] = 1
                elif tile == doorTile:
                    screenObjects[idx]['door'] = 1
                elif tile == lifeTile:
                    screenObjects[idx]['life'] = 1
                
                if tile in animatedTilesIds:
                    screenAnimatedTiles[idx].append([str(tile), str(mapX), str(mapY)])

                if len(screenAnimatedTiles[idx]) > maxAnimatedTilesPerScreen:
                    exitWithErrorMessage('Max animated tiles per screen is ' + str(maxAnimatedTilesPerScreen))

mapStr += "const MAP_SCREENS_WIDTH_COUNT as ubyte = " + str(mapCols) + "\n"
mapStr += "const SCREEN_OBJECT_ITEM_INDEX as ubyte = 0 \n"
mapStr += "const SCREEN_OBJECT_KEY_INDEX as ubyte = 1 \n"
mapStr += "const SCREEN_OBJECT_DOOR_INDEX as ubyte = 2 \n"
mapStr += "const SCREEN_OBJECT_LIFE_INDEX as ubyte = 3 \n\n"

mapStr += "dim screenObjects(" + str(screensCount - 1) + ", 3) as ubyte\n"
mapStr += "dim screenObjectsInitial(" + str(screensCount - 1) + ", 3) as ubyte = { _\n"
for screen in screenObjects:
    mapStr += '\t{' + str(screenObjects[screen]['item']) + ', ' + str(screenObjects[screen]['key']) + ', ' + str(screenObjects[screen]['door']) + ', ' + str(screenObjects[screen]['life']) + '}, _\n'
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

mapStr += "const SCREEN_LENGTH as uinteger = " + str(len(screens[0]) - 1) + "\n"
mapStr += "dim decompressedMap(SCREEN_LENGTH) as ubyte\n"
mapStr += "dim swapMap(SCREEN_LENGTH) as ubyte\n"
# mapStr += "dim screensLabels(" + str(screensCount - 1) + ") as ulong\n"
# for idx, screen in enumerate(screens):
#     label = 'screen' + str(idx)
#     mapStr += "screensLabels(" + str(idx) + ") = @" + label + "\n"

currentOffset = 0
mapStr += "dim screensOffsets(" + str(screensCount) + ") as uinteger\n"
mapStr += "screensOffsets(0) = " + str(currentOffset) + "\n"
for idx, screen in enumerate(screens):
    label = 'screen' + str(idx).zfill(3)
    with open(outputDir + label + '.bin', 'wb') as f:
        screen.tofile(f)
    subprocess.run(['java', '-jar', 'vendor/zxsgm/bin/zx0.jar', '-f', outputDir + label + '.bin', outputDir + label + '.bin.zx0'])
    currentOffset += os.path.getsize(outputDir + label + '.bin.zx0')
    mapStr += "screensOffsets(" + str(idx + 1) + ") = " + str(currentOffset) + "\n"
#     mapStr += label + ":\n"
#     mapStr += "\tasm\n"
#     mapStr += "\t\tincbin \"output/" + label + ".bin.zx0\"\n"
#     mapStr += "\tend asm\n\n"

# with open(outputDir + "maps.bas", "w") as text_file:
#     print(mapStr, file=text_file)

with open(outputDir + "config.bas", "w") as text_file:
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
                screenId = xScreenPosition + (yScreenPosition * mapCols)
                objects[str(object['id'])] = {
                    'name': object['name'],
                    'screenId': screenId,
                    'linIni': str(int((object['y'] % (tileHeight * screenHeight))) // 4),
                    'linEnd': str(int((object['y'] % (tileHeight * screenHeight))) // 4),
                    'colIni': str(int((object['x'] % (tileWidth * screenWidth))) // 4),
                    'colEnd': str(int((object['x'] % (tileWidth * screenWidth))) // 4),
                    'tile': str(object['gid'] - spriteTileOffset),
                    'life': str(object['properties'][0]['value']) if ('properties' in object and len(object['properties']) > 0 and object['properties'][0]['name'] == 'life') else '1',
                }

for layer in data['layers']:
    if layer['type'] == 'objectgroup':
        for object in layer['objects']:
            if 'point' in object and object['point'] == True:
                if 'properties' in object:
                    objects[str(object['properties'][0]['value'])]['linEnd'] = str(int((object['y'] % (tileHeight * screenHeight))) // 4)
                    objects[str(object['properties'][0]['value'])]['colEnd'] = str(int((object['x'] % (tileWidth * screenWidth))) // 4)
                if object['type'] == 'mainCharacter':
                    xScreenPosition = math.ceil(object['x'] / screenPixelsWidth) - 1
                    yScreenPosition = math.ceil(object['y'] / screenPixelsHeight) - 1
                    screenId = xScreenPosition + (yScreenPosition * mapCols)
                    initialScreen = screenId
                    initialMainCharacterX = str(int((object['x'] % (tileWidth * screenWidth))) // 4)
                    initialMainCharacterY = str(int((object['y'] % (tileHeight * screenHeight))) // 4)
                    

screenEnemies = defaultdict(dict)

for enemyId in objects:
    enemy = objects[enemyId]
    if len(screenEnemies[enemy['screenId']]) == 0:
        screenEnemies[enemy['screenId']] = []
    screenEnemies[enemy['screenId']].append(enemy)

enemiesPerScreen = []

enemStr = "const INITIAL_SCREEN as ubyte = " + str(initialScreen) + "\n"
enemStr += "const INITIAL_MAIN_CHARACTER_X as ubyte = " + str(initialMainCharacterX) + "\n"
enemStr += "const INITIAL_MAIN_CHARACTER_Y as ubyte = " + str(initialMainCharacterY) + "\n"
enemStr += "dim enemies(" + str(screensCount - 1) + "," + str(maxEnemiesPerScreen - 1) + ",10) as byte\n"
enemStr += "dim enemiesInitial(" + str(screensCount - 1) + "," + str(maxEnemiesPerScreen - 1) + ",10) as byte = { _"

for layer in data['layers']:
    if layer['type'] == 'tilelayer':
        for idx, screen in enumerate(layer['chunks']):
            enemStr += "\n\t{ _\n"
            if idx in screenEnemies:
                screen = screenEnemies[idx]
                enemiesPerScreen.append(0)
                for i in range(maxEnemiesPerScreen):
                    if i <= len(screen) - 1:
                        enemy = screen[i]
                        if (int(enemy['colIni']) < int(enemy['colEnd'])):
                            horizontalDirection = '-1'
                        else:
                            horizontalDirection = '1'

                        if (int(enemy['linIni']) > int(enemy['linEnd'])):
                            verticalDirection = '1'
                        else:
                            verticalDirection = '-1'

                        enemiesPerScreen[idx] = enemiesPerScreen[idx] + 1
                        enemStr += '\t\t{' + str(enemy['tile']) + ', ' + str(enemy['linIni']) + ', ' + str(enemy['colIni']) + ', ' + str(enemy['linEnd']) + ', ' + str(enemy['colEnd']) + ', ' + horizontalDirection + ', ' + str(enemy['linIni']) + ', ' + str(enemy['colIni']) + ', ' + str(enemy['life']) + ', ' + str(i + 1) + ', ' + verticalDirection + '}, _\n'
                    else:
                        enemStr += '\t\t{0, 0, 0, 0, 0, 0, 0, 0, 0, ' + str(i + 1) + ', 0}, _\n'
            else:
                for i in range(maxEnemiesPerScreen):
                    enemStr += "\t\t{0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0}, _\n"
                enemiesPerScreen.append(0)
            enemStr = enemStr[:-4]
            enemStr += " _\n\t}, _"

enemStr = enemStr[:-3]
enemStr += " _\n}\n\n"

enemStr += "dim enemiesPerScreen(" + str(screensCount - 1) + ") as ubyte\n"
enemStr += "dim enemiesPerScreenInitial(" + str(screensCount - 1) + ") as ubyte = {"

for i in enemiesPerScreen:
    enemStr += str(i) + ', '
enemStr = enemStr[:-2]
enemStr += "}\n\n"

with open(outputDir + "enemies.bas", "w") as text_file:
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

with open(outputDir + "keys.bas", "w") as text_file:
    print(keyStr, file=text_file)