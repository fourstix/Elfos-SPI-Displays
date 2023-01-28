[Your_Pathname]\Asm02\asm02 -L -D1802MINIPLUS sh1106_lib.asm

[Your_Pathname]\Asm02\asm02 -L -D1802MINIPLUS splash.asm
[Your_Pathname]\Link02\link02 -e -s splash.prg sh1106_lib.prg

[Your_Pathname]\Asm02\asm02 -L -D1802MINIPLUS clear.asm
[Your_Pathname]\Link02\link02 -e -s clear.prg sh1106_lib.prg

[Your_Pathname]\Asm02\asm02 -L -D1802MINIPLUS show.asm
[Your_Pathname]\Asm02\asm02 -L pixiecvt.asm
[Your_Pathname]\Link02\link02 -e show.prg pixiecvt.prg sh1106_lib.prg