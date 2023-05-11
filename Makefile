BIN_FOLDER=vendor/zxbne/bin/
PROJECT_NAME=z-lee
tiled-build:
	tiled --export-map json assets/maps.tmx output/maps.json
	python3 ${BIN_FOLDER}tiled-build.py
build:
	$(MAKE) tiled-build
	../../zxbasic-1.16.4-linux64/zxbasic/zxbc.py -taB main.bas
	cat vendor/zxbne/loader.tap main.tap > output/${PROJECT_NAME}.tap
	rm main.tap
run:
	fuse --machine=plus2a output/${PROJECT_NAME}.tap