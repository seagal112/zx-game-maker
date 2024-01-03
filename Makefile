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
	@if [ ! -d assets/fx ]; then\
		echo "FX folder not detected";\
		mkdir assets/fx;\
	fi
	@if [ ! -f assets/fx/fx.tap ]; then\
		echo "FX not detected";\
		cp -f vendor/zxsgm/default/fx.tap assets/fx/fx.tap;\
	fi

sum = $(shell expr $(1) + $(2))

screens-build:
	bash screens-build.sh

compile:
	python3 ${BIN_FOLDER}zxbasic/zxbc.py -W 500 -taB main.bas
	mv -f main.tap output/${PROJECT_NAME}.tap

HEAP_ADDRESS=$(shell cat /tmp/heapAddress.txt)

build:
	$(MAKE) tiled-build
	$(MAKE) check-fx
	$(MAKE) screens-build

	python3 ${BIN_FOLDER}zxbasic/zxbc.py -H 512 -S 24576 -O 4 main.bas --mmap output/map.txt -D HIDE_LOAD_MSG --debug-memory -o output/main.bin

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

run-48:
	fuse --machine=48 output/${PROJECT_NAME}.tap