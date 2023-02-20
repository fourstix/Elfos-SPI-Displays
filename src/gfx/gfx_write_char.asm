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
            extrn   gfx_display_ptr  

;-------------------------------------------------------
; Private routine - called only by the public routines
; These routines may *not* validate or clip. They may 
; also consume register values passed to them.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: gfx_write_char
;
; Write pixels for a character in the display buffer 
; at position x,y.
;
; Parameters: rf   - pointer to display buffer.
;             r7.1 - cursor y  (0 to 56)
;             r7.0 - cursor x  (0 to 122)
;             r9.0 - char
;
; Return: (None) - r8, r9 consumed
;-------------------------------------------------------
            proc    gfx_write_char
            
            PUSH    ra        ; save lo mask pointer
            PUSH    rb        ; save hi mask pointer, cursor backup
            PUSH    rc        ; save counter
            PUSH    rd        ; save font and cursor pointer  
            
            ;---- set rd to base of font table
            LOAD    rd, gfx_ascii_font   
            
            ;---- set up counter
            ldi      5          ; each font is 5 bytes
            plo     rc          ; set up loop counter 
            ;---- set up offset
            glo     r9          ; get character
            smi     32          ; convert to offset (c-space)
            str     r2          ; save at M(X) for add

            ;---- add offset to base five times to point to font bytes
calc_font:  glo     rc          ; check counter
            lbz     set_masks   ; when done, rd points to character bytes in font table
            glo     rd          ; get lo byte of font ptr
            add                 ; add offset to rd
            plo     rd          ; save updated byte
            ghi     rd          ; get hi byte of font ptr
            adci     0          ; add carry flag into hi byte
            phi     rd          ; save updated byte 
            dec     rc          ; count down
            lbr     calc_font   ; do 5 times (rd = base + 5*offset)
                    
            ;---- set up font masks
set_masks:  ldi      5          ; 5 bytes in font table for character
            phi     rc          ; set up outer counter in rc.1
            LOAD    ra, lo_mask ; set up mask pointers
            LOAD    rb, hi_mask

shft_font:  ghi     rc          ; check outer counter
            lbz     masks_done  ; done, when all mask bytes are set

            ;---- set up inner counter
            ghi     r7          ; get the shift value (y & 7)
            ani      7          ; shift value
            plo     rc          ; set rc.0 to shift value
            ;---- set up scratch register
            ldi      0          ; clear out scratch register hi byte
            phi     r8          ; hi byte will have hi_mask after shifting
            lda     rd          ; get font byte
            plo     r8          ; put in lo byte of scratch register
            
            ;---- inner loop to shift font byte
shft_byte:  glo     rc          ; check shift value count
            lbz     shft_done
            SHL16   r8          ; shift entire r8 register left
            dec     rc          ; count down shift counter
            lbr     shft_byte   ; keep going until done

            
            ;---- inner loop done, store shifted byte as mask bytes            
shft_done:  glo     r8          ; lo byte is lo_mask for font byte
            str     ra          ; save lo_mask byte
            inc     ra          ; move to next lo mask byte
            ghi     r8          ; save hi_mask byte
            str     rb          ; save hi_mask byte
            inc     rb          ; move to next hi mask byte
                      
            ;---- outer loop
            ghi     rc          ; decrement outer loop counter
            smi      1          ; count down for each font byte
            phi     rc          ; save updated count
            lbr     shft_font   ; keep going until all 5 bytes shifted into masks
            
            ;---- calculate display ptr from cursor position
            ;---- and set up display pointers rd and r8

masks_done: CALL    gfx_display_ptr   ; rd now points to lo bytes in buffer
            LOAD    ra, lo_mask       ; set ra to lo_mask bytes

            ghi     r7                ; check to see if we need hi ptr
            ani      7                ; calculate shift value 
            lbz     skip_ptr          ; 0 means byte aligned, so don't draw hi bytes                           
            
            ;---- set up r8 to point to second line of bytes in character
            glo     rd                ; set r8 to point to hi bytes in buffer
            adi     128               ; hi bytes are in next line (128 bytes pre line)              
            plo     r8                ; set lo byte of next line                
            ghi     rd
            adci    0                 ; set hi byte
            phi     r8                ; r8 now points to next line for hi mask bytes
                
            LOAD    rb, hi_mask       ; set rb to hi mask bytes

skip_ptr:   ldi      5                ; font has 5 bytes, shifted into 2 masks
            plo     rc                ; set up mask counter
          
            ;---- put character into display using masks
put_char:   glo     rc                ; check counter to see if we're done
            lbz     char_done
            lda     ra                ; get lo mask
            str     r2                ; put in M(X)
            ldn     rd                ; get first display byte
            xor                       ; xor mask with current byte
            str     rd                ; save updated byte in display
            inc     rd                ; move to next byte
            
            ghi     r7                ; check to see if we need hi mask
            ani      7                ; calculate shift value
            lbz     skip_hi           ; 0 means byte aligned, so don't draw hi mask                           
            
            lda     rb                ; get hi mask 
            str     r2                ; put in M(X)
            ldn     r8                ; get second display byte
            xor                       ; xor mask with current byte
            str     r8                ; save updated byte in display
            inc     r8                ; move to next byte
skip_hi:    dec     rc                ; count down
            lbr     put_char          ; get going for all 5 mask pairs
            
char_done:  POP     rd                ; restore registers
            POP     rc
            POP     rb
            POP     ra
            RETURN
            
            ;---- mask bytes for font
lo_mask:    db 0,0,0,0,0    
hi_mask:    db 0,0,0,0,0        
            endp
