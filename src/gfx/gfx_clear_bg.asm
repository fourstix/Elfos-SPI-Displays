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

            extrn   gfx_display_ptr  

;-------------------------------------------------------
; Private routine - called only by the public routines
; These routines may *not* validate or clip. They may 
; also consume register values passed to them.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: gfx_clear_bg
;
; Clear the background for a character to be drawn at  
; cursor position x,y.
;
; Parameters: rf   - pointer to display buffer.
;             r9.1 - size to clear  (1 to 128)
;             r7.1 - cursor y  (0 to 56)
;             r7.0 - cursor x  (0 to 122)
;
; Return: (None)
;-------------------------------------------------------
            proc    gfx_clear_bg
            PUSH    r8
            PUSH    rb
            PUSH    rc
            
            ;---- set up shift counter
            ghi     r7          ; get the shift value (y & 7)
            ani      7          ; shift value
            plo     rc          ; set rc.0 to shift value
            phi     rc          ; save copy of shift value for later
            
            ;---- set up scratch register
            LOAD    r8, $00FF   ; load shift mask in scratch register
            
bg_mask:    glo     rc          ; check shift value count
            lbz     bg_invert
            SHL16   r8          ; shift entire r8 register left
            dec     rc          ; count down shift counter
            lbr     bg_mask     ; keep going until done

bg_invert:  glo     r8          ; invert mask bytes
            xri     $FF         
            plo     r8      
            ghi     r8  
            xri     $FF
            phi     r8
            
            CALL    gfx_display_ptr ; point rd at character bytes
            ghi     rc              ; check shift value
            lbz     bg_setup        ; if byte aligned (0), don't draw hi bytes
            
            COPY    rd, rb          ; set hi byte ptr
            glo     rb              ; hi bytes are on the next line
            adi     128             ; next line is 128 bytes away
            plo     rb
            ghi     rb              ; add carry flag to high bytes
            adci     0
            phi     rb              ; rb now points to high bytes
            
bg_setup:   ghi     r9              ; get size to clear
            plo     rc              ; set up counter
  
            glo     r8              ; get lo mask
            str     r2              ; save lo mask in M(X)
            
bg_lo:      glo     rc
            lbz     bg_chk
            ldn     rd              ; get lo byte
            and                     ; clear mask bits
            str     rd              ; put byte back in display
            inc     rd
            dec     rc
            lbr     bg_lo           ; do all 6 collumns
            
bg_chk:     ghi     rc              ; check shift value
            lbz     bg_done         ; if byte aligned (0), we are done
            
            ghi     r9              ; set size for hi bytes
            plo     rc

            ghi     r8              ; get hi mask
            str     r2              ; save hi mask in M(X)
            
bg_hi:      glo     rc
            lbz     bg_done
            ldn     rb              ; get hi byte
            and                     ; clear mask bits
            str     rb
            inc     rb
            dec     rc
            lbr     bg_hi           ; do all 6 collumns
            
bg_done:    POP     rc
            POP     rb
            POP     r8
            RETURN
            endp
