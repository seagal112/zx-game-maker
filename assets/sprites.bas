dim spriteHanSoloRight1(31) as ubyte = { 14, 30, 48, 55, 36, 22, 7, 51, 104, 64, 109, 60, 0, 9, 17, 35, 224, 112, 112, 24, 192, 224, 192, 194, 31, 168, 48, 128, 0, 64, 64, 64 }
dim spriteHanSoloRight2(31) as ubyte = { 14, 30, 48, 55, 36, 22, 7, 51, 104, 64, 109, 60, 0, 9, 9, 9, 240, 120, 0, 192, 192, 224, 192, 194, 31, 168, 48, 128, 0, 64, 32, 16 }
dim spriteHanSoloLeft1(31) as ubyte = { 7, 14, 14, 24, 3, 7, 3, 67, 248, 21, 12, 1, 0, 2, 2, 2, 112, 120, 12, 236, 36, 104, 224, 204, 22, 2, 182, 60, 0, 144, 136, 196 }
dim spriteHanSoloLeft2(31) as ubyte = { 15, 30, 0, 3, 3, 7, 3, 67, 248, 21, 12, 1, 0, 2, 4, 8, 112, 120, 12, 236, 36, 104, 224, 204, 22, 2, 182, 60, 0, 144, 144, 144 }

dim spritesSet(3) as ubyte
spritesSet(0) = Create2x2Sprite(@spriteHanSoloRight1)
spritesSet(1) = Create2x2Sprite(@spriteHanSoloRight2)
spritesSet(2) = Create2x2Sprite(@spriteHanSoloLeft1)
spritesSet(3) = Create2x2Sprite(@spriteHanSoloLeft2)

' dim sprite0 = Create2x2Sprite(@spriteHanSoloRight1)