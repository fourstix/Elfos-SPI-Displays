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
; Name: gfx_set_steep_flag
;
; Compare absolute values of the x difference and y 
; difference to determine if steeply slanted line. 
; 
; Parameters: r7   - origin x,y 
;             r8   - endpoint x,y
;             r9.1 - color
;             r9.0 - steep flag 
;
; Note: A steep line is a line with a larger change in y
; than the change in x.
;                  
; Return: r9.0 - 1 (true) if steep, 0 (false) if not
;-------------------------------------------------------
            proc   gfx_set_steep_flag
            PUSH   ra       ; save difference register
            glo    r7       ; get origin x value
            str    r2       ; store origin x in M(X)
            glo    r8       ; get endpoint x
            sm              ; subtract origin x in M(X) from endpoint x in D
            plo    ra       ; save x difference in ra.0            
            lbdf   diff_y   ; if positive, calculate y difference
            glo    ra       ; if negative x difference
            sdi    0        ; negate it
            plo    ra       ; put absolute x difference in ra.0
diff_y:     ghi    r7       ; get origin y value
            str    r2       ; store origin y in M(X)
            ghi    r8       ; get endpoint y
            sm              ; subtract origin y in M(X) from endpoint y in D
            phi    ra       ; save y difference in ra.1
            lbdf   st_calc  ; if positive, we can check for steepness
            ghi    ra       ; if negative y difference
            sdi    0        ; negate it
            phi    ra       ; put absolute y difference in ra.1
st_calc:    glo    ra       ; get xdiff
            str    r2       ; store in M(X)
            ghi    ra       ; get ydiff
            sm              ; ydiff in D - xdiff in M(X)
            lbdf   is_steep ; if ydiff > xdiff, steep line
            ldi    0        ; if ydiff < xdiff, not a steep line
            lbr    done
is_steep:   ldi    $01      ; steep line flag in D
done:       plo    r9       ; set steep flag in r9.0 for slanted line drawing                                    
            POP    ra
            RETURN
            endp
