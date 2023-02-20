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
; Name: gfx_clip_bounds
;
; Clip unsigned byte values h,w so that origin plus 
; h,w are inside the display boundaries.
;
; Parameters: r7.1 - y0 (0 to 63)
;             r7.0 - x0 (0 to 127)
;             r8.1 - h  
;             r8.0 - w
;
; Note: Values x and y are unsigned byte values
;             
; Return: r8.1 - adjusted so that y0 + h <= 63 
;         r8.0 - adjusted so that x0 + w <= 127
;-------------------------------------------------------
            proc    gfx_clip_bounds
            ghi     r8                ; check h first
            ani     $C0               ; h must be 0 to 63, $C0 = ~$3F
            lbnz    bad_h             ; if h >= 64, zero out
            ghi     r7  
            str     r2                ; put origin y value in M(X)
            ghi     r8                ; get height
            add                       ; D = y0 + h
            smi     DISP_HEIGHT       ; anything over 63 is too big
            lbnf    check_w           ; if y0 + h < 64, h is okay
            adi     $01               ; add one to adjust overage
            str     r2
            ghi     r8                ; get h
            sm                        ; subtract overage
            phi     r8                ; adjust h
            lbdf    check_w           ; should be positive or zero
bad_h:      ldi     0                 ; if not, zero out h
            phi     r8
            
check_w:    glo     r8                ; check w
            ani     $80               ; w must be 0 to 127, $80 = ~$7F
            lbnz    bad_w             ; if w >= 128, zero out 
            glo     r7                ; get origin x values
            str     r2                ; put origin y value in M(X)
            glo     r8                ; get width
            add                       ; D = x0 + w
            smi     DISP_WIDTH        ; anything over 127 is too big
            lbnf    clip_done         ; if x0 + w < 128, w is okay
            adi     $01               ; add one to adjust overage
            str     r2
            glo     r8                ; get w  
            sm                        ; subtract overage
            plo     r8
            lbdf    clip_done         ; w should be positve or zero         
bad_w:      ldi     0                 ; if not, zero out w  
            plo     r8                
            
clip_done:  CLC                       ; clear df (no error, when clipped)
            RETURN
            endp
