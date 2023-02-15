;-------------------------------------------------------------------------------
; gfx_lib - a library for basic graphics functions useful 
; for a display connected to the 1802-Mini computer via 
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
#include    include/bios.inc
#include    include/kernel.inc
#include    include/macros.inc
#include    include/sysconfig.inc
#include    include/sh1106.inc

;-------------------------------------------------------
; Private Definitions
;-------------------------------------------------------

#define GFX_SET    $01
#define GFX_CLEAR  $00
#define GFX_INVERT $80

            extrn   gfx_check_bounds        
            extrn   gfx_clip_bounds        
            extrn   gfx_swap_points
            extrn   gfx_write_pixel
            extrn   gfx_write_line
            extrn   gfx_write_h_line
            extrn   gfx_write_v_line
            extrn   gfx_write_s_line
            extrn   gfx_set_steep_flag
            extrn   gfx_transpose_points
            extrn   gfx_write_rect
            extrn   gfx_write_block
            extrn   gfx_write_bitmap
            extrn   gfx_print_hex     
      

.link       .align  page

;-------------------------------------------------------
; Public routines - These routines validate or clip
;-------------------------------------------------------

;-------------------------------------------------------
; Name: clearBuffer
;
; Clear the entire display buffer.
;
; Parameters: rf - pointer to display buffer.
;
; Return: (None)
;-------------------------------------------------------
            proc    clearBuffer
            PUSH    rf                ; save buffer ptr
            PUSH    rc                ; save counter
            LOAD    rc, BUFFER_SIZE   ; set counter
             
cb_loop:    ldi     0
            str     rf
            inc     rf
            dec     rc
            LBRNZ   rc, cb_loop

            POP     rc
            POP     rf
            
            CLC               ; make sure DF = 0            
            RETURN

            endp

;-------------------------------------------------------
; Name: fillBuffer
;
; Fill the entire display buffer.
;
; Parameters: rf - pointer to display buffer.
;
; Return: (None)
;-------------------------------------------------------
            proc    fillBuffer
            PUSH    rf                ; save buffer ptr            
            PUSH    rc                ; save counter
            LOAD    rc, BUFFER_SIZE   ; set counter
             
fb_loop:    ldi     $FF
            str     rf
            inc     rf
            dec     rc
            LBRNZ   rc, fb_loop

            POP     rc
            POP     rf
            
            CLC               ; make sure DF = 0            
            RETURN

            endp

;-------------------------------------------------------
; Name: drawPixel
;
; Set a pixel in the display buffer at position x,y.
;
; Parameters: rf   - pointer to display buffer.
;             r7.1 - y (line, 0 to 63)
;             r7.0 - x (pixel offset, 0 to 127)
;
; Note: Checks x,y values, error if out of bounds
;                  
; Return: DF = 1 if error, 0 if no error
; 
;-------------------------------------------------------
            proc   drawPixel
            CALL   gfx_check_bounds
            lbnf   dp_ok
            ABEND           ; return with error code
            
dp_ok:      PUSH   r9       ; save temp register
            ldi    GFX_SET  ; set color 
            phi    r9
            ldi    0        ; clear out length
            plo    r9
            CALL   gfx_write_pixel  ; preserves r7 and rf

            POP    r9
            CLC               ; make sure DF = 0            
            RETURN
            
            endp

;-------------------------------------------------------
; Name: clearPixel
;
; Clear a pixel in the display buffer at position x,y.
;
; Parameters: rf   - pointer to display buffer.
;             r7.1 - y (line, 0 to 63)
;             r7.0 - x (pixel offset, 0 to 127)
;
; Note: Checks x,y values, error if out of bounds
;                  
; Return: DF = 1 if error, 0 if no error
; 
;-------------------------------------------------------
            proc   clearPixel
            CALL   gfx_check_bounds
            lbnf   cp_ok
            ABEND              ; return with error code
                        
cp_ok:      PUSH   r9
            ldi    GFX_CLEAR    ; set color
            phi    r9
            ldi    0            ; clear out length value
            plo    r9
            CALL   gfx_write_pixel  ; preserves r7 and rf
            POP    r9

            CLC                 ; make sure DF = 0            
            RETURN
 
            endp
            
;-------------------------------------------------------
; Name: drawLine
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
            proc    drawLine

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

;-------------------------------------------------------
; Name: clearLine
;
; Clear pixels in the display buffer to draw a line 
; from origin x0, y0 to endpoint x1, y1.
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
            proc    clearLine

            CALL    gfx_check_bounds
            lbnf    cl_chk
cl_err:     ABEND             ; return with error code
 
                         
cl_chk:     PUSH    r7        ; save origin value
            COPY    r8, r7    ; copy endpoint for bounds check
            CALL    gfx_check_bounds
            POP     r7        ; restore origin x,y
            lbdf    cl_err    ; if out of bounds return error

            PUSH    r9        ; save registers used in gfx_write_line
            PUSH    r8
            PUSH    r7
            
            ldi     GFX_CLEAR 
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

;-------------------------------------------------------
; Name: drawRect
;
; Set pixels in the display buffer to create a 
; rectangle with its upper left corner at position x,y
; and sides of width w and height h.
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
            proc    drawRect
            CALL    gfx_check_bounds
            lbnf    dr_ok
            ABEND             ; return with error code
            
dr_ok:      PUSH    r9        ; save registers used
            PUSH    r8
            PUSH    r7
            CALL    gfx_clip_bounds   ; clip w and h, if needed

            ldi     GFX_SET
            phi     r9        ; set up color            
            CALL    gfx_write_rect    ; draw rectangle
                    
            POP     r7        ; restore registers        
            POP     r8
            POP     r9
            CLC               ; make sure DF = 0            
            RETURN
            endp

;-------------------------------------------------------
; Name: clearRect
;
; Clear pixels in the display buffer to create a 
; rectangle with its upper right corner at position x,y
; and sides of width w and height h.
; 
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
            proc    clearRect
            CALL    gfx_check_bounds
            lbnf    cr_ok
            ABEND             ; return with error code
            
cr_ok:      PUSH    r9        ; save registers used
            PUSH    r8
            PUSH    r7
            CALL    gfx_clip_bounds   ; clip w and h, if needed

            ldi     GFX_CLEAR
            phi     r9        ; set up color                      
            CALL    gfx_write_rect
            
            POP     r7        ; restore registers        
            POP     r8
            POP     r9            
            CLC               ; make sure DF = 0            
            RETURN
            endp

;-------------------------------------------------------
; Name: drawBlock
;
; Set pixels in the display buffer to create a solid 
; filled rectangle with its upper left corner at the
; position x,y and sides of width w and height h.
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
            proc    drawBlock
            CALL    gfx_check_bounds
            lbnf    dr_ok
            ABEND                     ; return with error code
            
dr_ok:      PUSH    r9                ; save registers used
            PUSH    r8
            PUSH    r7
            CALL    gfx_clip_bounds   ; clip w and h, if needed

            ldi     GFX_SET
            phi     r9                ; set up color            
            CALL    gfx_write_block   ; draw block
                    
            POP     r7                ; restore registers        
            POP     r8
            POP     r9
            CLC                       ; make sure DF = 0            
            RETURN
            endp

;-------------------------------------------------------
; Name: clearBlock
;
; Clear pixels in the display buffer to create an empty 
; blank rectangle with its upper left corner at the
; position x,y and sides of width w and height h.
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
            proc    clearBlock
            CALL    gfx_check_bounds
            lbnf    dr_ok
            ABEND                     ; return with error code
            
dr_ok:      PUSH    r9                ; save registers used
            PUSH    r8
            PUSH    r7
            CALL    gfx_clip_bounds   ; clip w and h, if needed

            ldi     GFX_CLEAR
            phi     r9                ; set up color            
            CALL    gfx_write_block   ; draw block
                    
            POP     r7                ; restore registers        
            POP     r8
            POP     r9
            CLC                       ; make sure DF = 0            
            RETURN
            endp

;-------------------------------------------------------
; Name: drawBitmap
;
; Set pixels in the display buffer to draw a bitmap 
; with its upper left corner at the position x,y and 
; sides of width w and height h.
;  
; Pixels corresponding to 1 values in the bitmap data 
; are set.  Pixels corresponding to 0 values in the 
; bitmap data are  unchanged.
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
            proc    drawBitmap
            CALL    gfx_check_bounds
            lbnf    dbmp_ok
            ABEND                     ; return with error code
            
dbmp_ok:    PUSH    rd
            PUSH    r9                ; save registers used
            PUSH    r8
            PUSH    r7
            
            CALL    gfx_clip_bounds   ; clip w and h, if needed

            ldi     GFX_SET
            phi     r9                ; set up color            
            
            ;----- debugging
            ; PUSH    rd
            ; CALL    O_INMSG
            ;         db   'RD = ',0
            ; CALL    gfx_print_hex
            ; CALL    O_INMSG
            ;         db   'R7 = ',0
            ; COPY    r7, rd
            ; CALL    gfx_print_hex
            ; CALL    O_INMSG
            ;         db    'R8 = ',0
            ; COPY    r8, rd
            ; CALL    gfx_print_hex
            ; CALL    O_INMSG
            ;         db    'R9 = ',0
            ; COPY    r9, rd
            ; CALL    gfx_print_hex            
            ; POP     rd
            
            CALL    gfx_write_bitmap  ; draw bitmap

            POP     r7                ; restore registers        
            POP     r8
            POP     r9
            POP     rd        

            CLC                       ; make sure DF = 0            
            RETURN
            endp

;-------------------------------------------------------
; Name: clearBitmap
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
            proc    clearBitmap
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

;-------------------------------------------------------
; Private routines - called only by the public routines
; These routines may *not* validate or clip. They may 
; also consume register values passed to them.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: gfx_check_bounds
;
; Check to see if unsigned byte values for a point x,y 
; are outside of the display boundaries.
;
; Parameters: r7.1 - y (display line, 0 to 63)
;             r7.0 - x (pixel offset, 0 to 127)
;
; Note: Values x and y are unsigned byte values
;             
; Return: DF = 1 if error, ie x > 127 or y > 63 
;         DF = 0 if no error
;-------------------------------------------------------
            proc    gfx_check_bounds
            ghi     r7                ; check y value
            smi     DISP_HEIGHT       ; anything over 63 is an error
            lbdf    xy_err
            glo     r7                ; check x value
            smi     DISP_WIDTH        ; anything over 127 is an error
            lbdf    xy_err
            CLC                       ; clear df flag if okay
            lbr     xy_done          
xy_err:     STC                       ; set DF flag for error
xy_done:    RETURN
            endp

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
                        
;-------------------------------------------------------
; Name: gfx_write_pixel
;
; Set a pixel in the display buffer at position x,y.
;
; Parameters: rf   - pointer to display buffer.
;             r7.1 - y (line, 0 to 63)
;             r7.0 - x (pixel offset, 0 to 127)
;             r9.1 - color (GFX_SET, GFX_CLEAR, GFX_INVERT)
;                   
; Return: DF = 1 if error, 0 if no error
;-------------------------------------------------------
; Improvement: Use rd to set point (rd = rd + rf)
;-------------------------------------------------------
            proc    gfx_write_pixel
            PUSH    rd                ; save position register 
            PUSH    rc                ; save bit mask register
            LOAD    rd, 0             ; clear position
            ghi     r7                ; get line value (0 to $3f) 
            shr                       ; shift left (page = int y/8)
            shr                        
            shr                       
            phi     rd                ; put page into high byte (rd = page * 256)
            SHR16   rd                ; shift right, rd = page * DISP_WIDTH (128))
            glo     r7                ; get x (byte offset)
            str     r2                ; save in M(X)
            glo     rd                ; add x to page * DISP_WIDTH (128)
            add                       ; D = rd + x  
            plo     rd                ; DF has carry
            ghi     rd                ; add carry into rd.1
            adci    0
            phi     rd                ; rd now has the cursor position

            glo     rd                ; add rf to rd
            str     r2                ; put in M(X)
            glo     rf          
            add                       ; add rd.0 to rf.0 
            plo     rd                ; put back into rf.0, DF = carry
            ghi     rd
            str     r2                ; put in M(X)
            ghi     rf
            adc                       ; add rd.1 to rf.1 with carry
            phi     rd                ; rd now points to byte in buffer

            ldi     $01               ; bit mask for vertical pixie byte
            phi     rc                ; store bit mask in rc.1
            ghi     r7                ; vertical pixel bytes, so get y position for bitmask
            ani     $07               ; mask off 3 lower bits to get pixel position
            plo     rc                ; store in bit counter rc.0
            
shft_bit1:  lbz     set_bit
            ghi     rc
            shl                       ; shift mask one bit     
            phi     rc                ; save mask in rc.1
            dec     rc                ; count down
            glo     rc                ; check counter
            lbr     shft_bit1         ; repeat until count down to zero

set_bit:    ghi     rc                ; get mask from rc (LSB bit order)
            str     r2                ; store mask at M(x)
            ghi     r9                ; get color from temp register
            lbz     clr_bit           ; check for GFX_CLEAR value
            shl                       ; check for GFX_INVERT value
            lbdf    flip_bit    
            ldn     rd                ; get byte from buffer
            or                        ; OR mask to set bit
            str     rd                ; put updated byte back in buffer
            lbr     wp_done           
clr_bit:    ldi     $FF               ; invert bit mask so selected bit is zero
            xor                       ; Filp all mask bits ~(Bit Mask) 
            str     r2                ; put inverse mask in M(X)
            ldn     rd                ; get byte from buffer
            and                       ; AND inverse mask to clear bit
            str     rd                ; put updated byte back in buffer
            lbr     wp_done           
flip_bit:   ldn     rd                ; get byte from buffer
            xor                       ; XOR mask to invert bit
            str     rd                ; put updated byte back in buffer

wp_done:    POP     rc                ; restore bit register 
            POP     rd                ; restore position register
            CLC                       ; Set no error
            RETURN

            endp 


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

;-------------------------------------------------------
; Name: gfx_swap_points
;
; Exchange the values in r7 and r8 so that r7 has the 
; lower (left most or upper most) point.
;
; Parameters: r7   - origin x,y 
;             r8   - endpoint x,y 
;                  
; Return: r7 - initial r8 value (previous endpoint)
;         r8 - initial r7 value (previous origin)
;-------------------------------------------------------
            proc   gfx_swap_points
            glo    r7       ; swap x values
            str    r2       ; store origin x in M(X)
            glo    r8       ; get endpoint x
            plo    r7       ; put in origin x
            ldx             ; get origin from M(X)
            plo    r8       ; put in endpoint x
            ghi    r7       ; swap y values
            str    r2       ; store origin y in M(X)
            ghi    r8       ; get endpoint y
            phi    r7       ; put in origin y
            ldx             ; get origin y from M(X)
            phi    r8       ; put in endpoint y            
            
            RETURN
            endp

;-------------------------------------------------------
; Name: gfx_write_h_line
;
; Draw a horizontal line starting at position x,y.
; Uses logic instead of calling write pixel.
;
; Parameters: rf   - ptr to display buffer
;             r7.1 - origin y 
;             r7.0 - origin x 
;             r9.1 - color 
;             r9.0 - length  (0 to 127)   
;                  
; Return: (None) r7, r9 - consumed
;-------------------------------------------------------
            proc    gfx_write_h_line
            
            PUSH    rd                ; save position register 
            PUSH    rc                ; save bit mask register
            
            LOAD    rd, 0             ; clear position
            ghi     r7                ; get line value (0 to $3f) 
            shr                       ; shift left (page = int y/8)
            shr                        
            shr                       
            phi     rd                ; put page into high byte (rd = page * 256)
            SHR16   rd                ; shift right, rd = page * DISP_WIDTH (128))
            glo     r7                ; get x (byte offset)
            str     r2                ; save in M(X)
            glo     rd                ; add x to page * DISP_WIDTH (128)
            add                       ; D = rd + x  
            plo     rd                ; DF has carry
            ghi     rd                ; add carry into rd.1
            adci    0
            phi     rd                ; rd now has the cursor position

            glo     rd                ; add rf to rd
            str     r2                ; put in M(X)
            glo     rf          
            add                       ; add rd.0 to rf.0 
            plo     rd                ; put back into rf.0, DF = carry
            ghi     rd
            str     r2                ; put in M(X)
            ghi     rf
            adc                       ; add rd.1 to rf.1 with carry
            phi     rd                ; rd now points to byte in buffer

            ldi     $01               ; bit mask for vertical pixie byte
            phi     rc                ; store bit mask in rc.1
            ghi     r7                ; vertical pixel bytes, so get y position for bitmask
            ani     $07               ; mask off 3 lower bits to get pixel position
            plo     rc                ; store in bit counter rc.0
            
shft_ybit:  lbz     chk_color
            ghi     rc
            shl                       ; shift mask one bit     
            phi     rc                ; save mask in rc.1
            dec     rc                ; count down
            glo     rc                ; check counter
            lbr     shft_ybit         ; repeat until count down to zero

chk_color:  ghi     r9                ; get color from temp register
            lbnz    wfh_loop          ; check for GFX_SET or SET_INVERSE
            ghi     rc                ; get mask from rc (LSB bit order)
            str     r2                ; store GFX_CLEAR mask at M(x)
            ldi     $FF               ; invert bit mask so selected bit is zero
            xor                       ; Filp all mask bits ~(Bit Mask)             
            phi     rc                ; put inverted mask back for later

wfh_loop:   ghi     rc                ; get mask from rc (LSB bit order)
            str     r2                ; store mask at M(x) 
            ghi     r9                ; always do at least one pixel, so get color
            lbz     clr_ybit          ; check for GFX_CLEAR value
            shl                       ; check for GFX_INVERT value
            lbdf    flip_ybit                
                          
set_ybit:   ldn     rd                ; get byte from buffer
            or                        ; OR mask to set bit
            str     rd                ; put updated byte back in buffer
            lbr     wfh_chk           
clr_ybit:   ldn     rd                ; get byte from buffer
            and                       ; AND inverse mask to clear bit
            str     rd                ; put updated byte back in buffer
            lbr     wfh_chk           
flip_ybit:  ldn     rd                ; get byte from buffer
            xor                       ; XOR mask to invert bit
            str     rd                ; put updated byte back in buffer
  
wfh_chk:    glo     r9                ; check length count
            lbz     wh_done           ; if zero we are done
            inc     rd                ; move ptr to next byte
            dec     r9                ; draw length of w pixels
            lbr     wfh_loop            

wh_done:    POP     rc
            POP     rd
            RETURN

            endp

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
            ldi    0                ; put y value in r8.0
            phi    r8
            ghi    r7
            plo    r8               ; R8.0 has y value to increment
            CALL   gfx_write_pixel  ; always draw first pixel

wv_loop:    glo    r9               ; check length counter
            lbz    wv_done

            inc    r8               ; increment y value
            glo    r8               ; get new y value and put in r7.1
            phi    r7         
            dec    r9               ; decrement length counter
            CALL   gfx_write_pixel
            lbr    wv_loop
            
wv_done:    RETURN

            endp

;-------------------------------------------------------
; Name: gfx_set_steep_flag
;
; Compare absolute values of the x difference and y 
; difference to determine if steeply slanted line. 
; 
; Parameters: r7   - origin x,y 
;             r8   - endpoint x,y
;             r9.1 - color
;             r9.0 - steep flag 
;
; Note: A steep line is a line with a larger change in y
; than the change in x.
;                  
; Return: r9.0 - 1 (true) if steep, 0 (false) if not
;-------------------------------------------------------
            proc   gfx_set_steep_flag
            PUSH   ra       ; save difference register
            glo    r7       ; get origin x value
            str    r2       ; store origin x in M(X)
            glo    r8       ; get endpoint x
            sm              ; subtract origin x in M(X) from endpoint x in D
            plo    ra       ; save x difference in ra.0            
            lbdf   diff_y   ; if positive, calculate y difference
            glo    ra       ; if negative x difference
            sdi    0        ; negate it
            plo    ra       ; put absolute x difference in ra.0
diff_y:     ghi    r7       ; get origin y value
            str    r2       ; store origin y in M(X)
            ghi    r8       ; get endpoint y
            sm              ; subtract origin y in M(X) from endpoint y in D
            phi    ra       ; save y difference in ra.1
            lbdf   st_calc  ; if positive, we can check for steepness
            ghi    ra       ; if negative y difference
            sdi    0        ; negate it
            phi    ra       ; put absolute y difference in ra.1
st_calc:    glo    ra       ; get xdiff
            str    r2       ; store in M(X)
            ghi    ra       ; get ydiff
            sm              ; ydiff in D - xdiff in M(X)
            lbdf   is_steep ; if ydiff > xdiff, steep line
            ldi    0        ; if ydiff < xdiff, not a steep line
            lbr    done
is_steep:   ldi    $01      ; steep line flag in D
done:       plo    r9       ; set steep flag in r9.0 for slanted line drawing                                    
            POP    ra
            RETURN
            endp

;-------------------------------------------------------
; Name: gfx_transpose_points
;
; Exchange the x, y values in r7 and r8 so that their
; (x,y) values becomes (y,x) for each.

; Parameters: r7   - origin x,y 
;             r8   - endpoint x,y 
;                  
; Return: r7 - transposed r7 value (x,y) -> (y,x)
;         r8 - transposed r7 value (x,y) -> (y,x)
;-------------------------------------------------------
            proc   gfx_transpose_points
            glo    r7       ; transpose origin values
            str    r2       ; store origin x in M(X)
            ghi    r7       ; get origin y
            plo    r7       ; put in origin x
            ldx             ; get origin x from M(X)
            phi    r7       ; put in origin y
            glo    r8       ; transpose endpoint values
            str    r2       ; store endpoint x in M(X)
            ghi    r8       ; get endpoint y
            plo    r8       ; put in endpoint x
            ldx             ; get endpoint x from M(X)
            phi    r8       ; put in endpoint y
            
            RETURN
            endp

;-------------------------------------------------------
; Name: gfx_write_s_line
;
; Draw a sloping line starting at position x,y.
;
; Parameters: r7.1 - origin y 
;             r7.0 - origin x 
;             r8.1 - endpoint y 
;             r8.0 - endpoint x 
;             r9.1 - steep flag (transposed x,y values)
;
; Note: Uses Bresenham's algorithm to draw line.
; https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
;
; Since display co-ordinates each fit in one byte. This
; routine uses byte arithmetic to calculate pixel x,y values.
;                  
; Return: (None) r7, r8, r9 - consumed
;-------------------------------------------------------
            proc   gfx_write_s_line
            PUSH   ra       ; save x,y register 
            PUSH   rb       ; save dx, dy register
            PUSH   rc       ; save error, Ystep register       

;-------------------------------------------------------------------------------
;  The following values are used in Bresenham's algorithm 
;-------------------------------------------------------------------------------
;  ra.0  => calculated x
;  ra.1  => calculated y
;  rb.0  => dx  (x1 - x0), signed
;  rb.1  => dy  abs(y1 - y0)
;  rc.0  => error 
;  rc.1  => y_step (+1 or -1)
;  r9.1  => color
;  r9.0  => steep flag (calculate with transposed x,y)
;  r8.0  => endpoint x1, endpoint y1
;  r7    => pixel (x,y) to be drawn (either ra, or ra transposed for steep line)
;------------------------------------------------------------------------------- 
; This algorithm allows lines to be drawn using signed byte arithmetic. Some
; values were set up by the caller before this algorithm is called to 
; simplify calculations. 
;------------------------------------------------------------------------------- 
; A steep line is a line whose y difference is larger than its x difference.
; For a steep line, r7 and r8, are already transposed by the caller. If needed,
; r7 and r8 were swapped by the caller so that r7 is left of r8, making the 
; difference dx = x1 - x0 always positive.
;------------------------------------------------------------------------------- 
; The logic below sets up the remaining values used by algorithm.
;------------------------------------------------------------------------------- 

            COPY   r7, ra     ; copy origin to x,y
            glo    ra         ; dx = x1 - x0
            str    r2         ; x0 in M(X)
            glo    r8         ; get endpoint x1
            sm                ; dx = x1 in D minus x0 in M(X)
            plo    rb         ; save dx (always positive)              
            ghi    ra         ; dy = abs(y1 - y0)
            str    r2         ; y0 in M(X)
            ghi    r8         ; endpoint y1 in D  
            sm                ; dy = y1 in D minus y0 in M(X)
            phi    rb         ; save dy in rb
            lbdf   dy_pos     ; if positive no need to adjust
            ghi    rb         ; if dy is negative
            sdi    0          ; negate it
            phi    rb         ; save abs(dy) in rb
            ldi    $FF        ; set y step = -1 (signed byte value)
            phi    rc         ; save step in rc.1
            lbr    calc_err
dy_pos:     ldi    $01        ; set y step = +1
            phi    rc
calc_err:   glo    rb         ; get dx
            shr               ; divide by 2 (shift right)
            plo    rc         ; save as error value

;------------------------------------------------------------------------------- 
; Calculate and draw x,y values, for x = x0; x < x1; x++ Since we know the 
; endpoint is at pixel (x1,y1), we just draw it instead of calculating it.  
; For a steep line, the transposed x,y values must be transposed back to their 
; original positions to draw the pixel correctly on the display.
;------------------------------------------------------------------------------- 
           
sl_loop:    glo    r8         ; for x <= x1; x++    
            str    r2         ; store x1 in M(X)
            glo    ra         ; get x
            sm                ; x - x1, DF =0, until x >= x1
            lbdf   sl_done    ; if x1 >= x1, we are done
            
            glo    r9         ; check steep flag
            lbnz   sl_steep1  ; if steep, transpose x,y and draw
            COPY   ra, r7     ; copy current x,y to pixel x,y

            CALL   gfx_write_pixel
            lbr    sl_cont    ; continue    
sl_steep1:  glo    ra         ; transpose x and y for pixel
            phi    r7         ; put x in pixel y
            ghi    ra         ; put y in pixel x
            plo    r7         ; draw transposed pixel

            CALL   gfx_write_pixel 
            
sl_cont:    ghi    rb         ; get dy
            str    r2         ; save in M(X)
            glo    rc         ; get error
            sm                ; err = err - dy
            plo    rc         ;  save updated err
            lbdf   sl_adjx    ; if positive don't adjust y
            ghi    rc         ; get y step value (+1 or -1 signed byte)
            str    r2         ; save step in M(X)
            ghi    ra         ; get current y
            add               ; adjust y by step value (one step up or down) 
            phi    ra         ; save updated y
            glo    rb         ; get dx
            str    r2         ; save dx in M(X)
            glo    rc         ; get error value
            add               ; add dx to error value
            plo    rc         ; save updated error for next calculation
            
sl_adjx:    inc    ra         ; next x
            lbr    sl_loop    ; keep going while x < x1

;------------------------------------------------------------------------------- 
; Draw the endpoint to finish line 
;------------------------------------------------------------------------------ 
            
sl_done:    glo    r9         ; check steep flag
            lbnz   sl_steep2  ; if steep, transpose x,y and draw
            COPY   ra, r7     ; copy current x,y to pixel x,y
            lbr    sl_end     ; draw endpoint last
            
sl_steep2:  glo    r8         ; transpose x and y for pixel
            phi    r7         ; put x in pixel y
            ghi    r8         ; put y in pixel x
            plo    r7         ; draw transposed pixel 
                                 
sl_end:     CALL   gfx_write_pixel 

            POP    ra
            POP    rb
            POP    rc
            RETURN
            endp
            
;-------------------------------------------------------
; Name: gfx_write_rect
;
; Set pixels for a rectangle in the display buffer at 
; position x,y.
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
            proc    gfx_write_rect

            PUSH    rb        ; save origin registers
            PUSH    ra        ; save dimension register
            
            COPY    r7, ra    ; save origin 
            COPY    r8, rb    ; save dimensions
            
            glo     r8        ; get w for length
            plo     r9        ; set up length of horizontal line

            CALL    gfx_write_h_line   ; draw top line 
  
            COPY    ra, r7    ; restore origin
            COPY    rb, r8    ; restore w and h values
            ghi     r8        ; get h for length
            plo     r9        ; set up length of vertical line

            CALL    gfx_write_v_line   ; draw left line
            
            COPY    rb, r8    ; restore h and w values
            glo     ra        ; get origin x
            plo     r7        ; restore origin x
            ghi     ra        ; get origin y
            str     r2        ; put y0 in M(X)
            ghi     r8        ; get h
            add               ; D = y0 + h
            phi     r7        ; set new origin at lower left corner
            glo     r8        ; get w for length
            plo     r9        ; set length for horizontal line

            CALL    gfx_write_h_line   ; draw bottom line
            
            COPY    rb, r8    ; restore w and h values
            ghi     ra        ; get origin y
            phi     r7        ; restore origin y
            glo     ra        ; get origin x
            str     r2        ; put x0 in M(X)
            glo     r8        ; get w
            add               ; D = x0 + w
            plo     r7        ; set origin to upper right corner
            ghi     r8        ; get h for length
            plo     r9        ; set length for vertical line

            CALL    gfx_write_v_line   ; draw right line
            
            POP    ra         ; restore registers
            POP    rb
            RETURN 
            endp  

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
            
            ghi     r8        ; get h for height
            plo     rc        ; put in counter
            inc     rc        ; +1 to always draw first pixel row, even if h = 0
            
            glo     r8        ; get w for length
            plo     r9        ; set up length of horizontal line
  
wb_loop:    CALL    gfx_write_h_line   ; draw horizontal line at y
            ghi     ra        ; get y value
            adi     01        ; increment y for next row
            phi     ra        ; save as new origin
            dec     rc        ; decrement count after drawing line
            
            glo     r8        ; get w for length
            plo     r9        ; set up length of horizontal line
            
            COPY    ra, r7    ; put new origin for next line
            glo     rc        ; check counter
            lbnz    wb_loop   ; keep drawing columns until filled
            
            POP     ra        ; restore registers
            POP     rc
            RETURN 
            endp  


;-------------------------------------------------------
; Name: gfx_write_bitmap
;
; Write pixels for a filled rectangle in the display 
; buffer at position x,y.
;
; Parameters: rf   - pointer to display buffer.
;             rd   - pointer to bitmap
;             r7.1 - origin y  (upper left corner)
;             r7.0 - origin x  (upper left corner)
;             r8.1 - h 
;             r8.0 - w 
;             r9.1 - color
;
; Return: (None) r7, r8, r9 consumed
;-------------------------------------------------------
            proc    gfx_write_bitmap
            
            PUSH    ra        ; save bit register,  y value
            PUSH    rb        ; save j register, x origin
            PUSH    rc        ; save i register, x origin
            PUSH    rd        ; save bitmap pointer  
          
            ;-------------------------------------------------------
            ;     Registers used to draw bitmap
            ;     r8.1  -   h (height of bitmap)
            ;     r8.0  -   w (width of bitmap)
            ;     r9.1  -   color
            ;     r9.0  -   scratch register for (j * byte width)
            ;     ra.1  -   bitmap byte (b value for shifting)
            ;     ra.0  -   y value 
            ;     rc.0  -   inner iterator for x (i value)
            ;     rc.1  -   x origin value
            ;     rb.0  -   outer iterator for y (j value)  
            ;     rb.1  -   bitmap width in bytes
            ;-------------------------------------------------------
            
            ;----- set up registers 
            glo     r7        ; set up x origin value
            phi     rc
            ghi     r7        ; set up origin y value
            plo     ra        

            ;---- set up outer iterator j (count ddown )
            ghi     r8        ; get h value
            plo     rb        ; save as iterator j (count down)
            
            ;----- set up x iterator i and clear bitmap byte
            ldi     0         ; clear values
            plo     rc        ; set up inner x iterator i (count up)
            phi     ra        ; clear out bitmap byte for shifting
            
            ; calculate bitmap byte width
            glo     r8        ; get width of bitmap
            adi     07        ; add 7 to so byte width always >= 1
            shr               ; divide by 8 for int(w+7)
            shr               ; three shifts right => divde by 8  
            shr               ; D = byte width of byte map
            phi     rb        ; set byte width                        

            ;-------------------------------------------------------
            ; Algorithm from Adafruit:
            ;
            ; for (j=0; j<h; j++, y++) {
            ;   for (i=0; i<w; i++) {
            ;     if (i & 7) b <<= 1;
            ;     else b = read_byte(rd + i / 8]) 
            ;
            ;     if (b & 0x80)
            ;       writePixel(x + i, y, color);
            ;     } // for i
            ;   rd += byteWidth   // rd = rd + j * byteWidth
            ; } // for j
            ;-------------------------------------------------------

            ;----- outer loop for j iterations from 0 to h     
wbmp_jloop:                     ; redundant labels for readability            
            ;----- inner loop for i iterations from 0 to w
wbmp_iloop: glo     rc          ; get the i value
            ani     07          ; and i with 7
            lbz     wbmp_getb   ; if 0 or on byte boundary, get byte     
            ghi     ra          ; get byte value for shifting
            shl                 ; shift left to move next bit into MSB
            phi     ra          ; save shifted byte
            lbr     wbmp_chkb   ; check the byte
            
            ;----- read a new byte from the bitmap data
wbmp_getb:  PUSH    rd          ; save current byte row pointer
            glo     rc          ; get x iterator i
            shr                 ; convert x to byte offset
            shr                 ; 3 right shifts => divide by 8
            shr                 ; D = the byte offset int(i/8)
            str     r2          ; put byte offset in M(X)
            glo     rd          ; get byte row pointer
            add                 ; add offset to lower byte
            plo     rd          ; save byte ptr
            ghi     rd          ; adjust hi byte of pointer for carry
            adci    0           ; add DF into hi byte
            phi     rd          ; rd now points to rd + j*byteWidth + int(i/8)
            ldn     rd          ; get bitmap byte
            phi     ra          ; save bitmap byte for shifting
            POP     rd          ; restore byte pointer back to row
            
            ;----- check bit in bitmap and draw pixel if required
wbmp_chkb:  ghi     ra          ; get bitmap byte
            ani     $80         ; check MSB
            lbz     wbmp_iend   ; if MSB is zero we are done with this bit

            PUSH    r8          ; save h and w since r8 is consumed
            glo     ra          ; get current y value
            phi     r7          ; save as y value as pixel y
            ghi     rc          ; get x origin value
            str     r2          ; save x origin in M(X)
            glo     rc          ; get i offset
            add                 ; add offset to origin to get pixel x
            plo     r7          ; r7 now points to pixel to write
            
            ;----- debugging
            ; PUSH    rd
            ; CALL    O_INMSG
            ;         db   'R7 = ',0
            ; COPY    r7, rd
            ; CALL    gfx_print_hex
            ; POP     rd
            
            CALL    gfx_write_pixel
            POP     r8          ; restore h,w
            
            ;----- end of inner loop
wbmp_iend:  inc     rc          ; increment iterator i
            glo     rc          ; get iterator
            str     r2          ; save i in M(X)
            glo     r8          ; get w
            sm                  ; D = w - i
            lbnz    wbmp_iloop  ; keep going until i = w                 
            
            ;----- end of outer loop
wbmp_jend:  inc     ra          ; point y to next row
            ;----- debugging
            ; PUSH    rd
            ; CALL    O_INMSG
            ;         db   'RD = ',0
            ; CALL    gfx_print_hex
            ; CALL    O_INMSG
            ;         db   'RC = ',0
            ; COPY    rc, rd
            ; CALL    gfx_print_hex
            ; CALL    O_INMSG
            ;         db    'RB = ',0
            ; COPY    rb, rd
            ; CALL    gfx_print_hex
            ; CALL    O_INMSG
            ;         db    'RA = ',0
            ; COPY    ra, rd
            ; CALL    gfx_print_hex            
            ; CALL    O_INMSG
            ;         db    'R9 = ',0
            ; COPY    r9, rd
            ; CALL    gfx_print_hex            
            ; CALL    O_INMSG   
            ;         db 13,10,0  ; print blank line
            ; POP     rd

            ghi     rb          ; get byte width of bitmap pointer
            str     r2          ; save in M(X) for addition
            glo     rd          ; get bitmap pointer   
            add                 ; add byte width to bitmap pointer
            plo     rd          ; save in ptr
            ghi     rd          ; adjust hi byte for possible carry out
            adci    0           ; add DF to high byte
            phi     rd          ; rd now points to next line of bytes in bitmap
            
            ;----- reset iterator i and clear bitmap byte
            ldi     0         ; set up iterator values i and j
            plo     rc        ; set up inner x iterator (i)
            phi     ra        ; clear out bitmap byte for shifting

            dec     rb          ; count down from h 
            glo     rb          ; check j 
            lbnz    wbmp_jloop  ; keeping going until j = h
            
            POP     rd          ; restore registers
            POP     rc
            POP     rb
            POP     ra
            RETURN
            endp


;-------------------------------------------------------
; Debug routines
;-------------------------------------------------------          

;-------------------------------------------------------
; Name: gfx_print_hex
;
; Print a hex word.
;
; Parameters: rd - hex value to print
;
; Note:   rd is restored
;
; Return: None
;-------------------------------------------------------
            proc    gfx_print_hex
            PUSH    rd
            PUSH    rf                ; save buffer ptr
            LOAD    rf, hex_buf
            CALL    f_hexout4         ; convert rd to ascii hex
            
            LOAD    rf, hex_buf 
            CALL    O_MSG             ; print hex value
            
            CALL    O_INMSG           ; add newline 
            db      10,13,0
              
            POP     rf                ; restore buffer ptr
            POP     rd                ; restore hex value
            RETURN
hex_buf:    db 0,0,0,0,0
            endp
          
;-------------------------------------------------------
; Name: gfx_print_buffer
;
; Print the display buffer.
;
; Parameters: rf - pointer to 1K frame buffer.
;
; Return: rf - Consumed
;-------------------------------------------------------
            proc    gfx_print_buffer
            PUSH    ra                ; save byte counter
            PUSH    rb                ; save buffer ptr
            PUSH    rc                ; save line counter
            PUSH    rd                ; save register used by hexout2
            LOAD    rc, DISP_HEIGHT   ; set line counter
            COPY    rf, rb            ; move buffer pointer
prt_buff:   LOAD    rf, line_buf      ; point rf to line buffer
            inc     rf                ; skip over cr_lf
            inc     rf    
            LOAD    ra, 16            ; load byte counter
prt_line:   lda     rb                ; get byte from buffer
            plo     rd                ; put in rd for conversion
            CALL    f_hexout2         ; convert to two digit hex
            inc     rf                ; skip over space
            dec     ra
            LBRNZ   ra, prt_line      ; print entire line into buffer
            LOAD    rf, line_buf      ; point back to start of line buffer
            CALL    o_msg             ; output line of hex values
            dec     rc                ; decrement line counter
            LBRNZ   rc, prt_buff      ; keep printing all lines
            
            LOAD    rf, cr_lf         ; end block with line feed
            CALL    o_msg
            
            POP     rd                ; restore registers
            POP     rc
            POP     rb
            POP     ra
            RETURN

line_buf:   db 10,13,'XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX',0,0            
cr_lf:      db 10,13,0

            endp
