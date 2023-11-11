BIN_FOLDER=vendor/zxsgm/bin/
PROJECT_NAME=game

tiled-export:
	tiled --export-map json assets/maps.tmx output/maps.json

tiled-build:
	python3 ${BIN_FOLDER}tiled-build.py

screens-build:
	python3 ${BIN_FOLDER}png2scr.py assets/screens/title.png
	java -jar ${BIN_FOLDER}zx0.jar -f assets/screens/title.png.scr output/title.png.scr.zx0
	rm assets/screens/title.png.scr

	python3 ${BIN_FOLDER}png2scr.py assets/screens/ending.png
	java -jar ${BIN_FOLDER}zx0.jar -f assets/screens/ending.png.scr output/ending.png.scr.zx0
	rm assets/screens/ending.png.scr

	python3 ${BIN_FOLDER}png2scr.py assets/screens/hud.png
	java -jar ${BIN_FOLDER}zx0.jar -f assets/screens/hud.png.scr output/hud.png.scr.zx0
	rm assets/screens/hud.png.scr

	python3 ${BIN_FOLDER}png2scr.py assets/screens/loading.png
	mv assets/screens/loading.png.scr output/loading.bin

	python3 ${BIN_FOLDER}img2zxbasic/src/img2zxbasic.py -i assets/tiles.png -p assets/paperValues.txt -t tiles > output/tiles.bas
	python3 ${BIN_FOLDER}img2zxbasic/src/img2zxbasic.py -i assets/sprites.png -p assets/paperValues.txt -t sprites > output/sprites.bas

compile:
	python3 ${BIN_FOLDER}zxbasic/zxbc.py -taB main.bas
	mv -f main.tap ${PROJECT_NAME}.tap

build:
	$(MAKE) tiled-build
	$(MAKE) screens-build
	python3 ${BIN_FOLDER}zxbasic/zxbc.py -D HIDE_LOAD_MSG main.bas -o output/main.bin

	wine ${BIN_FOLDER}bas2tap.exe -a10 -s${PROJECT_NAME} ${BIN_FOLDER}loader.bas output/loader.tap
	wine ${BIN_FOLDER}bin2tap.exe -o output/loading.tap -a 16384 output/loading.bin
	wine ${BIN_FOLDER}bin2tap.exe -o output/main.tap -a 32768 output/main.bin

	cat output/loader.tap output/loading.tap output/main.tap > output/${PROJECT_NAME}.tap

	rm -f *.bin output/*.bin output/*.bas output/loading.tap output/main.tap output/*.json output/*.zx0 output/loader.tap

build-dev:
	$(MAKE) tiled-export
	$(MAKE)	build

run:
	fuse --machine=plus2a output/${PROJECT_NAME}.tap