SHELL := /bin/bash

BIN_FOLDER=vendor/zxsgm/bin/
DOCKER_VERSION=1.0rc

PROJECT_NAME := $(shell jq -r '.properties | .[] | select(.name=="gameName") | .value' output/maps.json)
PROJECT_NAME := $(if $(PROJECT_NAME),$(PROJECT_NAME),"Game Name")
PROJECT_FILE_NAME := $(shell echo $(PROJECT_NAME) | tr ' ' '-')

ENABLED_128K := $(shell jq -r '.properties | .[] | select(.name=="128Kenabled") | .value // false' output/maps.json)

ifeq ($(ENABLED_128K),)
	ENABLED_128K := false
endif

tiled-export:
	@tiled --export-map json assets/map/maps.tmx output/maps.json >> /dev/null

tiled-build:
	@echo -ne "Exporting game from Tiled... "
	@python3 ${BIN_FOLDER}tiled-build.py >> output/compile.log
	@cat output/screen*.bin.zx0 > output/map.bin.zx0
	@cat output/enemiesInScreen*.bin.zx0 > output/enemies.bin.zx0
	@echo -e "OK!\n"

check-fx:
	@if [ ! -d assets/fx ]; then\
		echo -ne "FX folder not detected, creating... ";\
		mkdir assets/fx;\
		echo -e "OK!\n";\
	fi
	@if [ ! -f assets/fx/fx.tap ]; then\
		echo -ne "FX not detected. Applying default... ";\
		cp -f vendor/zxsgm/default/fx.tap assets/fx/fx.tap;\
		echo -e "OK!\n";\
	fi

screens-build:
	@echo -ne "Building screens... "
	@bash screens-build.sh >> output/compile.log
	@echo -e "OK!\n"

compile:
	python3 ${BIN_FOLDER}zxbasic/zxbc.py -W 500 -taB main.bas
	mv -f main.tap output/$(PROJECT_NAME).tap

build:
	@rm -f output/compile.log

	@if [[ $(ENABLED_128K) == true ]]; then\
		echo -e "128K Version\n";\
	else\
		echo -e "48K Version\n";\
	fi

	$(MAKE) tiled-build

	$(MAKE) check-fx
	$(MAKE) screens-build

	@echo -ne "Compiling game... "
	@python3 ${BIN_FOLDER}zxbasic/zxbc.py -H 128 --heap-address 23755 -S 24576 -O 4 main.bas --mmap output/map.txt -D HIDE_LOAD_MSG --expect-warnings=999 -o output/main.bin
	@echo -e "OK!\n"

	@echo -ne "Checking memory... "	
	@python3 check-memory.py
	@echo -e "OK!\n"

	@echo -ne "Building TAP file... "
	@wine ${BIN_FOLDER}bas2tap.exe -a10 -s"$(PROJECT_NAME)" ${BIN_FOLDER}loader.bas output/loader.tap >> output/compile.log
	@wine ${BIN_FOLDER}bin2tap.exe -o output/loading.tap -a 16384 output/loading.bin >> output/compile.log
	@wine ${BIN_FOLDER}bin2tap.exe -o output/main.tap -a 24576 output/main.bin >> output/compile.log

	@if [[ $(ENABLED_128K) == true ]]; then\
		wine ${BIN_FOLDER}bin2tap.exe -o output/title.tap -a 49152 output/title.png.scr.zx0;\
		wine ${BIN_FOLDER}bin2tap.exe -o output/ending.tap -a 49152 output/ending.png.scr.zx0;\
		wine ${BIN_FOLDER}bin2tap.exe -o output/hud.tap -a 49152 output/hud.png.scr.zx0;\
		cat output/loader.tap output/loading.tap output/main.tap assets/fx/fx.tap output/files.tap assets/music/music.tap output/title.tap output/ending.tap output/hud.tap > dist/$(PROJECT_FILE_NAME).tap;\
	else\
		cat output/loader.tap output/loading.tap output/main.tap assets/fx/fx.tap output/files.tap > dist/$(PROJECT_FILE_NAME).tap;\
	fi
	@echo -e "OK!\n"

	@echo -en "Removing temporary files... "
	@rm -f output/*.zx0 output/*.bin output/*.tap output/*.bas
	@echo -e "OK!\n"

	@echo -e "Game compiled successfully! You can find at dist/$(PROJECT_FILE_NAME).tap.\n"
	
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