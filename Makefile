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
	@python3 screens-build.py >> output/compile.log
	@echo -e "OK!\n"

compile:
	python3 ${BIN_FOLDER}zxbasic/zxbc.py -W 500 -taB main.bas
	mv -f main.tap output/$(PROJECT_NAME).tap

build:
	@echo "==============================================="
	@echo "=            ZX Spectrum Game Maker           ="
	@echo -e "===============================================\n"
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
	bin2tap vendor/zxsgm/loader.bin output/loader.tap 10 --header "$(PROJECT_NAME)" --block_type 1 >> output/compile.log
	bin2tap output/loading.bin output/loading.tap 16384 >> output/compile.log
	bin2tap output/main.bin output/main.tap 24576 >> output/compile.log

	@if [[ $(ENABLED_128K) == true ]]; then\
		bin2tap output/title.png.scr.zx0 output/title.tap 49152 >> output/compile.log;\
		bin2tap output/ending.png.scr.zx0 output/ending.tap 49152 >> output/compile.log;\
		bin2tap output/hud.png.scr.zx0 output/hud.tap 49152 >> output/compile.log;\
		cat output/loader.tap output/loading.tap output/main.tap assets/fx/fx.tap output/files.tap assets/music/music.tap output/title.tap output/ending.tap output/hud.tap > dist/$(PROJECT_FILE_NAME).tap;\
		if [ -f output/intro.scr.zx0 ]; then\
			bin2tap output/intro.scr.zx0 output/intro.tap 49152 >> output/compile.log;\
			cat output/intro.tap >> dist/$(PROJECT_FILE_NAME).tap;\
		fi;\
		if [ -f output/gameover.scr.zx0 ]; then\
			bin2tap output/gameover.scr.zx0 output/gameover.tap 49152 >> output/compile.log;\
			cat output/gameover.tap >> dist/$(PROJECT_FILE_NAME).tap;\
		fi;\
	else\
		cat output/loader.tap output/loading.tap output/main.tap assets/fx/fx.tap output/files.tap > dist/$(PROJECT_FILE_NAME).tap;\
	fi
	@echo -e "OK!\n"

	@echo -en "Removing temporary files... "
	@rm -f output/*.zx0 output/*.bin output/*.tap output/*.bas
	@echo -e "OK!\n"

	@echo -e "Game compiled successfully! You can find it at dist/$(PROJECT_FILE_NAME).tap.\n"
	
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