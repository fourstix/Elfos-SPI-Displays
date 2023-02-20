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

            extrn   gfx_check_bounds  
            extrn   gfx_write_pixel      

;-------------------------------------------------------
; Public routine - This routine validate inputs
;-------------------------------------------------------

;-------------------------------------------------------
; Name: draw_pixel
;
; Set a pixel in the display buffer at position x,y.
;
; Parameters: rf   - pointer to display buffer.
;             r7.1 - y (line, 0 to 63)
;             r7.0 - x (pixel offset, 0 to 127)
;
; Note: Checks x,y values, error if out of bounds
;                  
; Return: DF = 1 if error, 0 if no error
; 
;-------------------------------------------------------
            proc   draw_pixel
            CALL   gfx_check_bounds
            lbnf   dp_ok
            ABEND           ; return with error code
            
dp_ok:      PUSH   r9       ; save temp register
            ldi    GFX_SET  ; set color 
            phi    r9
            ldi    0        ; clear out length
            plo    r9
            CALL   gfx_write_pixel  ; preserves r7 and rf

            POP    r9
            CLC               ; make sure DF = 0            
            RETURN
            
            endp
