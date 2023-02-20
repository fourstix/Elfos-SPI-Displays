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

;-------------------------------------------------------
; Private routine - called only by the public routines
; These routines may *not* validate or clip. They may 
; also consume register values passed to them.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: gfx_transpose_points
;
; Exchange the x, y values in r7 and r8 so that their
; (x,y) values becomes (y,x) for each.

; Parameters: r7   - origin x,y 
;             r8   - endpoint x,y 
;                  
; Return: r7 - transposed r7 value (x,y) -> (y,x)
;         r8 - transposed r7 value (x,y) -> (y,x)
;-------------------------------------------------------
            proc   gfx_transpose_points
            glo    r7       ; transpose origin values
            str    r2       ; store origin x in M(X)
            ghi    r7       ; get origin y
            plo    r7       ; put in origin x
            ldx             ; get origin x from M(X)
            phi    r7       ; put in origin y
            glo    r8       ; transpose endpoint values
            str    r2       ; store endpoint x in M(X)
            ghi    r8       ; get endpoint y
            plo    r8       ; put in endpoint x
            ldx             ; get endpoint x from M(X)
            phi    r8       ; put in endpoint y
            
            RETURN
            endp
