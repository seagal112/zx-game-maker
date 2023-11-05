BIN_FOLDER=vendor/zxbne/bin/
PROJECT_NAME=z-lee

tiled-build:
	tiled --export-map json assets/maps.tmx output/maps.json
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

	docker run -it -u $(id -u):$(id -g) -v ${PWD}:/share rtorralba/img2zxbasic -i /share/assets/tiles.png -p /share/assets/paperValues.txt -t tiles > output/tiles.bas
	docker run -it -u $(id -u):$(id -g) -v ${PWD}:/share rtorralba/img2zxbasic -i /share/assets/sprites.png -p /share/assets/paperValues.txt -t sprites > output/sprites.bas

compile:
	docker run --user $(id -u):$(id -g) -v ${PWD}:/app rtorralba/zxbasic -taB /app/main.bas
	mv -f main.tap ${PROJECT_NAME}.tap

build:
	$(MAKE) tiled-build
	$(MAKE) screens-build
	docker run --user $(id -u):$(id -g) -v ${PWD}:/app rtorralba/zxbasic -D HIDE_LOAD_MSG /app/main.bas

	${BIN_FOLDER}bas2tap -a10 -s${PROJECT_NAME} ${BIN_FOLDER}loader.bas output/loader.tap
	wine ${BIN_FOLDER}bin2tap.exe -o output/loading.tap -a 16384 output/loading.bin
	wine ${BIN_FOLDER}bin2tap.exe -o output/main.tap -a 32768 main.bin

	cat output/loader.tap output/loading.tap output/main.tap > ${PROJECT_NAME}.tap

	rm -f *.bin output/*.bin
run:
	fuse --machine=plus2a ${PROJECT_NAME}.tap