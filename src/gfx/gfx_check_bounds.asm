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
; Name: gfx_check_bounds
;
; Check to see if unsigned byte values for a point x,y 
; are outside of the display boundaries.
;
; Parameters: r7.1 - y (display line, 0 to 63)
;             r7.0 - x (pixel offset, 0 to 127)
;
; Note: Values x and y are unsigned byte values
;             
; Return: DF = 1 if error, ie x > 127 or y > 63 
;         DF = 0 if no error
;-------------------------------------------------------
            proc    gfx_check_bounds
            ghi     r7                ; check y value
            smi     DISP_HEIGHT       ; anything over 63 is an error
            lbdf    xy_err
            glo     r7                ; check x value
            smi     DISP_WIDTH        ; anything over 127 is an error
            lbdf    xy_err
            CLC                       ; clear df flag if okay
            lbr     xy_done          
xy_err:     STC                       ; set DF flag for error
xy_done:    RETURN
            endp
