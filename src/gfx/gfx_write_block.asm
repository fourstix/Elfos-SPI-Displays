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

            extrn   gfx_write_h_line
            extrn   gfx_write_v_line

;-------------------------------------------------------
; Private routine - called only by the public routines
; These routines may *not* validate or clip. They may 
; also consume register values passed to them.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: gfx_write_block
;
; Write pixels for a filled rectangle in the display 
; buffer at position x,y.
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
            proc    gfx_write_block

            PUSH    ra        ; save origin registers
            PUSH    rc        ; save counter register
            
            COPY    r7, ra    ; save origin
            LOAD    rc, 0     ; clear rc        
            
            glo     r8        ; get width
            plo     rc        ; put in counter
            inc     rc        ; +1 to always draw first pixel column, even if w = 0
            
            ghi     r8        ; get h for length
            plo     r9        ; set up length of vertical line
  
wb_loop:    CALL    gfx_write_v_line   ; draw vertical line at x
            inc     ra        ; increment x for next column
            dec     rc        ; decrement count after drawing line
            
            ghi     r8        ; get h for length
            plo     r9        ; set up length of vertical line
            
            COPY    ra, r7    ; put new origin for next line
            glo     rc        ; check counter
            lbnz    wb_loop   ; keep drawing columns until filled
            
            POP     ra        ; restore registers
            POP     rc
            RETURN 
            endp  
