dim hanSolo(3,31) as ubyte = { _
    { 14, 30, 48, 55, 36, 22, 7, 51, 104, 64, 109, 60, 0, 9, 17, 35, 224, 112, 112, 24, 192, 224, 192, 194, 31, 168, 48, 128, 0, 64, 64, 64 }, _
    { 14, 30, 48, 55, 36, 22, 7, 51, 104, 64, 109, 60, 0, 9, 9, 9, 240, 120, 0, 192, 192, 224, 192, 194, 31, 168, 48, 128, 0, 64, 32, 16 }, _
    { 7, 14, 14, 24, 3, 7, 3, 67, 248, 21, 12, 1, 0, 2, 2, 2, 112, 120, 12, 236, 36, 104, 224, 204, 22, 2, 182, 60, 0, 144, 136, 196 }, _
    { 15, 30, 0, 3, 3, 7, 3, 67, 248, 21, 12, 1, 0, 2, 4, 8, 112, 120, 12, 236, 36, 104, 224, 204, 22, 2, 182, 60, 0, 144, 144, 144 } _
}

dim spritesSet(3) as ubyte
spritesSet(0) = Create2x2Sprite(@hanSolo)
spritesSet(1) = Create2x2Sprite(@hanSolo + 32)
spritesSet(2) = Create2x2Sprite(@hanSolo + 64)
spritesSet(3) = Create2x2Sprite(@hanSolo + 96)

' dim sprite0 = Create2x2Sprite(@spriteHanSoloRight1)

dim ememy1Left(31) as ubyte = {3, 7, 7, 7, 0, 3, 7, 4, 4, 0, 174, 2, 24, 1, 1, 3, 252, 254, 254, 250, 0, 142, 253, 199, 190, 1, 187, 154, 0, 184, 156, 142}
dim ememy1Right(31) as ubyte = {63, 127, 127, 95, 0, 113, 191, 227, 125, 128, 221, 89, 0, 29, 57, 113, 192, 224, 224, 224, 0, 192, 224, 32, 32, 0, 117, 64, 24, 128, 128, 192}

dim spriteEnemy1Left as ubyte = Create2x2Sprite(@ememy1Left)
dim spriteEnemy1Right as ubyte = Create2x2Sprite(@ememy1Right)