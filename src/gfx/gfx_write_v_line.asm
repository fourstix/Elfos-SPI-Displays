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
; Name: gfx_write_v_line
;
; Draw a vertical line starting at position x,y.
;
; Parameters: r7.1 - origin y 
;             r7.0 - origin x 
;             r9.1 - color 
;             r9.0 - length 
;                  
; Return: (None) r7, r8, r9 - consumed
;-------------------------------------------------------
            proc   gfx_write_v_line

            PUSH   ra               ; save scratch register
            PUSH   rb               ; save look up register
            PUSH   rc               ; save counter
            PUSH   rd               ; save buffer pointer

            ;-------------------------------------------------------
            ;  rd - points to byte in buffer
            ;  rc.1 - bit mask
            ;  rc.0 - counter
            ;  rb   - look up table ptr
            ;  r9.1 - color 
            ;  r9.0 - length (h)
            ;  r8.1 - mask byte
            ;  r8.0 - mod value
            ;  r7.1 - origin y
            ;  r7.0 - origin x
            ;-------------------------------------------------------
            
            glo    r9               ; check length counter
            lbz    fwv_done         ; if no length, no line to draw
            
            ;---- get ptr to byte in buffer
            CALL   gfx_display_ptr  ; rd now points to byte in buffer
            
            ;---- calculate bit offset = y0 & 7
            ghi    r7               
            ani     7               ; D = y & 7
            lbz    fwv_byte         ; if byte aligned, draw entire byte
            ;---- calculate mod value
            sdi     8               ; D = (8 - D) = 8 - (y&7)
            plo    r8               ; save mod in r8.0
            

            ;-------------------------------------------------------
            ; write bits in partial first byte
            ;-------------------------------------------------------            
                        
            LOAD   rb, premask      ; set lookup ptr to premask
            glo    r8               ; get mod value
            str    r2               ; save in M(X)
            glo    rb               ; get look up ptr
            add                     ; add mod offset to look up ptr
            plo    rb               ; put back in look up ptr
            ghi    rb               ; adjust hi byte of look up ptr        
            adci    0               ; add carry value to hi byte of look up ptr
            phi    rb               ; rb now points to premask value
            
            ldn    rb               ; get premask byte from look up table
            phi    r8               ; save in r8.1
            
            ;---- check if h is less than mod value
            glo    r8               ; get mod value
            str    r2               ; save at M(X)
            glo    r9               ; get h
            sm                      ; D = (h - m)
            lbdf   fwv_mask1        ; if DF = 1, (h - mod) >= 0, mask is okay
            
            ;---- adjust premask mask &= (0XFF >> (mod-h));
            sdi     0               ; negate difference, 0 - D = (mod - h)
            plo    rc               ; save shift counter
            ldi    $FF              ; set initial bit shift mask
            phi    rc               ; save bit shift mask in rc.1
fwv_shft1:  glo    rc               ; check counter
            lbz    fwv_mask1
            ghi    rc               ; shift bit mask 1 bit left
            shl    
            phi    rc
            dec    rc               ; count down
            lbr    fwv_shft1        ; keep going until shift mask done

            ghi    rc               ; get shifted bit mask
            str    r2               ; save in M(X)
            ghi    r8               ; get premask
            and                     ; clear out unused high bits
            phi    r8               ; save premask
fwv_mask1:  ghi    r9               ; check color
            lbz    clr_mask1        ; check for GFX_CLEAR  
            shl                     ; check for GFX_INVERSE
            lbdf   inv_mask1        ; DF =1, means GFX_INVERSE
            
            ghi    r8               ; get premask for GFX_SET
            str    r2               ; save premask in M(X) 
            ldn    rd               ; get first byte
            or                      ; or to set selected bits
            str    rd               ; put back in buffer
            lbr    fwv_draw         ; continue to draw rest of line
             
clr_mask1:  ghi    r8               ; get premask          
            xri    $FF              ; invert mask for AND
            str    r2               ; save premask in M(X)
            ldn    rd               ; get byte from buffer
            and                     ; and to clear out selected bits
            str    rd               ; put back in buffer
            lbr    fwv_draw         ; continue to draw rest of line
            
inv_mask1:  ghi    r8               ; get premask          
            str    r2               ; save premask in M(X)
            ldn    rd               ; get byte from buffer
            xor                     ; xor to invert selected bits
            str    rd               ; put back in buffer
                           
fwv_draw:   glo    r8               ; adjust h by mod value
            str    r2               ; save mod value in M(X)
            glo    r9               ; get h (length)
            sm                      ; D = (h - mod)
            lbnf   fwv_done         ; if h < mod, we're done!
            plo    r9               ; save updated h value

            ;-------------------------------------------------------
            ; write entire bytes at a time
            ;-------------------------------------------------------            

next_byte:  ADD16  rd, 128          ; advance buffer ptr to next line
fwv_byte:   glo    r9               ; get h
            smi     8               ; subtract 8
            lbnf   fwv_last         ; if h < 8, do last byte
            plo    r9               ; save h = h-8
            ghi    r9               ; check color
            lbz    clr_byte         ; check for GFX_CLEAR  
            shl                     ; check for GFX_INVERSE
            lbdf   inv_byte         ; DF =1, means GFX_INVERSE

            ldi    $FF              ; GFX_SET, so set all bits at once 
            str    rd               ; update byte in buffer
            lbr    next_byte        ; continue to next byte  

clr_byte:   ldi    0                ; clear all 8 bits                        
            str    rd
            lbr    next_byte        ; continue to next byte

inv_byte:   ldn    rd               ; get byte from buffer
            xri    $FF              ; flip all bits in byte
            str    rd               ; update byte in buffer
            lbr    next_byte        ; continue to next byte
            
fwv_last:   glo    r9               ; do the last partial byte
            lbz    fwv_done         ; h = 0, ends on byte boundary, we're done
            ani    7                ; h&7 is last mod value
            plo    r8               ; save mod value
            LOAD   rb, postmask     ; set rb to lookup table
            glo    r8               ; get mod value
            str    r2               ; save mod value in M(X)
            glo    rb               ; add mod value to lookup ptr
            add 
            plo    rb               
            ghi    rb               ; adjust hi byte of lookup ptr for carry
            adci   0
            phi    rb
            ldn    rb               ; get post mask value
            phi    r8               ; save postmask byte

            ;-------------------------------------------------------
            ; write the bits in the remaining last byte  
            ;-------------------------------------------------------            
            
            ghi    r9               ; check color
            lbz    clr_mask2        ; check for GFX_CLEAR  
            shl                     ; check for GFX_INVERSE
            lbdf   inv_mask2        ; DF =1, means GFX_INVERSE
            
            ghi    r8               ; get postmask for GFX_SET
            str    r2               ; save postmask in M(X) 
            ldn    rd               ; get last byte
            or                      ; or to set selected bits
            str    rd               ; put back in buffer
            lbr    fwv_done         ; finished drawing line
             
clr_mask2:  ghi    r8               ; get postmask          
            xri    $FF              ; invert mask for AND
            str    r2               ; save postmask in M(X)
            ldn    rd               ; get last byte from buffer
            and                     ; and to clear out selected bits
            str    rd               ; put back in buffer
            lbr    fwv_done         ; finished drawing line
            
inv_mask2:  ghi    r8               ; get postmask          
            str    r2               ; save postmask in M(X)
            ldn    rd               ; get last byte from buffer
            xor                     ; xor to invert selected bits
            str    rd               ; put back in buffer            
            
fwv_done:   POP    rd               ; restore registers
            POP    rc
            POP    rb
            POP    ra  
            RETURN

            ;---- look up tables for partial first and last bytes
premask:  db $00, $80, $C0, $E0, $F0, $F8, $FC, $FE 
postmask: db $00, $01, $03, $07, $0F, $1F, $3F, $7F 
            endp
