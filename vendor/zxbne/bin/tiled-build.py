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
        mapStr = "DIM map(" + str(screensCount) + ", " + str(screenHeight) + ", " + str(screenWidth) + ") AS UBYTE = {\n";

        screens = defaultdict(dict)

        for idx, cell in enumerate(layer['data']):
            mapX = idx % layer['width']
            mapY = idx // layer['width']

            screenId = mapX // screenWidth

            if len(screens) == 0 or mapY not in screens[screenId]:
                screens[screenId][mapY] = defaultdict(dict)

            screens[screenId][mapY][mapX % screenWidth] = cell

        pprint(screens)
        
        for screen in screens:
            mapStr += '    {\n'
            for row in screens[screen]:
                mapStr += '       {'
                for cell in screens[screen][row]:
                    mapStr += str(screens[screen][row][cell]) + ","
                mapStr = mapStr[:-1]
                mapStr += "},\n"
            mapStr = mapStr[:-2]
            mapStr += "\n   },\n"
        mapStr += "}"
            


with open("output/maps.bas", "w") as text_file:
    print(mapStr, file=text_file)

# Construct enemies
enemies = {}

for layer in data['layers']:
    if layer['type'] == 'objectgroup':
        for object in layer['objects']:
            if object['type'] == 'enemy':
                enemies[str(object['id'])] = {
                    'name': object['name'],
                    'xIni': str(int(object['x']/16)),
                    'yIni': str(int(object['y']/16)),
                    'endObject': object['properties'][0]['value']
                }
for layer in data['layers']:
    if layer['type'] == 'objectgroup':
        for object in layer['objects']:
            if object['type'] == 'path':
                enemies[str(object['properties'][0]['value'])]['xEnd'] = str(int(object['x']/16))
                enemies[str(object['properties'][0]['value'])]['yEnd'] = str(int(object['y']/16))

enemStr = "typedef struct { char tile; char xIni; char yIni; char xEnd; char yEnd;} Enemy;\n"
enemStr += "Enemy enemies[1][" + str(len(enemies)) + "] = {\n"

for key in enemies:
    enemStr += '    {' + enemies[key]['name'] + ', ' + enemies[key]['xIni'] + ', ' + enemies[key]['yIni'] + ', ' + enemies[key]['xEnd'] + ', ' + enemies[key]['yEnd'] + '}\n'

enemStr += '};'

with open("output/enemies.h", "w") as text_file:
    print(enemStr, file=text_file)