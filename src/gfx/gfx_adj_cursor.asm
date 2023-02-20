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

            extrn   gfx_ascii_font  
            extrn   gfx_dislay_ptr  

;-------------------------------------------------------
; Private routine - called only by the public routines
; These routines may *not* validate or clip. They may 
; also consume register values passed to them.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: gfx_adj_cursor
;
; Adjust the cursor position x,y values to point to the
; next character location.  The cursor position will
; wrap to the next line or to the top of the screen if
; the cursor is at the bottom of the display.
;
; Parameters: rf   - pointer to display buffer.
;             r7.1 - cursor y  (0 to 56)
;             r7.0 - cursor x  (0 to 122)
;
; Return: r7 - updated for next cursor position
;-------------------------------------------------------
            proc    gfx_adj_cursor
            glo     r7          ; get the current x position 
            adi      6          ; each character is 6 pixels wide
            plo     r7          ; save updated x value
            sdi     122         ; check if past limit of columns
            lbdf    ac_done     ; if 122 - x >= 0, we are okay 
            ldi      0          ; set cursor to beginning of next line
            plo     r7          ; save new x location
            ghi     r7          ; get current y position
            adi      8          ; each character is 8 pixels tall
            phi     r7          ; save next y location
            sdi     56          ; check of past limit of rows
            lbdf    ac_done     ; if 56 - y >= 0, we are okay 
            ldi      0          ; set y to top row
            phi     r7          ; x,y now at home (0,0)
ac_done:    RETURN        
            endp
