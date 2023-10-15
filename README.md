# ZX Game Maker

Tool for create ZX Spectrum games visually using [Tiled](https://www.mapeditor.org/) and the image editor that you prefers. We recommend [ZX Paintbrush](https://sourcesolutions.itch.io/zx-paintbrush), But you can use whatever you want just using ZX Spectrum requeriments (color, size)

## Tech

ZX Game Maker use [Boriel's ZX Basic](https://zxbasic.readthedocs.io/en/docs/) and [GuSprites sprites library](https://github.com/gusmanb/GuSprites) and python for scripting

## How to use

### Assets
#### Screens

You should create 3 screens png into assets/screens folder, loading.png, title.png, ending.png for loader, title screen and ending screen repectively

#### Tiles

You should create a 256x48 tiles png file (tiles.png) into assets folder. ZX Game Maker works with 8x8 pixels tiles, then you can create 256 tiles into this png.

#### Sprites

You should create a 256 x 32 sprites png file (sprites.png) into assets folder. Each sprite is 16x16 pixels.

The 8 first sprits are reserved for game main character (0-2 for right movement, 3 for right jump, 4-6 for left movement, 7 for left jump).

The following 8 tiles wil be used for movement platforms, 2 tiles for each platform for animation.

The rest 16 tiles are reserved for enemies, 4 for each enemy, 2 frames for direction