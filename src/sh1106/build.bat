[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS init_oled.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS clear_oled.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS show_oled.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS position_oled.asm

type init_oled.prg clear_oled.prg show_oled.prg position_oled.prg > sh1106_oled.lib
