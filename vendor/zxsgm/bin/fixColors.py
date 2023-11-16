import sys
from PIL import Image
import numpy as np

def closest_color(rgb, colors):
    rgb = np.array(rgb[:3])  # Ignora el componente alpha
    color_diffs = np.sum((colors - rgb)**2, axis=1)
    return colors[np.argmin(color_diffs)]

def adjust_colors(img):
    # Define la paleta de colores de ZX Spectrum
    spectrum_palette = [
        (0, 0, 0),       # Negro
        (0, 0, 255),     # Azul
        (255, 0, 0),     # Rojo
        (255, 0, 255),   # Magenta
        (0, 255, 0),     # Verde
        (0, 255, 255),   # Cian
        (255, 255, 0),   # Amarillo
        (255, 255, 255), # Blanco
    ]

    # Convierte la imagen a RGB si no lo es ya
    if img.mode != 'RGBA':
        img = img.convert('RGBA')

    # Crea una imagen con los colores más cercanos de la paleta
    img_closest_colors = Image.new('RGBA', img.size)
    for x in range(img.width):
        for y in range(img.height):
            color = img.getpixel((x, y))
            closest_color_rgb = closest_color(color, np.array(spectrum_palette))
            img_closest_colors.putpixel((x, y), tuple(closest_color_rgb))

    return img_closest_colors

# Abre la imagen PNG
img = Image.open(sys.argv[1])

# Ajusta los colores de la imagen
img = adjust_colors(img)

# Guarda la imagen ajustada
img.save(sys.argv[2])