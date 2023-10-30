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
	#python3 ${BIN_FOLDER}png2scr.py assets/screens/loading.png
	docker run -it -u $(id -u):$(id -g) -v ${PWD}:/share rtorralba/img2zxbasic -i /share/assets/tiles.png -p /share/assets/paperValues.txt -t tiles > output/tiles.bas
	docker run -it -u $(id -u):$(id -g) -v ${PWD}:/share rtorralba/img2zxbasic -i /share/assets/sprites.png -p /share/assets/paperValues.txt -t sprites > output/sprites.bas

build:
	$(MAKE) tiled-build
	$(MAKE) screens-build
	docker run --user $(id -u):$(id -g) -v ${PWD}:/app rtorralba/zxbasic -tBa /app/main.bas
	# cat vendor/zxbne/loader.tap main.tap assets/music.tap > output/${PROJECT_NAME}.tap
	mv -f main.tap output/${PROJECT_NAME}.tap
run:
	fuse --machine=plus2a output/${PROJECT_NAME}.tap