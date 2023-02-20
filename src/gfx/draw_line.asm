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
            extrn   gfx_write_line

;-------------------------------------------------------
; Public routine - This routine validate inputs
;-------------------------------------------------------

;-------------------------------------------------------
; Name: draw_line
;
; Set pixels in the display buffer to draw a line from 
; the origin x0, y0 to endpoint x1, y1.
;
; Parameters: rf   - pointer to display buffer.
;             r7.1 - origin y 
;             r7.0 - origin x 
;             r8.1 - endpoint y 
;             r8.0 - endpoint x 
;
; Note: Checks x,y values, error if out of bounds
;                  
; Return: DF = 1 if error, 0 if no error
;-------------------------------------------------------
            proc    draw_line

            CALL    gfx_check_bounds
            lbnf    dl_chk
dl_err:     ABEND             ; return with error code
 
                         
dl_chk:     PUSH    r7        ; save origin value
            COPY    r8, r7    ; copy endpoint for bounds check
            CALL    gfx_check_bounds
            POP     r7        ; restore origin x,y
            lbdf    dl_err    ; if out of bounds return error

            PUSH    r9        ; save registers used in gfx_write_line
            PUSH    r8
            PUSH    r7
            
            ldi     GFX_SET 
            phi     r9        ; set color
            ldi     0         ; clear out length value
            plo     r9
            
            CALL    gfx_write_line
            POP     r7        ; restore registers
            POP     r8
            POP     r9
            CLC               ; make sure DF = 0                        
            RETURN
            
            endp
