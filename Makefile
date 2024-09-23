SHELL := /bin/bash

BIN_FOLDER=vendor/zxsgm/bin/
DOCKER_VERSION=latest

PROJECT_NAME := $(shell jq -r '.properties | .[] | select(.name=="gameName") | .value' output/maps.json)
PROJECT_NAME := $(if $(PROJECT_NAME),$(PROJECT_NAME),"Game Name")
PROJECT_FILE_NAME := $(shell echo $(PROJECT_NAME) | tr ' ' '-')

ENABLED_128K := $(shell jq -r '.properties | .[] | select(.name=="128Kenabled") | .value // false' output/maps.json)

ifeq ($(ENABLED_128K),)
	ENABLED_128K := false
endif

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

screens-build:
	bash screens-build.sh

compile:
	python3 ${BIN_FOLDER}zxbasic/zxbc.py -W 500 -taB main.bas
	mv -f main.tap output/$(PROJECT_NAME).tap

build:
	$(MAKE) tiled-build

	$(MAKE) check-fx
	$(MAKE) screens-build

	python3 ${BIN_FOLDER}zxbasic/zxbc.py -H 128 --heap-address 23755 -S 24576 -O 4 main.bas --mmap output/map.txt -D HIDE_LOAD_MSG -o output/main.bin

	wine ${BIN_FOLDER}bas2tap.exe -a10 -s"$(PROJECT_NAME)" ${BIN_FOLDER}loader.bas output/loader.tap
	wine ${BIN_FOLDER}bin2tap.exe -o output/loading.tap -a 16384 output/loading.bin
	wine ${BIN_FOLDER}bin2tap.exe -o output/main.tap -a 24576 output/main.bin

	echo $(ENABLED_128K)

	@if [[ $(ENABLED_128K) == true ]]; then\
		echo "128K ENABLED!";\
		wine ${BIN_FOLDER}bin2tap.exe -o output/title.tap -a 49152 output/title.png.scr.zx0;\
		wine ${BIN_FOLDER}bin2tap.exe -o output/ending.tap -a 49152 output/ending.png.scr.zx0;\
		wine ${BIN_FOLDER}bin2tap.exe -o output/hud.tap -a 49152 output/hud.png.scr.zx0;\
		cat output/loader.tap output/loading.tap output/main.tap assets/fx/fx.tap output/files.tap assets/music/music.tap output/title.tap output/ending.tap output/hud.tap > dist/$(PROJECT_FILE_NAME).tap;\
	else\
		echo "48K ENABLED!";\
		cat output/loader.tap output/loading.tap output/main.tap assets/fx/fx.tap output/files.tap > dist/$(PROJECT_FILE_NAME).tap;\
	fi
	

build-dev:
	$(MAKE) tiled-export
	$(MAKE)	build

docker-build:
	docker build -t rtorralba/zx-game-maker:${DOCKER_VERSION} .

docker-push:
	docker push rtorralba/zx-game-maker:${DOCKER_VERSION}

run:
	fuse --machine=plus2a dist/$(PROJECT_FILE_NAME).tap

run-48:
	fuse --machine=48 dist/$(PROJECT_FILE_NAME).tap