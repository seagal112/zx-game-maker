from PIL import Image
import numpy as np

def zxp_to_png(zxp_file, png_file):
    # Leer el archivo ZXP
    with open(zxp_file, 'r') as f:
        lines = f.readlines()

    # Encontrar las dos primeras líneas en blanco
    blank_line_indices = [i for i, line in enumerate(lines) if line == '\n']

    # Dividir el archivo en datos de imagen y atributos de color
    image_data = ''.join(lines[blank_line_indices[0]+1:blank_line_indices[1]]).replace('\n', '')
    color_data = ''.join(lines[blank_line_indices[1]+1:]).replace('\n', '').split(' ')

    # Convertir los datos de imagen a una matriz de píxeles
    pixels = np.array([int(image_data[i:i+8], 2) for i in range(0, len(image_data), 8)])

    # Convertir los atributos de color a una matriz de colores
    colors = [int(color, 16) for color in color_data]

    # Crear una nueva imagen y establecer los píxeles y colores
    img = Image.new('P', (256, 192))
    for i, pixel in enumerate(pixels):
        index = (i // 256) * 32 + (i % 256) // 8
        if index < len(colors):
            attribute = colors[index]  # Cada atributo de color se aplica a un bloque de 8x8 píxeles
        else:
            attribute = 0  # Valor predeterminado si no hay suficientes atributos de color
        ink = attribute & 0x07
        paper = (attribute & 0x38) >> 3
        bright = (attribute & 0x40) >> 6
        color = ink if pixel else paper
        if bright:
            color += 8
        img.putpixel((i % 256, i // 256), color)

    # Guardar la imagen como un archivo PNG
    img.save(png_file)

# Uso de la función
zxp_to_png('assets/map/tiles.zxp', 'output.png')