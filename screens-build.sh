BIN_FOLDER=vendor/zxsgm/bin/

enabled128K=$(jq -r '.properties | .[] | select(.name=="128Kenabled") | .value' output/maps.json)

if [ -f assets/screens/title.scr ]; then
    ${BIN_FOLDER}zx0 -f assets/screens/title.scr output/title.png.scr.zx0
else
    python3 ${BIN_FOLDER}fixColors.py assets/screens/title.png output/title.tmp.png
    python3 ${BIN_FOLDER}png2scr.py output/title.tmp.png
    ${BIN_FOLDER}zx0 -f output/title.tmp.png.scr output/title.png.scr.zx0
fi

if [ -f assets/screens/ending.scr ]; then
    ${BIN_FOLDER}zx0 -f assets/screens/ending.scr output/ending.png.scr.zx0
else
    python3 ${BIN_FOLDER}fixColors.py assets/screens/ending.png output/ending.tmp.png
    python3 ${BIN_FOLDER}png2scr.py output/ending.tmp.png
    ${BIN_FOLDER}zx0 -f output/ending.tmp.png.scr output/ending.png.scr.zx0
fi

if [ -f assets/screens/hud.scr ]; then
    ${BIN_FOLDER}zx0 -f assets/screens/hud.scr output/hud.png.scr.zx0
else
    python3 ${BIN_FOLDER}fixColors.py assets/screens/hud.png output/hud.tmp.png
    python3 ${BIN_FOLDER}png2scr.py output/hud.tmp.png
    ${BIN_FOLDER}zx0 -f output/hud.tmp.png.scr output/hud.png.scr.zx0
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

rm -f output/files.bin.zx0

if [[ $enabled128K != true ]]; then
    cat output/title.png.scr.zx0 output/ending.png.scr.zx0 output/hud.png.scr.zx0 > output/files.bin.zx0
fi
cat output/map.bin.zx0 \
    output/enemies.bin.zx0 \
    output/tiles.bin \
    output/attrs.bin \
    output/sprites.bin \
    output/objectsInScreen.bin \
    output/screenOffsets.bin \
    output/enemiesInScreenOffsets.bin \
    output/animatedTilesInScreen.bin \
    output/damageTiles.bin \
    output/enemiesPerScreen.bin \
    output/enemiesPerScreen.bin \
    output/screenObjects.bin \
    output/screensWon.bin \
    output/decompressedEnemiesScreen.bin >> output/files.bin.zx0

SIZE0=49152

if [[ $enabled128K != true ]]; then
    echo "const BEEP_FX_ADDRESS as uinteger=$SIZE0" >> output/config.bas
    SIZEFX=$(stat --printf="%s" assets/fx/fx.tap)
else
    SIZEFX=0
fi
if [[ $enabled128K == true ]]; then
    SIZE1=0
    SIZE2=0
    SIZE3=0
    SFX=$(stat --printf="%s" assets/fx/fx.tap)
    S1=$(stat --printf="%s" output/title.png.scr.zx0)
    S2=$(stat --printf="%s" output/ending.png.scr.zx0)
    S3=$(stat --printf="%s" output/hud.png.scr.zx0)
    params=FX:$SFX,Init-Screen:$S1,End-Screen:$S2,HUD:$S3

    if [ -f assets/screens/intro.scr ]; then
        ${BIN_FOLDER}zx0 -f assets/screens/intro.scr output/intro.scr.zx0
        S4=$(stat --printf="%s" output/intro.scr.zx0)
        params=$params,Intro-Screen:$S4
    fi

    if [ -f assets/screens/gameover.scr ]; then
        ${BIN_FOLDER}zx0 -f assets/screens/gameover.scr output/gameover.scr.zx0
        S5=$(stat --printf="%s" output/gameover.scr.zx0)
        params=$params,Gameover-Screen:$S5
    fi

    python3 vendor/zxsgm/bin/memoryImageGenerator.py $params memory-bank-3.png
else
    SIZE0=$(echo "$SIZEFX + $SIZE0" | bc)
    SIZE1=$(stat --printf="%s" output/title.png.scr.zx0)
    SIZE2=$(stat --printf="%s" output/ending.png.scr.zx0)
    SIZE3=$(stat --printf="%s" output/hud.png.scr.zx0)
fi
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
SIZE16=$(stat --printf="%s" output/screenObjects.bin)
SIZE17=$(stat --printf="%s" output/screensWon.bin)
SIZE18=$(stat --printf="%s" output/decompressedEnemiesScreen.bin)
tilesetAddress=$(echo "$SIZE0 + $SIZE1 + $SIZE2 + $SIZE3 + $SIZE4 + $SIZE5" | bc)
attrAddress=$(echo "$tilesetAddress + $SIZE6" | bc)
spritesAddress=$(echo "$attrAddress + $SIZE7" | bc)
screenObjectsInitial=$(echo "$spritesAddress + $SIZE8" | bc)
screenOffsetsAddress=$(echo "$screenObjectsInitial + $SIZE9" | bc)
enemiesInScreenOffsets=$(echo "$screenOffsetsAddress + $SIZE10" | bc)
animatedTilesInScreen=$(echo "$enemiesInScreenOffsets + $SIZE11" | bc)
damageTiles=$(echo "$animatedTilesInScreen + $SIZE12" | bc)
enemiesPerScreen=$(echo "$damageTiles + $SIZE13" | bc)
enemiesPerScreenInitial=$(echo "$enemiesPerScreen + $SIZE14" | bc)
screenObjects=$(echo "$enemiesPerScreenInitial + $SIZE15" | bc)
screensWon=$(echo "$screenObjects + $SIZE16" | bc)
decompressedEnemiesScreen=$(echo "$screensWon + $SIZE17" | bc)

if [[ $enabled128K != true ]]; then
    echo "const TITLE_SCREEN_ADDRESS as uinteger=$SIZE0" >> output/config.bas
fi
address=$(echo "$SIZE0 + $SIZE1" | bc)
if [[ $enabled128K != true ]]; then
    echo "const ENDING_SCREEN_ADDRESS as uinteger=$address" >> output/config.bas
fi
address=$(echo "$address + $SIZE2" | bc)
if [[ $enabled128K != true ]]; then
    echo "const HUD_SCREEN_ADDRESS as uinteger=$address" >> output/config.bas
fi
address=$(echo "$address + $SIZE3" | bc)
echo "const MAPS_DATA_ADDRESS as uinteger=$address" >> output/config.bas
address=$(echo "$address + $SIZE4" | bc)
echo "const ENEMIES_DATA_ADDRESS as uinteger=$address" >> output/config.bas
echo "const TILESET_DATA_ADDRESS as uinteger=$tilesetAddress" >> output/config.bas
echo "const ATTR_DATA_ADDRESS as uinteger=$attrAddress" >> output/config.bas
echo "const SPRITES_DATA_ADDRESS as uinteger=$spritesAddress" >> output/config.bas
echo "const SCREEN_OBJECTS_INITIAL_DATA_ADDRESS as uinteger=$screenObjectsInitial" >> output/config.bas
echo "const SCREEN_OFFSETS_DATA_ADDRESS as uinteger=$screenOffsetsAddress" >> output/config.bas
echo "const ENEMIES_IN_SCREEN_OFFSETS_DATA_ADDRESS as uinteger=$enemiesInScreenOffsets" >> output/config.bas
echo "const ANIMATED_TILES_IN_SCREEN_DATA_ADDRESS as uinteger=$animatedTilesInScreen" >> output/config.bas
echo "const DAMAGE_TILES_DATA_ADDRESS as uinteger=$damageTiles" >> output/config.bas
echo "const ENEMIES_PER_SCREEN_DATA_ADDRESS as uinteger=$enemiesPerScreen" >> output/config.bas
echo "const ENEMIES_PER_SCREEN_INITIAL_DATA_ADDRESS as uinteger=$enemiesPerScreenInitial" >> output/config.bas
echo "const SCREEN_OBJECTS_DATA_ADDRESS as uinteger=$screenObjects" >> output/config.bas
echo "const SCREENS_WON_DATA_ADDRESS as uinteger=$screensWon" >> output/config.bas
echo "const DECOMPRESSED_ENEMIES_SCREEN_DATA_ADDRESS as uinteger=$decompressedEnemiesScreen" >> output/config.bas

if [[ $enabled128K == true ]]; then
    sizeFX=$(stat --printf="%s" assets/fx/fx.tap)
    baseAddress=$(echo "$sizeFX + $SIZE0" | bc)
    echo "const TITLE_SCREEN_ADDRESS as uinteger=$baseAddress" >> output/config.bas
    titleAddress=$(stat --printf="%s" output/title.png.scr.zx0)
    address=$(echo "$baseAddress + $titleAddress" | bc)
    echo "const ENDING_SCREEN_ADDRESS as uinteger=$address" >> output/config.bas
    endingAddress=$(stat --printf="%s" output/ending.png.scr.zx0)
    address=$(echo "$address + $endingAddress" | bc)
    echo "const HUD_SCREEN_ADDRESS as uinteger=$address" >> output/config.bas

    if [ -f assets/screens/intro.scr ]; then
        hudAddress=$(stat --printf="%s" output/hud.png.scr.zx0)
        address=$(echo "$address + $hudAddress" | bc)
        echo "const INTRO_SCREEN_ADDRESS as uinteger=$address" >> output/config.bas
        echo "#DEFINE INTRO_SCREEN_ENABLED" >> output/config.bas
    fi

    if [ -f assets/screens/gameover.scr ]; then
        introAddress=$(stat --printf="%s" output/intro.scr.zx0)
        address=$(echo "$address + $introAddress" | bc)
        echo "const GAMEOVER_SCREEN_ADDRESS as uinteger=$address" >> output/config.bas
        echo "#DEFINE GAMEOVER_SCREEN_ENABLED" >> output/config.bas
    fi
fi

bin2tap output/files.bin.zx0 output/files.tap $SIZE0 

enemiesSize=$(echo "$SIZE5 + $SIZE11 + $SIZE14 + $SIZE15 + $SIZE18" | bc)
mapsSize=$(echo "$SIZE4 + $SIZE10 + $SIZE16 + $SIZE17" | bc)

python3 vendor/zxsgm/bin/memoryImageGenerator.py FX:$SIZEFX,Init-Screen:$SIZE1,End-Screen:$SIZE2,HUD:$SIZE3,Maps:$mapsSize,Enemies:$enemiesSize,Tileset:$SIZE6,Attributes:$SIZE7,Sprites:$SIZE8,Objects:$SIZE9,Damage-Tiles:$SIZE13,Animated-Tiles:$SIZE12 memory-bank-0.png