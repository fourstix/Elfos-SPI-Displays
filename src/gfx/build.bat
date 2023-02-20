[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS clear_buffer.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS fill_buffer.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS draw_pixel.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS clear_pixel.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS draw_line.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS clear_line.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS draw_rect.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS clear_rect.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS draw_block.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS clear_block.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS draw_bitmap.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS clear_bitmap.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS draw_char.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS draw_string.asm


[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_check_bounds.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_display_ptr.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_pixel.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_line.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_h_line.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_v_line.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_s_line.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_swap_points.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_set_steep_flag.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_transpose_points.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_clip_bounds.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_rect.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_block.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_bitmap.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_char.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_adj_cursor.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_clear_bg.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_ascii_font.asm

type clear_buffer.prg fill_buffer.prg draw_pixel.prg clear_pixel.prg  draw_line.prg clear_line.prg > gfx_oled.lib
type draw_rect.prg clear_rect.prg draw_block.prg clear_block.prg draw_bitmap.prg clear_bitmap.prg >> gfx_oled.lib
type draw_char.prg draw_string.prg gfx_ascii_font.prg >> gfx_oled.lib
type gfx_check_bounds.prg gfx_display_ptr.prg gfx_write_pixel.prg gfx_write_line.prg >> gfx_oled.lib
type gfx_write_h_line.prg gfx_write_v_line.prg gfx_write_s_line.prg gfx_swap_points.prg >> gfx_oled.lib
type gfx_set_steep_flag.prg gfx_transpose_points.prg gfx_clip_bounds.prg gfx_write_rect.prg >> gfx_oled.lib
type gfx_write_block.prg gfx_write_bitmap.prg gfx_adj_cursor.prg gfx_clear_bg.prg gfx_write_char.prg >> gfx_oled.lib
