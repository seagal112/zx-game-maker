# ZX Game Maker

Tool for create ZX Spectrum games visually using [Tiled](https://www.mapeditor.org/) and the image editor that you prefers. We recommend [ZX Paintbrush](https://sourcesolutions.itch.io/zx-paintbrush), But you can use whatever you want just using ZX Spectrum requeriments (color, size)

## Tech

ZX Game Maker use [Boriel's ZX Basic](https://zxbasic.readthedocs.io/en/docs/) and [GuSprites sprites library](https://github.com/gusmanb/GuSprites) and python for scripting

## Installation

Install python 3.12 or newer [https://www.python.org/downloads/](https://www.python.org/downloads/)
Download and unzip this repository and rename the folder with game name, for example your-game-folder.

Then open console (PowerShell in windows) and execute the following:

```bash
cd your-game-folder
python -m venv venv
pip install -r requeriments.txt
```

## Usage

Activate virtual environment:

### Linux/MacOS
```bash
source venv/bin/activate
```

### Windows
```bash
source venv\Scripts\activate
```

Modify the game into assets folder and for compile and create game excute the following command:

```bash
python build.py
```

## Créditos

* [Raül Torralba](https://github.com/rtorralba) (Autor)
* [Juan J. Martínez](https://github.com/reidrac) png2src
* [Michal Jurica](https://sourceforge.net/u/mikezt/) [ub880d](https://sourceforge.net/u/ub880d) bin2tap
* [Andy Balaam](https://github.com/andybalaam) bas2tap
* [Einar Saukas](https://github.com/einar-saukas) ZX0
* [PixelArtM](https://twitter.com/PixelArtM) Sprites
* [Isaías](https://isaiasdiaz.itch.io/) make-game.bat

## Special Thanks

* [Jose Rodriguez](https://github.com/boriel)
* [Agustín Gimenez Bernad](https://github.com/gusmanb)
* [Tiled](https://www.mapeditor.org/) specially to **eishiya**
* [Duefectu](https://twitter.com/Duefectu)
* [cmgonzalez](https://github.com/cmgonzalez)
* [Augusto Ruiz](https://github.com/AugustoRuiz)
* [@briefer_666](https://briefer.itch.io/)
* [cronomantic](https://github.com/cronomantic)

Y a todo el grupo de ZX Basic de Boriel de Telegram