BIN_FOLDER=vendor/zxsgm/bin/
# 49152
SIZE0=49152
SIZE1=0
SIZE2=0
SIZE3=0
SIZE4=0
SIZE5=0

echo "const BEEP_FX_ADDRESS as uinteger=$SIZE0" >> output/config.bas

python3 ${BIN_FOLDER}fixColors.py assets/screens/title.png assets/screens/title.tmp.png
python3 ${BIN_FOLDER}png2scr.py assets/screens/title.tmp.png
java -jar ${BIN_FOLDER}zx0.jar -f assets/screens/title.tmp.png.scr output/title.png.scr.zx0

python3 ${BIN_FOLDER}fixColors.py assets/screens/ending.png assets/screens/ending.tmp.png
python3 ${BIN_FOLDER}png2scr.py assets/screens/ending.tmp.png
java -jar ${BIN_FOLDER}zx0.jar -f assets/screens/ending.tmp.png.scr output/ending.png.scr.zx0

python3 ${BIN_FOLDER}fixColors.py assets/screens/hud.png assets/screens/hud.tmp.png
python3 ${BIN_FOLDER}png2scr.py assets/screens/hud.tmp.png
java -jar ${BIN_FOLDER}zx0.jar -f assets/screens/hud.tmp.png.scr output/hud.png.scr.zx0

python3 ${BIN_FOLDER}fixColors.py assets/screens/loading.png assets/screens/loading.tmp.png
python3 ${BIN_FOLDER}png2scr.py assets/screens/loading.tmp.png
mv assets/screens/loading.tmp.png.scr output/loading.bin

python3 ${BIN_FOLDER}img2zxbasic/src/img2zxbasic.py -i assets/tiles.png -p assets/paperValues.txt -t tiles > output/tiles.bas
python3 ${BIN_FOLDER}img2zxbasic/src/img2zxbasic.py -i assets/sprites.png -p assets/paperValues.txt -t sprites > output/sprites.bas

cat output/title.png.scr.zx0 output/ending.png.scr.zx0 output/hud.png.scr.zx0 output/map.bin.zx0 output/enemies.bin.zx0 output/tiles.bin output/attrs.bin output/sprites.bin output/objectsInScreen.bin output/screenOffsets.bin output/enemiesInScreenOffsets.bin > output/files.bin.zx0

SIZEFX=$(stat --printf="%s" assets/fx/fx.tap)
SIZE0=$(echo "$SIZEFX + $SIZE0" | bc)
SIZE1=$(stat --printf="%s" output/title.png.scr.zx0)
SIZE2=$(stat --printf="%s" output/ending.png.scr.zx0)
SIZE3=$(stat --printf="%s" output/hud.png.scr.zx0)
SIZE4=$(stat --printf="%s" output/map.bin.zx0)
SIZE5=$(stat --printf="%s" output/enemies.bin.zx0)
SIZE6=$(stat --printf="%s" output/tiles.bin)
SIZE7=$(stat --printf="%s" output/attrs.bin)
SIZE8=$(stat --printf="%s" output/sprites.bin)
SIZE9=$(stat --printf="%s" output/objectsInScreen.bin)
SIZE10=$(stat --printf="%s" output/screenOffsets.bin)
tilesetAddress=$(echo "$SIZE0 + $SIZE1 + $SIZE2 + $SIZE3 + $SIZE4 + $SIZE5" | bc)
attrAddress=$(echo "$tilesetAddress + $SIZE6" | bc)
spritesAddress=$(echo "$attrAddress + $SIZE7" | bc)
screenObjectsAddress=$(echo "$spritesAddress + $SIZE8" | bc)
screenOffsetsAddress=$(echo "$screenObjectsAddress + $SIZE9" | bc)
enemiesInScreenOffsets=$(echo "$screenOffsetsAddress + $SIZE10" | bc)

echo "const TITLE_SCREEN_ADDRESS as uinteger=$SIZE0" >> output/config.bas
address=$(echo "$SIZE0 + $SIZE1" | bc)
echo "const ENDING_SCREEN_ADDRESS as uinteger=$address" >> output/config.bas
address=$(echo "$address + $SIZE2" | bc)
echo "const HUD_SCREEN_ADDRESS as uinteger=$address" >> output/config.bas
address=$(echo "$address + $SIZE3" | bc)
echo "const MAPS_DATA_ADDRESS as uinteger=$address" >> output/config.bas
address=$(echo "$address + $SIZE4" | bc)
echo "const ENEMIES_DATA_ADDRESS as uinteger=$address" >> output/config.bas
echo "const TILESET_DATA_ADDRESS as uinteger=$tilesetAddress" >> output/config.bas
echo "const ATTR_DATA_ADDRESS as uinteger=$attrAddress" >> output/config.bas
echo "const SPRITES_DATA_ADDRESS as uinteger=$spritesAddress" >> output/config.bas
echo "const SCREEN_OBJECTS_DATA_ADDRESS as uinteger=$screenObjectsAddress" >> output/config.bas
echo "const SCREEN_OFFSETS_DATA_ADDRESS as uinteger=$screenOffsetsAddress" >> output/config.bas
echo "const ENEMIES_IN_SCREEN_OFFSETS_DATA_ADDRESS as uinteger=$enemiesInScreenOffsets" >> output/config.bas

wine ${BIN_FOLDER}bin2tap.exe -o output/files.tap -a $SIZE0 output/files.bin.zx0