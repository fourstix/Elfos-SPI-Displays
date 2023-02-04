[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS sh1106_lib.asm

[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_lib.asm

[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS pixels.asm
[Your_Path]\Link02\link02 -e -s pixels.prg sh1106_lib.prg gfx_lib.prg

[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS linetest.asm
[Your_Path]\Link02\link02 -e -s linetest.prg sh1106_lib.prg gfx_lib.prg

[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS lines.asm
[Your_Path]\Link02\link02 -e -s lines.prg sh1106_lib.prg gfx_lib.prg

[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS reversed.asm
[Your_Path]\Link02\link02 -e -s reversed.prg sh1106_lib.prg gfx_lib.prg

[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS boxes.asm
[Your_Path]\Link02\link02 -e -s boxes.prg sh1106_lib.prg gfx_lib.prg
