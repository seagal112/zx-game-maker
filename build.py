import os
import subprocess
import json
import shutil
import sys
from pathlib import Path

verbose = False

BIN_FOLDER = Path("vendor/zxsgm/bin/")
TILED_SCRIPT = Path("vendor/zxsgm/bin/tiled-build.py")
MAPS_FILE = str(Path("assets/map/maps.tmx"))
ZXBASIC_PATH = str(Path("vendor/zxsgm/bin/zxbasic/zxbc.py"))

def get_project_name():
    with open("output/maps.json", "r") as f:
        maps_json = json.load(f)
    project_name = next((prop["value"] for prop in maps_json["properties"] if prop["name"] == "gameName"), "Game Name")
    return project_name

def get_enabled_128k():
    with open("output/maps.json", "r") as f:
        maps_json = json.load(f)
    enabled_128k = next((prop["value"] for prop in maps_json["properties"] if prop["name"] == "128Kenabled"), False)
    return enabled_128k

PROJECT_NAME = get_project_name()
PROJECT_FILE_NAME = PROJECT_NAME.replace(" ", "-")
ENABLED_128K = get_enabled_128k()
OUTPUT_FILE = Path(f"dist/{PROJECT_FILE_NAME}.tap")
DEFAULT_FX = Path("assets/fx/default_fx.tap")

def run_command(command):
    global verbose
    if verbose:
        result = subprocess.call(command, shell=True)
    else:
        result = subprocess.call(command, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if result != 0:
        print(f"Error executing command: {command}")
        sys.exit(1)

def tiled_export():
    print("Exporting game from Tiled... ", end="")
    run_command("tiled --export-map json " + MAPS_FILE + " " + str(Path("output/maps.json")))
    print("OK!")

def tiled_build():
    print("Building tiled into code... ", end="")
    run_command(f"python3 {TILED_SCRIPT}")
    print("OK!")

def check_fx():
    if not os.path.isdir("assets/fx"):
        print("FX folder not detected, creating... ", end="")
        os.makedirs(str(Path("assets/fx")))
        print("OK!")
    if not os.path.isfile("assets/fx/fx.tap"):
        print("FX not detected. Applying default... ", end="")
        shutil.copy(f"{DEFAULT_FX}", str(Path("assets/fx/fx.tap")))
        print("OK!")

def screens_build():
    print("Building screens... ", end="")
    run_command(f"python3 screens-build.py")
    print("OK!")

def compiling_game():
    print("Compiling game... ", end="")
    run_command(ZXBASIC_PATH + " -H 128 --heap-address 23755 -S 24576 -O 4 main.bas --mmap " + str(Path("output/map.txt")) + " -D HIDE_LOAD_MSG -o " + str(Path("output/main.bin")))
    print("OK!")

def check_memory():
    print("Checking memory... ", end="")
    run_command(f"python3 check-memory.py")
    print("OK!")

def concatenate_files(output_file, input_files):
    with open(output_file, "wb") as out_file:
        for file in input_files:
            with open(file, "rb") as in_file:
                out_file.write(in_file.read())

def taps_build():
    print("Building TAP files... ", end="")
    run_command("bin2tap " + str(Path("vendor/zxsgm/loader.bin")) + " " + str(Path("output/loader.tap")) + " 10 --header \"" + PROJECT_NAME + "\" --block_type 1")
    run_command("bin2tap " + str(Path("output/loading.bin")) + " " + str(Path("output/loading.tap")) + " 16384")
    run_command("bin2tap " + str(Path("output/main.bin")) + " " + str(Path("output/main.tap")) + " 24576")

    if ENABLED_128K:
        run_command("bin2tap " + str(Path("output/title.png.scr.zx0")) + " " + str(Path("output/title.tap")) + " 49152")
        run_command("bin2tap " + str(Path("output/ending.png.scr.zx0")) + " " + str(Path("output/ending.tap")) + " 16384")
        run_command("bin2tap " + str(Path("output/hud.png.scr.zx0")) + " " + str(Path("output/hud.tap")) + " 24576")
        input_files = [
            str(Path("output/loader.tap")),
            str(Path("output/loading.tap")),
            str(Path("output/main.tap")),
            str(Path("assets/fx/fx.tap")),
            str(Path("output/files.tap")),
            str(Path("assets/music/music.tap")),
            str(Path("output/title.tap")),
            str(Path("output/ending.tap")),
            str(Path("output/hud.tap"))
        ]

        if os.path.isfile("output/intro.scr.zx0"):
            run_command("bin2tap " + str(Path("output/intro.scr.zx0")) + " " + str(Path("output/intro.tap")) + " 49152")
            input_files.append("output/intro.tap")
        
        if os.path.isfile("output/gameover.scr.zx0"):
            run_command("bin2tap " + str(Path("output/gameover.scr.zx0")) + " " + str(Path("output/gameover.tap")) + " 49152")
            input_files.append("output/gameover.tap")
    else:
        input_files = [
            str(Path("output/loader.tap")),
            str(Path("output/loading.tap")),
            str(Path("output/main.tap")),
            str(Path("assets/fx/fx.tap")),
            str(Path("output/files.tap")),
        ]

    
    concatenate_files(OUTPUT_FILE, input_files)

    print("OK!")

def remove_temp_files():
    print("Removing temporary files... ", end="")
    for file in os.listdir("output"):
        if file.endswith(".zx0") or file.endswith(".bin") or file.endswith(".tap") or file.endswith(".bas"):
            os.remove(os.path.join("output", file))
    print("OK!\n")

def build():
    print("============================================")
    print("=          ZX SPECTRUM GAME MAKER          =")
    print("============================================")

    tiled_export()

    tiled_build()

    check_fx()

    screens_build()

    compiling_game()

    check_memory()

    taps_build()

    remove_temp_files()

    print(f"Game compiled successfully! You can find it at dist/{PROJECT_FILE_NAME}.tap.\n")

def main():
    global verbose
    import argparse

    parser = argparse.ArgumentParser(description="Build and manage the ZX Spectrum game project.")
    parser.add_argument("-v", "--verbose", action="store_true", help="Show detailed output")
    
    args = parser.parse_args()
    verbose = args.verbose

    build()

if __name__ == "__main__":
    main()