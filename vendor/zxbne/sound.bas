sub damageSound()
    NIRVANAhalt()
    NIRVANAstop()
    BEEP 0,16
    NIRVANAstart()
end sub

sub jumpSound()
    NIRVANAhalt()
    NIRVANAstop()
    BEEP 0,6
    BEEP 0,14
    NIRVANAstart()
end sub

sub killEnemySound()
    NIRVANAhalt()
    NIRVANAstop()
    BEEP 0,6
    BEEP 0,14
    BEEP 0,8
    BEEP 0,16
    NIRVANAstart()
end sub