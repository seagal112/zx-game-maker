'REM --SPRITE SECTION--

asm

SPRITE_BUFFER:
TEST_ADDRESS:
    DEFB 000h, 000h, 000h, 000h, 000h, 001h, 00Fh, 018h
    DEFB 030h, 020h, 060h, 030h, 010h, 018h, 008h, 00Fh
    DEFB 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
    DEFB 000h, 000h, 000h, 000h, 000h, 080h, 0E0h, 018h
    DEFB 008h, 008h, 008h, 00Ch, 008h, 018h, 030h, 0C0h
    DEFB 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
    DEFB 000h, 000h, 000h, 000h, 000h, 000h, 000h, 001h
    DEFB 003h, 002h, 006h, 003h, 001h, 001h, 000h, 000h
    DEFB 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
    DEFB 000h, 000h, 000h, 000h, 000h, 018h, 0FEh, 081h
    DEFB 000h, 000h, 000h, 000h, 000h, 081h, 083h, 0FCh
    DEFB 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
    DEFB 000h, 000h, 000h, 000h, 000h, 000h, 000h, 080h
    DEFB 080h, 080h, 080h, 0C0h, 080h, 080h, 000h, 000h
    DEFB 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h

SPRITE_INDEX:
    DEFW (SPRITE_BUFFER + 0)
    DEFW (SPRITE_BUFFER + 120)

SPRITE_COUNT:
    DEFB 1

end asm

#define TEST_INDEX 1

'REM --TILE SECTION--

#define EMPTY_TILE_INDEX 0
#define TILE_INDEX 1

Dim tileSet(5,8) as uByte => { _
{ $00, $00, $00, $00, $00, $00, $00, $00 }, _
{ $00, $70, $F8, $1F, $5F, $1F, $1F, $1F }, _
{ $1F, $1F, $0F, $00, $00, $00, $00, $00 }, _
{ $00, $00, $00, $E0, $E0, $F0, $F8, $F8 }, _
{ $E0, $E0, $F0, $F8, $18, $00, $00, $00 } _
}

Dim tileColors(5) as ubyte => { $0, $38, $38, $38, $38 }