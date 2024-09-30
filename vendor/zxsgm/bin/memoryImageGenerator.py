import sys
import matplotlib.pyplot as plt
import numpy as np
import os
import hashlib


# function that generate hex color from string
def stringToColor(s):
    # Generate a hash of the string
    hash_object = hashlib.md5(s.encode())
    # Convert the hash to a hex color code
    hex_color = '#' + hash_object.hexdigest()[:6]
    return hex_color

bars = sys.argv[1].split(',')

weight_counts = {}

total = 0
for bar in bars:
    values = bar.split(':')
    if int(values[1]) == 0:
        continue
    total += int(values[1])
    weight_counts[values[0]] = np.array([int(values[1])])

bankMemory = 16383
free = bankMemory - total

weight_counts["Free-Memory"] = np.array([free])

species = (
    "",
    "",
    "",
)
width = 2

# initialize colors
colors = []

for label, weight_count in weight_counts.items():
    if label == "Free-Memory":
        colors.append("#999999")
    colors.append(stringToColor(label))

fig, ax = plt.subplots()
bottom = np.zeros(3)

counter = 0
for label, weight_count in weight_counts.items():
    p = ax.bar(species, weight_count, width=0.3, label=label + " (" + str(weight_count[0]) + " bytes)", bottom=bottom, color=colors[counter])
    bottom += weight_count
    counter += 1

ax.set_title("Memoria ocupada (" + str(free) + " bytes libres)")
ax.legend(loc="upper right")

if not os.path.exists("dist"):
    os.mkdir("dist")

plt.savefig("dist/" + sys.argv[2], dpi=150, bbox_inches="tight", orientation = 'portrait')