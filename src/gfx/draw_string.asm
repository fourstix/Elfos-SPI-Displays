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

            extrn   draw_char  

;-------------------------------------------------------
; Public routine - This routine validates the origin
;   and the character string will wrap around the 
;   display boundaries.
;-------------------------------------------------------

;---------------------------------------------------------------------
; Name: draw_string
;
; Set pixels in the display buffer to define a string of 
; ASCII characters at position x,y.  The string will wrap 
; around the display if needed.  
;
; Parameters: rf   - pointer to display buffer.
;             r7.1 - y (0 to 56)
;             r7.0 - x (0 to 122)
;             r8   - pointer to null-terminated ASCII string
;             r9.1 - background (GFX_ BG_TRANSPARENT OR GFX_OPAQUE)
;
; Note: Checks x,y values, error if out of bounds. 
;       Checks ASCII character value, draws DEL (127) if out of bounds
;                  
; Return: DF = 1 if error, 0 if no error
;         r9, r8 are consumed
;---------------------------------------------------------------------
            proc    draw_string            
ds_loop:    lda     r8                  
            lbz     ds_done
            plo     r9        ; put character to draw
            
            CALL    draw_char ; r7 advances to next position  
            
            lbdf    ds_error  ; exit immediately on an error
            lbr     ds_loop   ; continue if no error  
            
ds_done:    CLC
            RETURN            ; return after string drawn
                        
ds_error:   ABEND             ; return error            
            endp
