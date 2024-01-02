BIN_FOLDER=vendor/zxsgm/bin/
PROJECT_NAME=game
DOCKER_VERSION=latest

tiled-export:
	tiled --export-map json assets/maps.tmx output/maps.json

tiled-build:
	python3 ${BIN_FOLDER}tiled-build.py
	cat output/screen*.bin.zx0 > output/map.bin.zx0
	cat output/enemiesInScreen*.bin.zx0 > output/enemies.bin.zx0

check-fx:
	@if [ ! -f assets/fx/fx.tap ]; then\
		echo "FX not detected";\
		cp -f vendor/zxsgm/default/fx.tap assets/fx/fx.tap;\
	fi

sum = $(shell expr $(1) + $(2))

# 49152
SIZE0 = 49152
SIZE1 = 0
SIZE2 = 0
SIZE3 = 0
SIZE4 = 0
SIZE5 = 0
screens-build:
	$(eval SIZEFX = $(shell stat --printf="%s" assets/fx/fx.tap))
	echo "const BEEP_FX_ADDRESS as uinteger = $(SIZE0)" >> output/config.bas
	$(eval SIZE0 = $(call sum, $(SIZEFX), $(SIZE0)))

	python3 ${BIN_FOLDER}fixColors.py assets/screens/title.png assets/screens/title.tmp.png
	python3 ${BIN_FOLDER}png2scr.py assets/screens/title.tmp.png
	java -jar ${BIN_FOLDER}zx0.jar -f assets/screens/title.tmp.png.scr output/title.png.scr.zx0
	$(eval SIZE1 = $(shell stat --printf="%s" output/title.png.scr.zx0))

	python3 ${BIN_FOLDER}fixColors.py assets/screens/ending.png assets/screens/ending.tmp.png
	python3 ${BIN_FOLDER}png2scr.py assets/screens/ending.tmp.png
	java -jar ${BIN_FOLDER}zx0.jar -f assets/screens/ending.tmp.png.scr output/ending.png.scr.zx0
	$(eval SIZE2 = $(shell stat --printf="%s" output/ending.png.scr.zx0))

	python3 ${BIN_FOLDER}fixColors.py assets/screens/hud.png assets/screens/hud.tmp.png
	python3 ${BIN_FOLDER}png2scr.py assets/screens/hud.tmp.png
	java -jar ${BIN_FOLDER}zx0.jar -f assets/screens/hud.tmp.png.scr output/hud.png.scr.zx0
	$(eval SIZE3 = $(shell stat --printf="%s" output/hud.png.scr.zx0))

	$(eval SIZE4 = $(shell stat --printf="%s" output/map.bin.zx0))
	$(eval SIZE5 = $(shell stat --printf="%s" output/enemies.bin.zx0))

	echo "const TITLE_SCREEN_ADDRESS as uinteger = $(SIZE0)" >> output/config.bas
	echo "const ENDING_SCREEN_ADDRESS as uinteger = $(call sum,$(SIZE0), $(SIZE1))" >> output/config.bas
	echo "const HUD_SCREEN_ADDRESS as uinteger = $(call sum, $(call sum, $(SIZE0), $(SIZE1)), $(SIZE2))" >> output/config.bas
	echo "const MAPS_DATA_ADDRESS as uinteger = $(call sum, $(call sum, $(call sum, $(SIZE0), $(SIZE1)), $(SIZE2)), $(SIZE3))" >> output/config.bas
	echo "const ENEMIES_DATA_ADDRESS as uinteger = $(call sum, $(call sum, $(call sum, $(call sum, $(SIZE0), $(SIZE1)), $(SIZE2)), $(SIZE3)), $(SIZE4))" >> output/config.bas

	rm -rf *.zx0

	python3 ${BIN_FOLDER}fixColors.py assets/screens/loading.png assets/screens/loading.tmp.png
	python3 ${BIN_FOLDER}png2scr.py assets/screens/loading.tmp.png
	mv assets/screens/loading.tmp.png.scr output/loading.bin

	python3 ${BIN_FOLDER}img2zxbasic/src/img2zxbasic.py -i assets/tiles.png -p assets/paperValues.txt -t tiles > output/tiles.bas
	python3 ${BIN_FOLDER}img2zxbasic/src/img2zxbasic.py -i assets/sprites.png -p assets/paperValues.txt -t sprites > output/sprites.bas

	$(eval SIZE6 = $(shell stat --printf="%s" output/tiles.bin))
	$(eval SIZE7 = $(shell stat --printf="%s" output/attrs.bin))
	$(eval SIZE8 = $(shell stat --printf="%s" output/sprites.bin))
	$(eval SIZE9 = $(shell stat --printf="%s" output/objectsInScreen.bin))
	$(eval SIZE10 = $(shell stat --printf="%s" output/screenOffsets.bin))

	$(eval tilesetAddress = $(call sum, $(call sum, $(call sum, $(call sum, $(call sum, $(SIZE0), $(SIZE1)), $(SIZE2)), $(SIZE3)), $(SIZE4)), $(SIZE5)))
	echo "const TILESET_DATA_ADDRESS as uinteger = $(tilesetAddress)" >> output/config.bas

	$(eval attrAddress = $(call sum, $(tilesetAddress), $(SIZE6)))
	echo "const ATTR_DATA_ADDRESS as uinteger = $(attrAddress)" >> output/config.bas

	$(eval spritesAddress = $(call sum, $(attrAddress), $(SIZE7)))
	echo "const SPRITES_DATA_ADDRESS as uinteger = $(spritesAddress)" >> output/config.bas

	$(eval screenObjectsAddress = $(call sum, $(spritesAddress), $(SIZE8)))
	echo "const SCREEN_OBJECTS_DATA_ADDRESS as uinteger = $(screenObjectsAddress)" >> output/config.bas

	$(eval screenOffsetsAddress = $(call sum, $(screenObjectsAddress), $(SIZE9)))
	echo "const SCREEN_OFFSETS_DATA_ADDRESS as uinteger = $(screenOffsetsAddress)" >> output/config.bas

	$(eval enemiesInScreenOffsets = $(call sum, $(screenOffsetsAddress), $(SIZE10)))
	echo "const ENEMIES_IN_SCREEN_OFFSETS_DATA_ADDRESS as uinteger = $(enemiesInScreenOffsets)" >> output/config.bas

	cat output/title.png.scr.zx0 output/ending.png.scr.zx0 output/hud.png.scr.zx0 output/map.bin.zx0 output/enemies.bin.zx0 output/tiles.bin output/attrs.bin output/sprites.bin output/objectsInScreen.bin output/screenOffsets.bin output/enemiesInScreenOffsets.bin > output/files.bin.zx0

	rm -f output/screen*.bin.zx0
	rm -f output/screen*.bin
	rm -f output/enemiesInScreen*.bin.zx0
	rm -f output/enemiesInScreen*.bin
	
	wine ${BIN_FOLDER}bin2tap.exe -o output/files.tap -a $(SIZE0) output/files.bin.zx0

compile:
	python3 ${BIN_FOLDER}zxbasic/zxbc.py -W 500 -taB main.bas
	mv -f main.tap output/${PROJECT_NAME}.tap

HEAP_ADDRESS=$(shell cat /tmp/heapAddress.txt)

build:
	$(MAKE) tiled-build
	$(MAKE) check-fx
	$(MAKE) screens-build

	# python3 ${BIN_FOLDER}zxbasic/zxbc.py -H 1024 --heap-address 63488 -S 24576 -O 4 main.bas --mmap output/map.txt --debug-memory -o output/main.bin
	python3 ${BIN_FOLDER}zxbasic/zxbc.py -H 600 -S 24576 -O 4 main.bas --mmap output/map.txt --debug-memory -o output/main.bin

	wine ${BIN_FOLDER}bas2tap.exe -a10 -s${PROJECT_NAME} ${BIN_FOLDER}loader.bas output/loader.tap
	wine ${BIN_FOLDER}bin2tap.exe -o output/loading.tap -a 16384 output/loading.bin
	wine ${BIN_FOLDER}bin2tap.exe -o output/main.tap -a 24576 output/main.bin

	@if [ -f assets/music/music.tap ]; then\
		echo "Music detected";\
		cat output/loader.tap output/loading.tap output/main.tap assets/fx/fx.tap output/files.tap assets/music/music.tap > output/${PROJECT_NAME}.tap;\
		# cat output/loader.tap output/loading.tap output/main.tap output/files.tap > output/${PROJECT_NAME}.tap;\
	else\
		cat output/loader.tap output/loading.tap output/main.tap > output/${PROJECT_NAME}.tap;\
	fi
	

build-dev:
	$(MAKE) tiled-export
	$(MAKE)	build

docker-build:
	docker build -t rtorralba/zx-game-maker:${DOCKER_VERSION} .

docker-push:
	docker push rtorralba/zx-game-maker:${DOCKER_VERSION}

run:
	fuse --machine=plus2a output/${PROJECT_NAME}.tap