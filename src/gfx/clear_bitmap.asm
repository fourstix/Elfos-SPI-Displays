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
            extrn   gfx_clip_bounds  
            extrn   gfx_write_bitmap

;-------------------------------------------------------
; Public routine - This routine validates the Origin
;   and clips the bitmap to the edges of the display
;-------------------------------------------------------

;-------------------------------------------------------
; Name: clear_bitmap
;
; Clear pixels in the display buffer to clear a bitmap 
; with its upper left corner at the position x,y and 
; sides of width w and height h.
;  
; Pixels corresponding to 1 values in the bitmap data 
; are cleared.  Pixels corresponding to 0 values in the 
; bitmap data are unchanged.
;
; Parameters: rf   - pointer to display buffer.
;             r7.1 - origin y 
;             r7.0 - origin x 
;             r8.1 - h 
;             r8.0 - w
;
; Note: Checks origin x,y values, error if out of bounds
; and the w, h values may be clipped to edge of display.
;                  
; Return: DF = 1 if error, 0 if no error
;-------------------------------------------------------
            proc    clear_bitmap
            CALL    gfx_check_bounds
            lbnf    cbmp_ok
            ABEND                     ; return with error code
            
cbmp_ok:    PUSH    rd
            PUSH    r9                ; save registers used
            PUSH    r8
            PUSH    r7
            
            CALL    gfx_clip_bounds   ; clip w and h, if needed

            ldi     GFX_CLEAR
            phi     r9                ; set up color            
                      
            CALL    gfx_write_bitmap  ; draw bitmap

            POP     r7                ; restore registers        
            POP     r8
            POP     r9
            POP     rd        

            CLC                       ; make sure DF = 0            
            RETURN
            endp
