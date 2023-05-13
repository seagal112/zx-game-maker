import json
from collections import defaultdict
from pprint import pprint

f = open('output/maps.json')

data = json.load(f)

screenWidth = 16
screenHeight = 11
cellsPerScreen = screenWidth * screenHeight

for layer in data['layers']:
    if layer['type'] == 'tilelayer':
        screensCount = len(layer['data'])//screenWidth//screenHeight
        mapRows = layer['height']//screenHeight
        mapCols = layer['width']//screenWidth
        mapStr = "DIM screens(" + str(screensCount - 1) + ", " + str(screenHeight - 1) + ", " + str(screenWidth - 1) + ") AS UBYTE = {";

        screens = defaultdict(dict)

        for idx, cell in enumerate(layer['data']):
            mapX = idx % layer['width']
            mapY = idx // layer['width']

            screenId = mapX // screenWidth

            if len(screens) == 0 or mapY not in screens[screenId]:
                screens[screenId][mapY] = defaultdict(dict)

            screens[screenId][mapY][mapX % screenWidth] = cell

        for screen in screens:
            mapStr += '{'
            for row in screens[screen]:
                mapStr += '{'
                for cell in screens[screen][row]:
                    mapStr += str(screens[screen][row][cell]) + ","
                mapStr = mapStr[:-1]
                mapStr += "},"
            mapStr = mapStr[:-1]
            mapStr += "},"
        mapStr = mapStr[:-1]
        mapStr += "}"
            


with open("output/maps.bas", "w") as text_file:
    print(mapStr, file=text_file)

# Construct enemies

tileHeight = 16
tileWidth = 16

enemies = {}

for layer in data['layers']:
    if layer['type'] == 'objectgroup':
        for object in layer['objects']:
            if object['type'] == 'enemy':
                enemies[str(object['id'])] = {
                    'name': object['name'],
                    'screenId': str((object['x'] // tileWidth) // screenWidth),
                    # 'xIni': str(object['x'] % (screenWidth * tileWidth)),
                    # 'yIni': str(object['y'] % (screenHeight * tileHeight)),
                    'linIni': str((int(object['y'] // tileHeight) - 1)  % screenHeight),
                    'colIni': str(int(object['x'] // tileWidth % screenWidth)),
                    'tile': str(object['properties'][1]['value']),
                    'endObject': object['properties'][0]['value']
                }
for layer in data['layers']:
    if layer['type'] == 'objectgroup':
        for object in layer['objects']:
            if object['type'] == 'path':
                # enemies[str(object['properties'][0]['value'])]['xEnd'] = str(int(object['x'] % (screenWidth * tileWidth)))
                # enemies[str(object['properties'][0]['value'])]['yEnd'] = str(int(object['y'] % (screenHeight * tileHeight)))
                enemies[str(object['properties'][0]['value'])]['linEnd'] = str((int(object['y'] // tileHeight) - 1)  % screenHeight)
                enemies[str(object['properties'][0]['value'])]['colEnd'] = str(int(object['x'] // tileWidth % screenWidth))

enemStr = "DIM enemies(" + str(len(enemies) - 1) + ",5) as ubyte = {"

screenEnemies = defaultdict(dict)

for enemyId in enemies:
    enemy = enemies[enemyId]
    enemStr += '{' + enemy['tile'] + ', ' + enemy['linIni'] + ', ' + enemy['colIni'] + ', ' + enemy['linEnd'] + ', ' + enemy['colEnd'] + ', ' + enemy['screenId'] + '},'
enemStr = enemStr[:-1]
enemStr += "}"

with open("output/enemies.bas", "w") as text_file:
    print(enemStr, file=text_file)