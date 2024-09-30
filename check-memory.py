import os
import sys

last_line = os.popen("tail -n 1 output/map.txt").read()
memoryAddress = last_line.split(":")[0]

if int(memoryAddress, 16) > 0xC000:
    print("")
    print("========================================================")
    print("ERROR: Memory address is greater than $C000")
    print("Try to disable some features in the map configuration")
    print("========================================================")
    print("")
    sys.exit(1)
