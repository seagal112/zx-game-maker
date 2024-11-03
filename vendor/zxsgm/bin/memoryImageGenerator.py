#!/usr/bin/env python3

import os
import sys
import hashlib
import numpy as np
import pandas as pd
import plotly.express as px

# Función que genera un color hex a partir de una cadena
def stringToColor(s):
    # Generar un hash de la cadena
    hash_object = hashlib.md5(s.encode())
    # Convertir el hash a un código de color hex
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

# Inicializar colores
colors = []
labels = []
for label in weight_counts.keys():
    if label == "Free-Memory":
        colors.append("#999999")
    else:
        colors.append(stringToColor(label))
    labels.append(label + " (" + str(weight_counts[label][0]) + " bytes)")

# Crear DataFrame para Plotly Express
data = {
    'Label': labels,
    'Value': [weight_count[0] for weight_count in weight_counts.values()],
    'Color': colors,
    'x': ['' for weight_count in weight_counts.values()]
}

df = pd.DataFrame(data)

# Crear gráfico de barras apiladas
fig = px.pie(df, names='Label', values='Value', title=f"Memoria ocupada ({free} bytes libres)", color='Label', color_discrete_sequence=colors, category_orders={"Label": labels})

# Guardar gráfico
if not os.path.exists("dist"):
    os.mkdir("dist")

fig.write_image("dist/" + sys.argv[2], format='png', scale=1.5)