sub damageSound()
    NIRVANAstop()
    BEEP 0,16
    NIRVANAstart()
end sub

sub jumpSound()
    NIRVANAstop()
    BEEP 0,6
    BEEP 0,14
    NIRVANAstart()
end sub

sub killEnemySound()
    NIRVANAstop()
    BEEP 0,6
    BEEP 0,14
    BEEP 0,8
    BEEP 0,16
    NIRVANAstart()
end sub