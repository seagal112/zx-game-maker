import json
import math
from collections import defaultdict
from pprint import pprint

f = open('output/maps.json')

data = json.load(f)

screenWidth = 16
screenHeight = 8
cellsPerScreen = screenWidth * screenHeight
screensPerRow = 4
mapWidth = screenWidth * screensPerRow

for layer in data['layers']:
    if layer['type'] == 'tilelayer':
        screensCount = len(layer['chunks'])
        mapRows = layer['chunks'][0]['height']//screenHeight
        mapCols = layer['chunks'][0]['width']//screenWidth
        mapStr = "DIM screens(" + str(screensCount - 1) + ", " + str(screenHeight - 1) + ", " + str(screenWidth - 1) + ") AS UBYTE = { _\n";

        screens = defaultdict(dict)

        for idx, screen in enumerate(layer['chunks']):
            screens[idx] = defaultdict(dict)

            for jdx, cell in enumerate(screen['data']):
                mapX = jdx % screen['width']
                mapY = jdx // screen['width']

                screens[idx][mapY][mapX % screenWidth] = cell

        # for idx, cell in enumerate(layer['data']):
        #     mapX = idx % layer['width']
        #     mapY = idx // layer['width']

        #     screenId = mapX // screenWidth

        #     if len(screens) == 0 or mapY not in screens[screenId]:
        #         screens[screenId][mapY] = defaultdict(dict)

        #     screens[screenId][mapY][mapX % screenWidth] = cell

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
        mapStr += " _\n} _\n"
            


with open("output/maps.bas", "w") as text_file:
    print(mapStr, file=text_file)

# Construct enemies

tileHeight = 16
tileWidth = 16

screenPixelsWidth = screenWidth * tileWidth
screenPixelsHeight = screenHeight * tileHeight

enemies = {}
keys = {}
items = {}

for layer in data['layers']:
    if layer['type'] == 'objectgroup':
        for object in layer['objects']:
            if object['type'] == 'enemy':
                xScreenPosition = math.ceil(object['x'] / screenPixelsWidth) - 1
                yScreenPosition = math.ceil(object['y'] / screenPixelsHeight) - 1
                screenId = xScreenPosition + (yScreenPosition * screensPerRow)
                enemies[str(object['id'])] = {
                    'name': object['name'],
                    'screenId': screenId,
                    'linIni': str(object['y'] // tileHeight % screenHeight * 16),
                    'linEnd': str(object['y'] // tileHeight % screenHeight * 16),
                    'colIni': str(object['x'] // tileWidth % screenWidth * 2),
                    'colEnd': str(object['x'] // tileWidth % screenWidth * 2),
                    'tile': str(object['gid'] - 1),
                    'endObject': object['properties'][0]['value']
                }
            elif object['type'] == 'key':
                keys[str(object['id'])] = {
                    'name': object['name'],
                    'screenId': screenId,
                    'linIni': str(object['y'] // tileHeight % screenHeight * 16),
                    'colIni': str(object['x'] // tileWidth % screenWidth * 2),
                    'tile': str(object['gid'] - 1),
                }
            elif object['type'] == 'items':
                keys[str(object['id'])] = {
                    'name': object['name'],
                    'screenId': screenId,
                    'linIni': str(object['y'] // tileHeight % screenHeight * 16),
                    'colIni': str(object['x'] // tileWidth % screenWidth * 2),
                    'tile': str(object['gid'] - 1),
                }

for layer in data['layers']:
    if layer['type'] == 'objectgroup':
        for object in layer['objects']:
            if object['type'] == 'path':
                enemies[str(object['properties'][0]['value'])]['linEnd'] = str(object['y'] // tileHeight % screenHeight * 16)
                enemies[str(object['properties'][0]['value'])]['colEnd'] = str(object['x'] // tileWidth % screenWidth * 2)

screenEnemies = defaultdict(dict)

for enemyId in enemies:
    enemy = enemies[enemyId]
    if len(screenEnemies[enemy['screenId']]) == 0:
        screenEnemies[enemy['screenId']] = []
    screenEnemies[enemy['screenId']].append(enemy)

print(screenEnemies)

enemStr = "DIM enemies(" + str(screensCount - 1) + ",2,9) as ubyte = { _"

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
                        enemStr += '\t\t{' + enemy['tile'] + ', ' + enemy['linIni'] + ', ' + enemy['colIni'] + ', ' + enemy['linEnd'] + ', ' + enemy['colEnd'] + ', ' + right + ', ' + enemy['linIni'] + ', ' + enemy['colIni'] + ', 1, ' + str(i + 1) + '}, _\n'
                    else:
                        enemStr += '\t\t{0, 0, 0, 0, 0, 0, 0, 0, 0, ' + str(i + 1) + '}, _\n'
            else:
                enemStr += "\t\t{0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, _\n"
                enemStr += "\t\t{0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, _\n"
                enemStr += "\t\t{0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, _\n"
            enemStr = enemStr[:-4]
            enemStr += " _\n\t}, _"

# for screenId in screenEnemies:
#     enemStr += "\t{ _\n"
#     screen = screenEnemies[screenId]
#     for i in range(3):
#         if i <= len(screen) - 1:
#             enemy = screen[i]
#             if (enemy['colIni'] < enemy['colEnd']):
#                 right = '1'
#             else:
#                 right = '0'
#             enemStr += '\t\t{' + enemy['tile'] + ', ' + enemy['linIni'] + ', ' + enemy['colIni'] + ', ' + enemy['linEnd'] + ', ' + enemy['colEnd'] + ', ' + right + ', ' + enemy['linIni'] + ', ' + enemy['colIni'] + ', 1, ' + str(i + 1) + '}, _\n'
#         else:
#             enemStr += '\t\t{0, 0, 0, 0, 0, 0, 0, 0, 0, ' + str(i + 1) + '}, _\n'
#     enemStr = enemStr[:-4]
#     enemStr += " _\n\t},"
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