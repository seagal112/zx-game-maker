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
musicEnabled = 0

vtplayerInit = '0'
vtplayerMute = '0'
vtplayerNextNote = '0'

initialScreen = 2
initialMainCharacterX = 8
initialMainCharacterY = 8

spritesMergeModeXor = 0

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
    elif property['name'] == 'musicEnabled':
        musicEnabled = 1 if property['value'] else 0
    elif property['name'] == 'VTPLAYER_INIT':
        vtplayerInit = property['value']
    elif property['name'] == 'VTPLAYER_MUTE':
        vtplayerMute = property['value']
    elif property['name'] == 'VTPLAYER_NEXTNOTE':
        vtplayerNextNote = property['value']
    elif property['name'] == 'maxEnemiesPerScreen' and property['value'] < 6:
        maxEnemiesPerScreen = property['value']
    elif property['name'] == 'spritesMergeModeXor':
        spritesMergeModeXor = 1 if property['value'] else 0

if len(solidTiles) == 0:
    solidTiles.append('0')

if len(damageTiles) == 0:
    damageTiles.append('0')

solidTilesCount = len(solidTiles) - 1 if len(solidTiles) > 0 else 0 
damageTilesCount = len(damageTiles) - 1 if len(damageTiles) > 0 else 0

configStr = "const MAX_ENEMIES_PER_SCREEN as ubyte = " + str(maxEnemiesPerScreen) + "\n"
configStr += "const screenWidth as ubyte = " + str(screenWidth) + "\n"
configStr += "const screenHeight as ubyte = " + str(screenHeight) + "\n"
configStr += "const INITIAL_LIFE as ubyte = " + str(initialLife) + "\n"
configStr += "const MAX_LINE as ubyte = " + str(screenHeight * 2 - 4) + "\n"
configStr += "const GOAL_ITEMS as ubyte = " + str(goalItems) + "\n"
configStr += "const DAMAGE_AMOUNT as ubyte = " + str(damageAmount) + "\n"
configStr += "const LIFE_AMOUNT as ubyte = " + str(lifeAmount) + "\n"
configStr += "const BULLET_DISTANCE as ubyte = " + str(bulletDistance) + "\n"
configStr += "const ENEMIES_RESPAWN as ubyte = " + str(enemiesRespawn) + "\n"
configStr += "const SHOOTING as ubyte = " + str(shooting) + "\n"
configStr += "const SHOULD_KILL_ENEMIES as ubyte = " + str(shouldKillEnemies) + "\n"
configStr += "const MUSIC_ENABLED as ubyte = " + str(musicEnabled) + "\n"
configStr += "dim solidTiles(" + str(solidTilesCount) + ") as ubyte = {" + ",".join(solidTiles) + "}\n"
configStr += "dim damageTiles(" + str(damageTilesCount) + ") as ubyte = {" + ",".join(damageTiles) + "}\n"
configStr += "dim keyTile as ubyte = " + keyTile + "\n"
configStr += "dim itemTile as ubyte = " + itemTile + "\n"
configStr += "dim doorTile as ubyte = " + doorTile + "\n"
configStr += "dim lifeTile as ubyte = " + lifeTile + "\n"
configStr += "const SOLID_TILES_ARRAY_SIZE as ubyte = " + str(len(solidTiles) - 1) + "\n\n"
configStr += "const DAMAGE_TILES_ARRAY_SIZE as ubyte = " + str(len(damageTiles) - 1) + "\n\n"

configStr += "#DEFINE VTPLAYER_INIT $" + str(vtplayerInit) + "\n"
configStr += "#DEFINE VTPLAYER_MUTE $" + str(vtplayerMute) + "\n"
configStr += "#DEFINE VTPLAYER_NEXTNOTE $" + str(vtplayerNextNote) + "\n\n"

if spritesMergeModeXor == 1:
    configStr += "#DEFINE MERGE_WITH_XOR\n\n"

for layer in data['layers']:
    if layer['type'] == 'tilelayer':
        screensCount = len(layer['chunks'])
        mapRows = layer['height']//screenHeight
        mapCols = layer['width']//screenWidth

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

configStr += "const MAP_SCREENS_WIDTH_COUNT as ubyte = " + str(mapCols) + "\n"
configStr += "const SCREEN_OBJECT_ITEM_INDEX as ubyte = 0 \n"
configStr += "const SCREEN_OBJECT_KEY_INDEX as ubyte = 1 \n"
configStr += "const SCREEN_OBJECT_DOOR_INDEX as ubyte = 2 \n"
configStr += "const SCREEN_OBJECT_LIFE_INDEX as ubyte = 3 \n\n"

configStr += "dim screenObjects(" + str(screensCount - 1) + ", 3) as ubyte\n"
configStr += "dim screenObjectsInitial(" + str(screensCount - 1) + ", 3) as ubyte = { _\n"
for screen in screenObjects:
    configStr += '\t{' + str(screenObjects[screen]['item']) + ', ' + str(screenObjects[screen]['key']) + ', ' + str(screenObjects[screen]['door']) + ', ' + str(screenObjects[screen]['life']) + '}, _\n'
configStr = configStr[:-4]
configStr += " _\n}\n\n"

configStr += "dim screenAnimatedTiles(" + str(screensCount - 1) + ", 2, 3) as ubyte = { _\n"
for screen in screenAnimatedTiles:
    configStr += "\t{ _\n"
    for i in range(len(screenAnimatedTiles[screen])):
        configStr += '\t\t{' + screenAnimatedTiles[screen][i][0] + ', ' + screenAnimatedTiles[screen][i][1] + ', ' + screenAnimatedTiles[screen][i][2] + ', 0}, _\n'
    for i in range(3 - len(screenAnimatedTiles[screen])):
        configStr += '\t\t{0, 0, 0, 0}, _\n'
    configStr = configStr[:-4]
    configStr += " _\n"
    configStr += '\t}, _\n'
configStr = configStr[:-4]
configStr += "\t} _\n"
configStr = configStr[:-4]
configStr += " _\n}\n\n"

configStr += "const SCREEN_LENGTH as uinteger = " + str(len(screens[0]) - 1) + "\n"
configStr += "dim decompressedMap(SCREEN_LENGTH) as ubyte\n"

currentOffset = 0
configStr += "dim screensOffsets(" + str(screensCount) + ") as uinteger\n"
configStr += "screensOffsets(0) = " + str(currentOffset) + "\n"
for idx, screen in enumerate(screens):
    label = 'screen' + str(idx).zfill(3)
    with open(outputDir + label + '.bin', 'wb') as f:
        screen.tofile(f)
    subprocess.run(['java', '-jar', 'vendor/zxsgm/bin/zx0.jar', '-f', outputDir + label + '.bin', outputDir + label + '.bin.zx0'])
    currentOffset += os.path.getsize(outputDir + label + '.bin.zx0')
    configStr += "screensOffsets(" + str(idx + 1) + ") = " + str(currentOffset) + "\n"

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
                    'life': '1',
                    'color': '0',
                }

                if 'properties' in object and len(object['properties']) > 0:
                    for property in object['properties']:
                        if property['name'] == 'life':
                            objects[str(object['id'])]['life'] = str(property['value'])
                        elif property['name'] == 'color':
                            objects[str(object['id'])]['color'] = str(property['value'])
for layer in data['layers']:
    if layer['type'] == 'objectgroup':
        for object in layer['objects']:
            if 'point' in object and object['point'] == True:
                if object['type'] == '' and 'properties' in object:
                    objects[str(object['properties'][0]['value'])]['linEnd'] = str(int((object['y'] % (tileHeight * screenHeight))) // 4)
                    objects[str(object['properties'][0]['value'])]['colEnd'] = str(int((object['x'] % (tileWidth * screenWidth))) // 4)
                elif object['type'] == 'mainCharacter':
                    xScreenPosition = math.ceil(object['x'] / screenPixelsWidth) - 1
                    yScreenPosition = math.ceil(object['y'] / screenPixelsHeight) - 1
                    screenId = xScreenPosition + (yScreenPosition * mapCols)
                    initialScreen = screenId
                    initialMainCharacterX = str(int((object['x'] % (tileWidth * screenWidth))) // 4)
                    initialMainCharacterY = str(int((object['y'] % (tileHeight * screenHeight))) // 4)

                    if int(initialMainCharacterX) < 2 or int(initialMainCharacterX) > 60 or int(initialMainCharacterY) < 0 or int(initialMainCharacterY) > 38:
                        exitWithErrorMessage('Main character initial position is out of bounds. X: ' + initialMainCharacterX + ', Y: ' + initialMainCharacterY)
                else:
                    exitWithErrorMessage('Unknown object type. Only "enemy" and "mainCharacter" are allowed')   
                    

screenEnemies = defaultdict(dict)

for enemyId in objects:
    enemy = objects[enemyId]
    if len(screenEnemies[enemy['screenId']]) == 0:
        screenEnemies[enemy['screenId']] = []
    screenEnemies[enemy['screenId']].append(enemy)

enemiesPerScreen = []

configStr += "const INITIAL_SCREEN as ubyte = " + str(initialScreen) + "\n"
configStr += "const INITIAL_MAIN_CHARACTER_X as ubyte = " + str(initialMainCharacterX) + "\n"
configStr += "const INITIAL_MAIN_CHARACTER_Y as ubyte = " + str(initialMainCharacterY) + "\n"

enemiesArray = []

for layer in data['layers']:
    if layer['type'] == 'tilelayer':
        for idx, screen in enumerate(layer['chunks']):
            arrayBuffer = []
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
                        arrayBuffer.append(int(enemy['tile']))
                        arrayBuffer.append(int(enemy['linIni']))
                        arrayBuffer.append(int(enemy['colIni']))
                        arrayBuffer.append(int(enemy['linEnd']))
                        arrayBuffer.append(int(enemy['colEnd']))
                        arrayBuffer.append(int(horizontalDirection))
                        arrayBuffer.append(int(enemy['linIni']))
                        arrayBuffer.append(int(enemy['colIni']))
                        arrayBuffer.append(int(enemy['life']))
                        arrayBuffer.append(i + 1)
                        arrayBuffer.append(int(verticalDirection))                  
                        arrayBuffer.append(int(enemy['color']))                  
                    else:
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(i + 1)
                        arrayBuffer.append(0) 
                        arrayBuffer.append(0)
            else:
                for i in range(maxEnemiesPerScreen):
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                    arrayBuffer.append(1)
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                enemiesPerScreen.append(0)
            enemiesArray.append(array.array('b', arrayBuffer))

currentOffset = 0
configStr += "dim enemiesInScreenOffsets(" + str(screensCount) + ") as uinteger\n"
configStr += "enemiesInScreenOffsets(0) = " + str(currentOffset) + "\n"
for idx, enemiesScreen in enumerate(enemiesArray):
    label = 'enemiesInScreen' + str(idx).zfill(3)
    with open(outputDir + label + '.bin', 'wb') as f:
        enemiesScreen.tofile(f)
    subprocess.run(['java', '-jar', 'vendor/zxsgm/bin/zx0.jar', '-f', outputDir + label + '.bin', outputDir + label + '.bin.zx0'])
    currentOffset += os.path.getsize(outputDir + label + '.bin.zx0')
    configStr += "enemiesInScreenOffsets(" + str(idx + 1) + ") = " + str(currentOffset) + "\n"

configStr += "dim enemiesPerScreen(" + str(screensCount - 1) + ") as ubyte\n"
configStr += "dim enemiesPerScreenInitial(" + str(screensCount - 1) + ") as ubyte = {"

for i in enemiesPerScreen:
    configStr += str(i) + ', '
configStr = configStr[:-2]
configStr += "}\n\n"

configStr += "dim decompressedEnemiesScreen(" + str(maxEnemiesPerScreen - 1) + ", 11) as byte\n"
configStr += "dim unpaintEnemiesArray(" + str(maxEnemiesPerScreen - 1) + ", 1) as byte\n"

with open(outputDir + "config.bas", "w") as text_file:
    print(configStr, file=text_file)