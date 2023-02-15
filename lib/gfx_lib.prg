.big
.align  page
{clearBuffer
:0000 9f 73 8f 73 9c 73 8c 73 f8 00 ac f8 04 bc f8 00
:0010 5f 1f 2c 8c ca 00 0e 9c ca 00 0e 60 72 ac f0 bc
:0020 60 72 af f0 bf fc 00 d5
^0015 0e
v0016
^0019 0e
v001a
}
{fillBuffer
:0000 9f 73 8f 73 9c 73 8c 73 f8 00 ac f8 04 bc f8 ff
:0010 5f 1f 2c 8c ca 00 0e 9c ca 00 0e 60 72 ac f0 bc
:0020 60 72 af f0 bf fc 00 d5
^0015 0e
v0016
^0019 0e
v001a
}
{drawPixel
/gfx_check_bounds 0001 00
\gfx_check_bounds 0002
:0000 d4 00 00 cb 00 0a f8 ff fe d5 99 73 89 73 f8 01
/gfx_write_pixel 0015 00
\gfx_write_pixel 0016
:0010 b9 f8 00 a9 d4 00 00 60 72 a9 f0 b9 fc 00 d5
+0004
}
{clearPixel
/gfx_check_bounds 0001 00
\gfx_check_bounds 0002
:0000 d4 00 00 cb 00 0a f8 ff fe d5 99 73 89 73 f8 00
/gfx_write_pixel 0015 00
\gfx_write_pixel 0016
:0010 b9 f8 00 a9 d4 00 00 60 72 a9 f0 b9 fc 00 d5
+0004
}
{drawLine
/gfx_check_bounds 0001 00
\gfx_check_bounds 0002
:0000 d4 00 00 cb 00 0a f8 ff fe d5 97 73 87 73 88 a7
/gfx_check_bounds 0013 00
\gfx_check_bounds 0014
:0010 98 b7 d4 00 00 60 72 a7 f0 b7 c3 00 06 99 73 89
:0020 73 98 73 88 73 97 73 87 73 f8 01 b9 f8 00 a9 d4
/gfx_write_line 0030 00
\gfx_write_line 0031
:0030 00 00 60 72 a7 f0 b7 60 72 a8 f0 b8 60 72 a9 f0
:0040 b9 fc 00 d5
+0004
+001b
}
{clearLine
/gfx_check_bounds 0001 00
\gfx_check_bounds 0002
:0000 d4 00 00 cb 00 0a f8 ff fe d5 97 73 87 73 88 a7
/gfx_check_bounds 0013 00
\gfx_check_bounds 0014
:0010 98 b7 d4 00 00 60 72 a7 f0 b7 c3 00 06 99 73 89
:0020 73 98 73 88 73 97 73 87 73 f8 00 b9 f8 00 a9 d4
/gfx_write_line 0030 00
\gfx_write_line 0031
:0030 00 00 60 72 a7 f0 b7 60 72 a8 f0 b8 60 72 a9 f0
:0040 b9 fc 00 d5
+0004
+001b
}
{drawRect
/gfx_check_bounds 0001 00
\gfx_check_bounds 0002
:0000 d4 00 00 cb 00 0a f8 ff fe d5 99 73 89 73 98 73
/gfx_clip_bounds 0017 00
\gfx_clip_bounds 0018
/gfx_write_rect 001d 00
\gfx_write_rect 001e
:0010 88 73 97 73 87 73 d4 00 00 f8 01 b9 d4 00 00 60
:0020 72 a7 f0 b7 60 72 a8 f0 b8 60 72 a9 f0 b9 fc 00
:0030 d5
+0004
}
{clearRect
/gfx_check_bounds 0001 00
\gfx_check_bounds 0002
:0000 d4 00 00 cb 00 0a f8 ff fe d5 99 73 89 73 98 73
/gfx_clip_bounds 0017 00
\gfx_clip_bounds 0018
/gfx_write_rect 001d 00
\gfx_write_rect 001e
:0010 88 73 97 73 87 73 d4 00 00 f8 00 b9 d4 00 00 60
:0020 72 a7 f0 b7 60 72 a8 f0 b8 60 72 a9 f0 b9 fc 00
:0030 d5
+0004
}
{drawBlock
/gfx_check_bounds 0001 00
\gfx_check_bounds 0002
:0000 d4 00 00 cb 00 0a f8 ff fe d5 99 73 89 73 98 73
/gfx_clip_bounds 0017 00
\gfx_clip_bounds 0018
/gfx_write_block 001d 00
\gfx_write_block 001e
:0010 88 73 97 73 87 73 d4 00 00 f8 01 b9 d4 00 00 60
:0020 72 a7 f0 b7 60 72 a8 f0 b8 60 72 a9 f0 b9 fc 00
:0030 d5
+0004
}
{clearBlock
/gfx_check_bounds 0001 00
\gfx_check_bounds 0002
:0000 d4 00 00 cb 00 0a f8 ff fe d5 99 73 89 73 98 73
/gfx_clip_bounds 0017 00
\gfx_clip_bounds 0018
/gfx_write_block 001d 00
\gfx_write_block 001e
:0010 88 73 97 73 87 73 d4 00 00 f8 00 b9 d4 00 00 60
:0020 72 a7 f0 b7 60 72 a8 f0 b8 60 72 a9 f0 b9 fc 00
:0030 d5
+0004
}
{drawBitmap
/gfx_check_bounds 0001 00
\gfx_check_bounds 0002
:0000 d4 00 00 cb 00 0a f8 ff fe d5 9d 73 8d 73 99 73
/gfx_clip_bounds 001b 00
\gfx_clip_bounds 001c
:0010 89 73 98 73 88 73 97 73 87 73 d4 00 00 f8 01 b9
/gfx_write_bitmap 0021 00
\gfx_write_bitmap 0022
:0020 d4 00 00 60 72 a7 f0 b7 60 72 a8 f0 b8 60 72 a9
:0030 f0 b9 60 72 ad f0 bd fc 00 d5
+0004
}
{clearBitmap
/gfx_check_bounds 0001 00
\gfx_check_bounds 0002
:0000 d4 00 00 cb 00 0a f8 ff fe d5 9d 73 8d 73 99 73
/gfx_clip_bounds 001b 00
\gfx_clip_bounds 001c
:0010 89 73 98 73 88 73 97 73 87 73 d4 00 00 f8 00 b9
/gfx_write_bitmap 0021 00
\gfx_write_bitmap 0022
:0020 d4 00 00 60 72 a7 f0 b7 60 72 a8 f0 b8 60 72 a9
:0030 f0 b9 60 72 ad f0 bd fc 00 d5
+0004
}
{gfx_check_bounds
:0000 97 ff 40 c3 00 11 87 ff 80 c3 00 11 fc 00 c0 00
:0010 13 ff 00 d5
+0004
+000a
+000f
}
{gfx_clip_bounds
:0000 98 fa c0 ca 00 18 97 52 98 f4 ff 40 cb 00 1b fc
:0010 01 52 98 f7 b8 c3 00 1b f8 00 b8 88 fa 80 ca 00
:0020 33 87 52 88 f4 ff 80 cb 00 36 fc 01 52 88 f7 a8
:0030 c3 00 36 f8 00 a8 fc 00 d5
+0004
+000d
+0016
+001f
+0028
+0031
}
{gfx_write_pixel
:0000 9d 73 8d 73 9c 73 8c 73 f8 00 ad f8 00 bd 97 f6
:0010 f6 f6 bd 9d f6 bd 8d 76 ad 87 52 8d f4 ad 9d 7c
:0020 00 bd 8d 52 8f f4 ad 9d 52 9f 74 bd f8 01 bc 97
:0030 fa 07 ac c2 00 3e 9c fe bc 2c 8c c0 00 33 9c 52
:0040 99 c2 00 4e fe c3 00 58 0d f1 5d c0 00 5b f8 ff
:0050 f3 52 0d f2 5d c0 00 5b 0d f3 5d 60 72 ac f0 bc
:0060 60 72 ad f0 bd fc 00 d5
+0034
+003c
+0042
+0046
+004c
+0056
}
{gfx_write_line
:0000 97 52 98 f5 ca 00 1c 87 52 88 f7 a9 c3 00 16 89
/gfx_swap_points 0014 00
\gfx_swap_points 0015
/gfx_write_h_line 0017 00
\gfx_write_h_line 0018
:0010 fd 00 a9 d4 00 00 d4 00 00 c0 00 51 87 52 88 f7
:0020 ca 00 38 97 52 98 f7 a9 c3 00 32 89 fd 00 a9 d4
/gfx_swap_points 0030 00
\gfx_swap_points 0031
/gfx_write_v_line 0033 00
\gfx_write_v_line 0034
/gfx_set_steep_flag 0039 00
\gfx_set_steep_flag 003a
:0030 00 00 d4 00 00 c0 00 51 d4 00 00 89 c2 00 42 d4
/gfx_transpose_points 0040 00
\gfx_transpose_points 0041
/gfx_swap_points 004a 00
\gfx_swap_points 004b
/gfx_write_s_line 004d 00
\gfx_write_s_line 004e
:0040 00 00 87 52 88 f7 c3 00 4c d4 00 00 d4 00 00 fc
:0050 00 d5
+0005
+000d
+001a
+0021
+0029
+0036
+003d
+0047
}
{gfx_swap_points
:0000 87 52 88 a7 f0 a8 97 52 98 b7 f0 b8 d5
}
{gfx_write_h_line
:0000 9d 73 8d 73 9c 73 8c 73 f8 00 ad f8 00 bd 97 f6
:0010 f6 f6 bd 9d f6 bd 8d 76 ad 87 52 8d f4 ad 9d 7c
:0020 00 bd 8d 52 8f f4 ad 9d 52 9f 74 bd f8 01 bc 97
:0030 fa 07 ac c2 00 3e 9c fe bc 2c 8c c0 00 33 99 ca
:0040 00 48 9c 52 f8 ff f3 bc 9c 52 99 c2 00 58 fe c3
:0050 00 5e 0d f1 5d c0 00 61 0d f2 5d c0 00 61 0d f3
:0060 5d 89 c2 00 6a 1d 29 c0 00 48 60 72 ac f0 bc 60
:0070 72 ad f0 bd d5
+0034
+003c
+0040
+004c
+0050
+0056
+005c
+0063
+0068
}
{gfx_write_v_line
/gfx_write_pixel 0006 00
\gfx_write_pixel 0007
:0000 f8 00 b8 97 a8 d4 00 00 89 c2 00 16 18 88 b7 29
/gfx_write_pixel 0011 00
\gfx_write_pixel 0012
:0010 d4 00 00 c0 00 08 d5
+000a
+0014
}
{gfx_set_steep_flag
:0000 9a 73 8a 73 87 52 88 f7 aa c3 00 10 8a fd 00 aa
:0010 97 52 98 f7 ba c3 00 1c 9a fd 00 ba 8a 52 9a f7
:0020 c3 00 28 f8 00 c0 00 2a f8 01 a9 60 72 aa f0 ba
:0030 d5
+000a
+0016
+0021
+0026
}
{gfx_transpose_points
:0000 87 52 97 a7 f0 b7 88 52 98 a8 f0 b8 d5
}
{gfx_write_s_line
:0000 9a 73 8a 73 9b 73 8b 73 9c 73 8c 73 87 aa 97 ba
:0010 8a 52 88 f7 ab 9a 52 98 f7 bb c3 00 27 9b fd 00
:0020 bb f8 ff bc c0 00 2a f8 01 bc 8b f6 ac 88 52 8a
/gfx_write_pixel 003d 00
\gfx_write_pixel 003e
:0030 f7 c3 00 5f 89 ca 00 42 8a a7 9a b7 d4 00 00 c0
/gfx_write_pixel 0047 00
\gfx_write_pixel 0048
:0040 00 49 8a b7 9a a7 d4 00 00 9b 52 8c f7 ac c3 00
:0050 5b 9c 52 9a f4 ba 8b 52 8c f4 ac 1a c0 00 2d 89
/gfx_write_pixel 006f 00
:0060 ca 00 6a 8a a7 9a b7 c0 00 6e 88 b7 98 a7 d4 00
\gfx_write_pixel 0070
:0070 00 60 72 aa f0 ba 60 72 ab f0 bb 60 72 ac f0 bc
:0080 d5
+001b
+0025
+0032
+0036
+0040
+004f
+005d
+0061
+0068
}
{gfx_write_rect
:0000 9b 73 8b 73 9a 73 8a 73 87 aa 97 ba 88 ab 98 bb
/gfx_write_h_line 0013 00
\gfx_write_h_line 0014
:0010 88 a9 d4 00 00 8a a7 9a b7 8b a8 9b b8 98 a9 d4
/gfx_write_v_line 0020 00
\gfx_write_v_line 0021
:0020 00 00 8b a8 9b b8 8a a7 9a 52 98 f4 b7 88 a9 d4
/gfx_write_h_line 0030 00
\gfx_write_h_line 0031
:0030 00 00 8b a8 9b b8 9a b7 8a 52 88 f4 a7 98 a9 d4
/gfx_write_v_line 0040 00
\gfx_write_v_line 0041
:0040 00 00 60 72 aa f0 ba 60 72 ab f0 bb d5
}
{gfx_write_block
:0000 9a 73 8a 73 9c 73 8c 73 87 aa 97 ba f8 00 ac f8
/gfx_write_h_line 0018 00
\gfx_write_h_line 0019
:0010 00 bc 98 ac 1c 88 a9 d4 00 00 9a fc 01 ba 2c 88
:0020 a9 8a a7 9a b7 8c ca 00 17 60 72 aa f0 ba 60 72
:0030 ac f0 bc d5
+0027
}
{gfx_write_bitmap
:0000 9a 73 8a 73 9b 73 8b 73 9c 73 8c 73 9d 73 8d 73
:0010 87 bc 97 aa 98 ab f8 00 ac ba 88 fc 07 f6 f6 f6
:0020 bb 8c fa 07 c2 00 2d 9a fe ba c0 00 44 9d 73 8d
:0030 73 8c f6 f6 f6 52 8d f4 ad 9d 7c 00 bd 0d ba 60
:0040 72 ad f0 bd 9a fa 80 c2 00 5d 98 73 88 73 8a b7
/gfx_write_pixel 0056 00
\gfx_write_pixel 0057
:0050 9c 52 8c f4 a7 d4 00 00 60 72 a8 f0 b8 1c 8c 52
:0060 88 f7 ca 00 21 1a 9b 52 8d f4 ad 9d 7c 00 bd f8
:0070 00 ac ba 2b 8b ca 00 21 60 72 ad f0 bd 60 72 ac
:0080 f0 bc 60 72 ab f0 bb 60 72 aa f0 ba d5
+0025
+002b
+0048
+0063
+0076
}
{gfx_print_hex
:0000 9d 73 8d 73 9f 73 8f 73 f8 2b af f8 00 bf d4 ff
:0010 4b f8 2b af f8 00 bf d4 03 33 d4 03 4b 0a 0d 00
:0020 60 72 af f0 bf 60 72 ad f0 bd d5 00 00 00 00 00
v0009
^000c 2b
v0012
^0015 2b
}
{gfx_print_buffer
:0000 9a 73 8a 73 9b 73 8b 73 9c 73 8c 73 9d 73 8d 73
:0010 f8 40 ac f8 00 bc 8f ab 9f bb f8 67 af f8 00 bf
:0020 1f 1f f8 10 aa f8 00 ba 4b ad d4 ff 48 1f 2a 8a
:0030 ca 00 28 9a ca 00 28 f8 67 af f8 00 bf d4 03 33
:0040 2c 8c ca 00 1a 9c ca 00 1a f8 9a af f8 00 bf d4
:0050 03 33 60 72 ad f0 bd 60 72 ac f0 bc 60 72 ab f0
:0060 bb 60 72 aa f0 ba d5 0a 0d 58 58 20 58 58 20 58
:0070 58 20 58 58 20 58 58 20 58 58 20 58 58 20 58 58
:0080 20 58 58 20 58 58 20 58 58 20 58 58 20 58 58 20
:0090 58 58 20 58 58 20 58 58 00 00 0a 0d 00
v001b
^001e 67
^0031 28
v0032
^0035 28
v0036
v0038
^003b 67
^0043 1a
v0044
^0047 1a
v0048
v004a
^004d 9a
}
