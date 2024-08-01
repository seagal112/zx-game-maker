BIN_FOLDER=vendor/zxsgm/bin/
# 49152
SIZE0=49152
SIZE1=0
SIZE2=0
SIZE3=0
SIZE4=0
SIZE5=0

echo "const BEEP_FX_ADDRESS as uinteger=$SIZE0" >> output/config.bas

if [ -f assets/screens/title.scr ]; then
    java -jar ${BIN_FOLDER}zx0.jar -f assets/screens/title.scr output/title.png.scr.zx0
else
    python3 ${BIN_FOLDER}fixColors.py assets/screens/title.png output/title.tmp.png
    python3 ${BIN_FOLDER}png2scr.py output/title.tmp.png
    java -jar ${BIN_FOLDER}zx0.jar -f output/title.tmp.png.scr output/title.png.scr.zx0
fi

if [ -f assets/screens/ending.scr ]; then
    java -jar ${BIN_FOLDER}zx0.jar -f assets/screens/ending.scr output/ending.png.scr.zx0
else
    python3 ${BIN_FOLDER}fixColors.py assets/screens/ending.png output/ending.tmp.png
    python3 ${BIN_FOLDER}png2scr.py output/ending.tmp.png
    java -jar ${BIN_FOLDER}zx0.jar -f output/ending.tmp.png.scr output/ending.png.scr.zx0
fi

if [ -f assets/screens/hud.scr ]; then
    java -jar ${BIN_FOLDER}zx0.jar -f assets/screens/hud.scr output/hud.png.scr.zx0
else
    python3 ${BIN_FOLDER}fixColors.py assets/screens/hud.png output/hud.tmp.png
    python3 ${BIN_FOLDER}png2scr.py output/hud.tmp.png
    java -jar ${BIN_FOLDER}zx0.jar -f output/hud.tmp.png.scr output/hud.png.scr.zx0
fi

if [ -f assets/screens/loading.scr ]; then
    cp assets/screens/loading.scr output/loading.bin
else
    python3 ${BIN_FOLDER}fixColors.py assets/screens/loading.png output/loading.tmp.png
    python3 ${BIN_FOLDER}png2scr.py output/loading.tmp.png
    mv output/loading.tmp.png.scr output/loading.bin
fi

python3 ${BIN_FOLDER}img2zxbasic/src/img2zxbasic.py -t tiles
python3 ${BIN_FOLDER}img2zxbasic/src/img2zxbasic.py -t sprites

cat output/title.png.scr.zx0 output/ending.png.scr.zx0 output/hud.png.scr.zx0 output/map.bin.zx0 output/enemies.bin.zx0 output/tiles.bin output/attrs.bin output/sprites.bin output/objectsInScreen.bin output/screenOffsets.bin output/enemiesInScreenOffsets.bin output/animatedTilesInScreen.bin output/damageTiles.bin output/enemiesPerScreen.bin output/enemiesPerScreen.bin > output/files.bin.zx0

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
SIZE11=$(stat --printf="%s" output/enemiesInScreenOffsets.bin)
SIZE12=$(stat --printf="%s" output/animatedTilesInScreen.bin)
SIZE13=$(stat --printf="%s" output/damageTiles.bin)
SIZE14=$(stat --printf="%s" output/enemiesPerScreen.bin)
SIZE15=$(stat --printf="%s" output/enemiesPerScreen.bin)
tilesetAddress=$(echo "$SIZE0 + $SIZE1 + $SIZE2 + $SIZE3 + $SIZE4 + $SIZE5" | bc)
attrAddress=$(echo "$tilesetAddress + $SIZE6" | bc)
spritesAddress=$(echo "$attrAddress + $SIZE7" | bc)
screenObjectsAddress=$(echo "$spritesAddress + $SIZE8" | bc)
screenOffsetsAddress=$(echo "$screenObjectsAddress + $SIZE9" | bc)
enemiesInScreenOffsets=$(echo "$screenOffsetsAddress + $SIZE10" | bc)
animatedTilesInScreen=$(echo "$enemiesInScreenOffsets + $SIZE11" | bc)
damageTiles=$(echo "$animatedTilesInScreen + $SIZE12" | bc)
enemiesPerScreen=$(echo "$damageTiles + $SIZE13" | bc)
enemiesPerScreenInitial=$(echo "$enemiesPerScreen + $SIZE14" | bc)

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
echo "const ANIMATED_TILES_IN_SCREEN_DATA_ADDRESS as uinteger=$animatedTilesInScreen" >> output/config.bas
echo "const DAMAGE_TILES_DATA_ADDRESS as uinteger=$damageTiles" >> output/config.bas
echo "const ENEMIES_PER_SCREEN_DATA_ADDRESS as uinteger=$enemiesPerScreen" >> output/config.bas
echo "const ENEMIES_PER_SCREEN_INITIAL_DATA_ADDRESS as uinteger=$enemiesPerScreenInitial" >> output/config.bas

wine ${BIN_FOLDER}bin2tap.exe -o output/files.tap -a $SIZE0 output/files.bin.zx0

python3 vendor/zxsgm/bin/memoryImageGenerator.py $SIZEFX,$SIZE1,$SIZE2,$SIZE3,$SIZE4,$SIZE5,$SIZE6,$SIZE7,$SIZE8,$SIZE9,$SIZE10,$SIZE11,$SIZE12