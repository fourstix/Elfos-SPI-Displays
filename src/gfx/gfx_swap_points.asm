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
; Name: gfx_swap_points
;
; Exchange the values in r7 and r8 so that r7 has the 
; lower (left most or upper most) point.
;
; Parameters: r7   - origin x,y 
;             r8   - endpoint x,y 
;                  
; Return: r7 - initial r8 value (previous endpoint)
;         r8 - initial r7 value (previous origin)
;-------------------------------------------------------
            proc   gfx_swap_points
            glo    r7       ; swap x values
            str    r2       ; store origin x in M(X)
            glo    r8       ; get endpoint x
            plo    r7       ; put in origin x
            ldx             ; get origin from M(X)
            plo    r8       ; put in endpoint x
            ghi    r7       ; swap y values
            str    r2       ; store origin y in M(X)
            ghi    r8       ; get endpoint y
            phi    r7       ; put in origin y
            ldx             ; get origin y from M(X)
            phi    r8       ; put in endpoint y            
            
            RETURN
            endp
