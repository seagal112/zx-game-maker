import json

f = open('output/maps.json')

data = json.load(f)

screenWidth = 16
screenHeight = 11

for layer in data['layers']:
    if layer['type'] == 'tilelayer':
        mapStr = "DIM map(0 to " + str(len(layer['data']) - 1) + ") AS UBYTE = {";
        screensCount = len(layer['data'])//screenWidth//screenHeight
        mapRows = layer['height']//screenHeight
        mapCols = layer['width']//screenWidth

        cellsPerMapRow = mapCols * screenWidth * screenHeight



        for mapRow in range(mapRows):
            initialCell = mapRow * cellsPerMapRow
            for cell in range(initialCell, initialCell + cellsPerMapRow):
                print(layer['data'][cell])

        exit
        for cell in layer['data']:
            mapStr += str(cell) + ", ";
        mapStr = mapStr[:-2] + "}"

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