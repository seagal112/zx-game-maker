SUB FASTCALL PaginarMemoria(banco AS UByte)
    ASM
        ld d,a
        ; Con FASTCALL banco se coloca en A
        ld a,($5b5c)
        ; Leemos BANKM
        AND %11111000
        ; Reseteamos los 3 primeros bits
        OR d
        ; Ajustamos los 3 primeros bits con el
        ; "banco"
        ld bc,$7ffd
        ; Puerto donde haremos el OUT
        di
        ; Deshabilitamos las interrupciones
        ld ($5b5c),a
        ; Actualizamos BANKM
        OUT (c),a
        ; Hacemos el OUT
        ei
        ; Habilitamos las interrupciones
    END ASM
END SUB