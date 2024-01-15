import sys
import matplotlib.pyplot as plt
import numpy as np
import os

values = sys.argv[1].split(',')

total = 0
for value in values:
    total += int(value)

bankMemory = 16383
free = bankMemory - total

species = (
    "",
    "",
    "",
)
weight_counts = {
    "FX": np.array([int(values[0])]),
    "Pantalla Inicial": np.array([int(values[1])]),
    "Pantalla Final": np.array([int(values[2])]),
    "HUD": np.array([int(values[3])]),
    "Mapas": np.array([int(values[4])]),
    "Enemigos": np.array([int(values[5])]),
    "Tileset": np.array([int(values[6])]),
    "Atributos": np.array([int(values[7])]),
    "Sprites": np.array([int(values[8])]),
    "Objetos": np.array([int(values[9])]),
    "Offsets de pantalla": np.array([int(values[10])]),
    "Offsets de enemigos": np.array([int(values[11])]),
    "Tiles animados": np.array([int(values[12])]),
    "Espacio libre": np.array([free]),
}
width = 2

colors = ['#0000cd', '#cd0000','#cd00cd', '#00cd00','#00cdcd', '#cdcd00','#0000ff', '#ff0000','#ff00ff', '#00ff00','#00ffff', '#ffff00','#ae24d1', '#999999']

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

plt.savefig("dist/memory.png", dpi=150, bbox_inches="tight", orientation = 'portrait')