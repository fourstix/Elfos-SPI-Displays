;-------------------------------------------------------------------------------
; gfx_oled - a library for basic graphics functions useful 
; for an oled display connected to the 1802-Mini computer via 
; the SPI Expansion Board.  These routines operate on pixels
; in a buffer used by the display.
;
;
; Copyright 2023 by Gaston Williams
;
; Based on code from the Elf-Elfos-OLED library
; Written by Tony Hefner
; Copyright 2022 by Tony Hefner
;
; Based on code from Adafruit_SH110X library
; Written by Limor Fried/Ladyada for Adafruit Industries  
; Copyright 2012 by Adafruit Industries
;
; SPI Expansion Board for the 1802/Mini Computer hardware
; Copyright 2022 by Tony Hefner 
;-------------------------------------------------------------------------------
#include    ../include/bios.inc
#include    ../include/kernel.inc
#include    ../include/ops.inc
#include    ../include/sysconfig.inc
#include    ../include/sh1106.inc

#define GFX_SET    $01
#define GFX_CLEAR  $00
#define GFX_INVERT $80

            extrn   gfx_swap_points  
            extrn   gfx_set_steep_flag  
            extrn   gfx_transpose_points  
            extrn   gfx_write_h_line
            extrn   gfx_write_v_line
            extrn   gfx_write_s_line

;-------------------------------------------------------
; Private routine - called only by the public routines
; These routines may *not* validate or clip. They may 
; also consume register values passed to them.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: gfx_write_rect
;
; Set pixels for a rectangle in the display buffer at 
; position x,y.
;
; Parameters: rf   - pointer to display buffer.
;             r7.1 - origin y 
;             r7.0 - origin x 
;             r8.1 - h 
;             r8.0 - w 
;             r9.1 - color
;
; Return: (None) r7, r8, r9 consumed
;-------------------------------------------------------
            proc    gfx_write_rect

            PUSH    rb        ; save origin registers
            PUSH    ra        ; save dimension register
            
            COPY    r7, ra    ; save origin 
            COPY    r8, rb    ; save dimensions
            
            glo     r8        ; get w for length
            plo     r9        ; set up length of horizontal line

            CALL    gfx_write_h_line   ; draw top line 
  
            COPY    ra, r7    ; restore origin
            COPY    rb, r8    ; restore w and h values
            ghi     r8        ; get h for length
            plo     r9        ; set up length of vertical line

            CALL    gfx_write_v_line   ; draw left line
            
            COPY    rb, r8    ; restore h and w values
            glo     ra        ; get origin x
            plo     r7        ; restore origin x
            ghi     ra        ; get origin y
            str     r2        ; put y0 in M(X)
            ghi     r8        ; get h
            add               ; D = y0 + h
            phi     r7        ; set new origin at lower left corner
            glo     r8        ; get w for length
            plo     r9        ; set length for horizontal line

            CALL    gfx_write_h_line   ; draw bottom line
            
            COPY    rb, r8    ; restore w and h values
            ghi     ra        ; get origin y
            phi     r7        ; restore origin y
            glo     ra        ; get origin x
            str     r2        ; put x0 in M(X)
            glo     r8        ; get w
            add               ; D = x0 + w
            plo     r7        ; set origin to upper right corner
            ghi     r8        ; get h for length
            plo     r9        ; set length for vertical line

            CALL    gfx_write_v_line   ; draw right line
            
            POP    ra         ; restore registers
            POP    rb
            RETURN 
            endp  
