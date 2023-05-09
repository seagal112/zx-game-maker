#define disableInterrupts() \
    asm                \
        di     \
    end asm

#define enableInterrupts() \
    asm                \
        ei     \
    end asm

sub debug(message)
    PRINT AT 16,16; message
end sub