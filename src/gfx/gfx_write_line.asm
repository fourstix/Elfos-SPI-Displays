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

            extrn   gfx_swap_points  
            extrn   gfx_set_steep_flag  
            extrn   gfx_transpose_points  
            extrn   gfx_write_h_line
            extrn   gfx_write_v_line
            extrn   gfx_write_s_line

;-------------------------------------------------------
; Private routine - called only by the public routines
; These routines may *not* validate or clip. They may 
; also consume register values passed to them.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: gfx_write_line
;
; Write a line in the display buffer from position r7
; to position r8. 
;
; Parameters: r7.1 - origin y 
;             r7.0 - origin x 
;             r8.1 - endpoint y 
;             r8.0 - endpoint x 
;             r9.1 - color
;             r9.0 - length
;                  
; Return: r7, r8, r9 - consumed
;-------------------------------------------------------
            proc    gfx_write_line
            ghi     r7                 ; get origin y
            str     r2                 ; save at M(X)
            ghi     r8                 ; get endpoint y
            sd                         ; check for horizontal line 
            lbnz    wl_vchk            ; if not zero check for vertical line
            glo     r7                 ; get origin x
            str     r2                 ; save at M(X)
            glo     r8                 ; get endpoint x
            sm                         ; length = Endpoint - Origin
            plo     r9                 ; put in temp register
            lbdf    wl_horz            ; if positive, we're good to go
            glo     r9                 ; get negative length 
            sdi     0                  ; negate it (-D = 0 - D)
            plo     r9                 ; put length in temp register
            CALL    gfx_swap_points    ; make sure origin is left of endpoint

wl_horz:    CALL    gfx_write_h_line
            lbr     wl_done

wl_vchk:    glo     r7                 ; get origin x
            str     r2                 ; save at M(X)
            glo     r8                 ; get endpoint x
            sm
            lbnz    wl_slant
                        
            ghi     r7                 ; get origin y
            str     r2                 ; save at M(X)
            ghi     r8                 ; get endpoint y
            sm                         ; length = endpoint - origin
            plo     r9                 ; put in temp register
            lbdf    wl_vert            ; if positive, we're good 
            glo     r9                 ; get negative length
            sdi     0                  ; negate length 
            plo     r9                 ; put length in temp register
            CALL    gfx_swap_points    ; make sure origin is above endpoint
wl_vert:    CALL    gfx_write_v_line
            lbr     wl_done
                         
wl_slant:   CALL    gfx_set_steep_flag ; set r9.0 to steep flag for sloping line         

            glo     r9                    ; check steep flag
            lbz     wl_schk               ; if not steep, jump to check for swap
            CALL    gfx_transpose_points  ; for steep line, transpose x,y to y,x      

wl_schk:    glo     r7                    ; make sure origin x is left of endpoint x
            str     r2                    ; save origin x at M(X)
            glo     r8                    ; get endpoint x
            sm                             
            lbdf    wl_slope              ; if positive, the okay (x1 - x0 > 0)
            CALL    gfx_swap_points       ; swap so that origin is left of endpoint       
   
wl_slope:   CALL    gfx_write_s_line      ; draw a sloping line   
            CLC                           ; make sure DF = 0
wl_done:    RETURN
            endp
