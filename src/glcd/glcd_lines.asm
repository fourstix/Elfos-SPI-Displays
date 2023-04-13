;-------------------------------------------------------------------------------
; glcd_lines - a demo program for displaying lines on an ST7920 
; GLCD display via the SPI Expansion Board for the 1802/Mini Computer. 
;
; Copyright 2023 by Gaston Williams
;
; Based on code from the Elf-Elfos-OLED library
; Written by Tony Hefner
; Copyright 2022 by Tony Hefner
;
; Based on code from Adafruit_GFX library
; Written by Limor Fried/Ladyada for Adafruit Industries  
; Copyright 2012-2023 by Adafruit Industries
;
; Based on code from the ST7920_GFX library
; Written by Borna Bira  
; Copyright 2018 by Borna Bira
;
; SPI Expansion Board for the 1802/Mini Computer hardware
; Copyright 2022 by Tony Hefner 
;-------------------------------------------------------------------------------
#include    include/bios.inc
#include    include/kernel.inc
#include    include/ops.inc
#include    include/sysconfig.inc
#include    include/st7920.inc

; ************************************************************
; This block generates the Execution header
; It occurs 6 bytes before the program start.
; ************************************************************

        org     02000h-6        ; Header starts at 01ffah
            dw      2000h
            dw      endrom-2000h
            dw      2000h

              org   2000h
start:      br    main


; Build information
; Build date
date:       db      80h+4          ; Month, 80h offset means extended info
            db      12             ; Day
            dw      2023           ; year

; Current build number
build:      dw      1             ; build
            db    'Copyright 2023 by Gaston Williams',0


; Main code starts here, check provided argument

main:       lda   ra                    ; move past any spaces
            smi   ' '
            lbz   main
            dec   ra                    ; move back to non-space character
            ldn   ra                    ; get byte
            lbz   good                  ; jump if no argument given
            call  o_inmsg               ; otherwise display usage message
            db    'Usage: glcd_lines',10,13,0
            ldi   $0a
            RETURN                      ; and return to os

good:       ;---- initialize the display, draw the pattern, show pattern
            CALL  st7920_init               
            LOAD  rf, disp_buff         ; update the display
            CALL  clear_buff            ; clear the buffer
            LOAD  rf, disp_buff         ; update the display
            CALL  draw_lines            ; draw line demo
            LOAD  rf, disp_buff         ; update the display
            CALL  st7920_display          
            CLC                         ; clear df = 0
            RETURN

;-------------------------------------------------------------------------------
; Name: st7920_init
;
; Initializes the GLCD display using the ST7920 controller chip connected
; to port 0 of the 1802/Mini SPI interface. 
;
; The bits of the SPI control port are as follows:
; Bit 7 - If set to 0, the low 6-bits of the control port are set.
;         If set to 1, the low 6-bits of the DMA count are set.
; Bit 6 - Setting this bit to 1 starts a DMA out operation.
; Bit 5 - Setting this bit to 1 starts a DMA in operation (not used here).
; Bit 4 - The MSB of the DMA count when the count is written.
; Bit 3 - CS1 - used by the micro-SD card.
; Bit 2 - CS0 - Chip Select for the ST7920 PSB line, PSB=0, Serial on
; Bit 1 - Active low reset for the GLCD display.
; Bit 0 - D/C line for Register Select line, RS = 1, Display On.
;
; Parameters: None
;
; Return: None
;-------------------------------------------------------------------------------
st7920_init:  PUSH    rd
              PUSH    rc

              sex     r3                ; set x for inline data
                                        
            #if SPI_GROUP
              out     EXP_PORT          ; set group for SPI card
              db      SPI_GROUP
            #endif

              out     SPI_CTL           ; clear SPI card  
              db      IDLE

              ldi     83                ; delay 1 ms
              plo     rc
delay1:       dec     rc
              glo     rc
              lbnz    delay1
;-------------------------------------------------------------------------------            
;   Reset for the st7920
;-------------------------------------------------------------------------------

              out     SPI_CTL           ; Drop reset line
              db      RESET

              mov     rc, 830           ; hold reset low for 10 ms
delay2:       dec     rc
              LBRNZ   rc, delay2

              out     SPI_CTL           ; raise reset line
              db      IDLE

              mov     rc, 4150          ; wait 50 ms for reset to complete
delay3:       dec     rc
              LBRNZ   rc, delay3

              out     SPI_CTL
              db      DATA              ; Set PSB (CS1) Low, turn on RS (DATA) 

              ldi     83                ; wait 1 ms
              plo     rc
delay4:       dec     rc
              glo     rc
              lbnz    delay4

              sex     r2                ; set x back to stack
              ldi     SET_DISP_INIT     ; initialize display
              plo     rd                ; save command in rd.0
              STC                       ; DF = 1 to send as a command
              CALL    st7920_send       ; send command to display
              
              sex     r3                ; set x for inline data

              out     SPI_CTL           ; clear CD and data line
              db      IDLE

            #if SPI_GROUP
              out     EXP_PORT
              db      NO_GROUP
            #endif

              sex     r2                ; set x for stack

              POP     rc
              POP     rd
              RETURN

;-------------------------------------------------------------------------------
; Name: st7920_send
;
; Send data or a command to the GLCD display using the ST7920 controller chip
; connected to port 0 of the 1802/Mini SPI interface. 
;
; The bits of the SPI control port are as follows:
; Bit 7 - If set to 0, the low 6-bits of the control port are set.
;         If set to 1, the low 6-bits of the DMA count are set.
; Bit 6 - Setting this bit to 1 starts a DMA out operation.
; Bit 5 - Setting this bit to 1 starts a DMA in operation (not used here).
; Bit 4 - The MSB of the DMA count when the count is written.
; Bit 3 - CS1 - used by the micro-SD card.
; Bit 2 - CS0 - Chip Select for the ST7920 PSB line, PSB=0, Serial on
; Bit 1 - Active low reset for the GLCD display.
; Bit 0 - D/C line for Register Select line, RS = 1, Display On.
;
; Parameters: RD.0 - byte to send to display
;             DF = 1, send byte as a command
;             DF = 0, send byte as a data
;
; Return: None
;-------------------------------------------------------------------------------
st7920_send:  PUSH    rc
              
              lbnf    s_data            ; DF used for command or data byte
              ldi     SET_CMD_MODE      ; DF=1 means send byte as command
              plo     re                ; save command marker in scratch register
              lbr     s_byte            ; send the byte
                
s_data:       ldi     SET_DATA_MODE     ; DF=0, means send byte as data             
              plo     re                ; save data marker in scratch register

s_byte:       glo     rd                ; get low nibble of byte to send
              shl                       ; move low nibble to upper 4 bits
              shl                       ; and fill with zeros
              shl 
              shl
              stxd                      ; put low nibble on stack

              glo     rd                ; get high nibble of byte to send
              ani     $F0               ; mask high nibble
              stxd                      ; save high byte on stack 
              
              glo     re                ; get type marker byte
              str     r2                ; save at M(x)
              
              out     SPI_DATA          ; send marker byte
              out     SPI_DATA          ; Send high nibble of command
              out     SPI_DATA          ; Send low nibble of command
              dec     r2                ; put stack pointer back to M(X)    
              
              ldi     83                ; delay 1 ms after sending byte
              plo     rc
s_delay:      dec     rc
              glo     rc
              lbnz    s_delay

              POP     rc
              RETURN
  
;-------------------------------------------------------------------------------
; Name: st7920_display
;
; Copy a complete image from frame buffer to display using the st7920 
; controller chip connected; to port 0 of the 1802/Mini SPI interface. 
;
; The bits of the SPI control port are as follows:
; Bit 7 - If set to 0, the low 6-bits of the control port are set.
;         If set to 1, the low 6-bits of the DMA count are set.
; Bit 6 - Setting this bit to 1 starts a DMA out operation.
; Bit 5 - Setting this bit to 1 starts a DMA in operation (not used here).
; Bit 4 - The MSB of the DMA count when the count is written.
; Bit 3 - CS1 - used by the micro-SD card.
; Bit 2 - CS0 - Chip Select for the ST7920 PSB line, PSB=0, Serial on
; Bit 1 - Active low reset for the GLCD display.
; Bit 0 - D/C line for Register Select line, RS = 1, Display On.
;
; Parameters: rf - pointer to 1K frame buffer.
;
; Return: None, rf is consumed
;-------------------------------------------------------------------------------
st7920_display:
            PUSH    rd              ; save reg used for byte to send
            PUSH    rc              ; save reg used as line byte count
            PUSH    r8              ; save reg used as line count
            sex     r3

          #if SPI_GROUP
            out     EXP_PORT
            db      SPI_GROUP
          #endif

            ; --- set display for serial communication
            out     SPI_CTL
            db      DATA            ; Set PSB Low, turn on RS 
            
            ldi     83                  ; wait 1 ms
            plo     rc
d_delay:    dec     rc
            glo     rc
            lbnz    d_delay

            sex     r2              ; set x back to stack

            ; --- send commands to put in graphics mode
            ldi     SET_EXT_CMD     ; set extended command mode
            plo     rd              ; save in rd.0
            STC                     ; DF=1 to send as a command
            CALL    st7920_send     ; send byte to display

            ldi     SET_GFX_MODE    ; graphics mode extended command
            plo     rd              ; save in rd.0
            STC                     ; DF=1 to send as a command
            CALL    st7920_send     ; send byte to display

            mov     r8, 0           ; set up buffer line counter

showrow:    glo     r8              ; get the line counter for y position
            ori     SET_POSITION    ; OR with $80 for y position command
            plo     rd              ; put y position command in rd.0      
            STC                     ; DF=1 to send as command
            CALL    st7920_send     ; send byte to display 

            ldi     SET_POSITION    ; put $80 for x = 0
            plo     rd              ; put x position command in rd.0
            STC                     ; DF=1 to send as command
            CALL    st7920_send     ; send byte to display 

            ldi     16
            plo     rc              ; send two lines of data (16 bytes each)

d_loop:     lda     rf              ; get first display byte
            plo     rd              ; set byte to send to zero
            CLC                     ; DF=0 to send byte as data
            CALL    st7920_send     ; send byte to display 

            lda     rf              ; get second display byte
            plo     rd              ; set byte to send to zero
            CLC                     ; DF=0 to send byte as data
            CALL    st7920_send     ; send byte to display 
                      
            dec     rc              ; count down 
            glo     rc              ; check line byte counter
            lbnz    d_loop          ; keep sending all 16 bytes for two lines

            inc     r8              ; count up
            glo     r8              ; get the line count
            smi     32              ; check to see if we have sent all 32 rows

            lbnf    showrow         ; if negative (DF = 0) fill next row

            sex     r3              ; set x for next page commands or exit

            out     SPI_CTL         ; end spi and prepare to exit
            db      IDLE

          #if SPI_GROUP
            out     EXP_PORT
            db      NO_GROUP
          #endif

            sex     r2          ; set x back to stack

            POP     r8          ; restore reg used as line count
            POP     rc          ; restore reg used as line byte count
            POP     rd          ; restore reg used for byte to send
            RETURN

;-------------------------------------------------------
; Name: clear_buff
;
; Clear all pixels in the display buffer.
;
; Parameters: rf - pointer to 1K frame buffer.
;-------------------------------------------------------
            ; Clear the display buffer by loading zeros
clear_buff: PUSH    rd                ; save index register
            PUSH    rc                ; save counter register
            COPY    rf, rd            ; copy buffer pointer to index
            LOAD    rc, BUFFER_SIZE
            
clr_buff:   ldi     0
            str     rd
            inc     rd
            dec     rc
            LBRNZ   rc, clr_buff

            POP     rc                ; restore counter register
            POP     rd                ; restore index register
            RETURN 

;-------------------------------------------------------
; Name: set_pixel
;
; Set a pixel in the display buffer at position x,y.
;
; Parameters: rf   - pointer to display buffer.
;             r7.1 - y (line, 0 to 63)
;             r7.0 - x (pixel offset, 0 to 127)
;
; Note: Checks x,y values, does nothing if out of bounds
;-------------------------------------------------------

;-------------------------------------------------------------------------------            
; Original algorithm to set pixel in Arduino C code:
;            
; if(x<0 || x>=ST7920_WIDTH || y<0 || y>=ST7920_HEIGHT) return;
;  uint8_t y0 = 0, x0 = 0;   
;  uint8_t data;
;  uint16_t n;   //variable to send buffer data (one line of page)
;
;  if (y > 31) {  //If Y coordinate > than 31, skip into upper row, by adding 16
;    y -= 32;
;    y0 = 16;
;  }
;
;  x0 = x % 8;		
;  x /= 8;
;  data = 0x80 >> x0;
;  
;  n = (x) + (y0) + (32 * y);
;  buff[n] |= data;
;  return;
;-------------------------------------------------------------------------------

set_pixel:  ghi     r7                ; check y value
            smi     DISP_HEIGHT       ; anything over 63 is an error
            lbdf    xy_ignore         ; exit routine without doing anything
            glo     r7                ; check x value
            smi     DISP_WIDTH        ; anything over 127 is an error
            lbdf    xy_ignore         ; exit routine without doing anything
            
            PUSH    rd                ; save position register 
            PUSH    rc                ; save bit mask register

            
            ;------ calculate bit mask for pixel bit in display byte
            ldi     $80               ; bit mask for horizontal pixel
            phi     rc                ; store initial bit mask in rc.1
            glo     r7                ; horizontal pixel bytes, so get x position for bitmask
            ani     $07               ; mask off 3 lower bits to get pixel position
            plo     rc                ; store in bit counter rc.0
 
shft_bit1:  lbz     set_index
            ghi     rc
            shr                       ; shift mask one bit     
            phi     rc                ; save mask in rc.1
            dec     rc                ; count down
            glo     rc                ; check counter
            lbr     shft_bit1         ; repeat until count down to zero

            ;-------------------------------------------------------            
            ; Calculate index n for byte to update in buffer            
            ; using formula n = int(x/8) + (offset) + (32 * y);
            ;-------------------------------------------------------            
            ; Note: rc.0 = 0, after bit mask loop above
            ; If y in upper half of display, adjust y to y-32
            ; and set rc.0 as flag to add offset of 16 to byte index
            ; then calculate int(x/8) and add to index
            ;-------------------------------------------------------                        
set_index:  ldi     0                 ; clear out some register bytes
            plo     rc                ; clear out offset flag (redundant)
            phi     rd                ; clear out index register
            ghi     r7                ; check y value
            plo     rd                ; save y in index register
            smi     32                ; if y >= 32, adjust y
            lbnf    calc_index        ; if negative, y < 32
            plo     rd                ; save (y-32) as new value in index register
            ldi     $FF               ; need offset for upper half of display
            plo     rc                ; so set upper offset flag in rc.0

calc_index: glo     rd                ; shift y value in rd 5 times to multiply by 32
            shl                       ; max value is 5 bits, so rd.0 shift 3 times
            shl                       ; without worrying about carry bit, then
            shl                       ; shift whole register for 4 and 5
            plo     rd                ; rd = y * 8
            SHL16   rd                ; rd = y * 16
            SHL16   rd                ; rd = y * 32

            glo     rc                ; check offset flag
            lbz     no_offset
            ADD16   rd, 16            ; add in offset (rd = y*32 + 16)
    
no_offset:  glo     r7                ; get x value
            shr                       ; shift 3 times to divide by 8
            shr     
            shr                       ; D = int (x/8)
            str     r2                ; save value in M(X)
            glo     rd                ; add int(x/8) to index register
            add                       ; D = index low byte
            plo     rd                ; save low byte value in index
            ghi     rd                ; get index hi byte to update
            adci     0                ; add carry value into hi byte
            phi     rd                ; save sum in index register
             
            ;----- add display buffer address register 
            ADD16   rd, rf            ; add display buffer address (rd=rd+rf) 

            ;----- index register now points to byte in display buffer to update
            ghi     rc                ; get bit mask from rc
            str     r2                ; save bit mask in M(X)
            ldn     rd                ; get byte from display buffer
            or                        ; OR mask with byte to set bit
            str     rd                ; save updated byte in buffer

            POP     rc                ; restore bit mask register  
            POP     rd                ; restore display index register
xy_ignore:  RETURN

;-------------------------------------------------------
; Name: swap_points
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
swap_points:
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
            
;-------------------------------------------------------
; Name: transpose_points
;
; Exchange the x, y values in r7 and r8 so that their
; (x,y) values becomes (y,x) for each.

; Parameters: r7   - origin x,y 
;             r8   - endpoint x,y 
;                  
; Return: r7 - transposed r7 value (x,y) -> (y,x)
;         r8 - transposed r7 value (x,y) -> (y,x)
;-------------------------------------------------------
transpose_points:
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

;-------------------------------------------------------
; Name: write_h_line
;
; Draw a horizontal line starting at position x,y.
; Calls set pixel to draw line (not optimized).
;
; Parameters: rf   - ptr to display buffer
;             r7.1 - origin y 
;             r7.0 - origin x 
;             r9.0 - length w (0 to 127)   
;                  
; Return: (None) r7, r9 - consumed
;-------------------------------------------------------
write_h_line:
            CALL    set_pixel
            glo     r9              ; check length count
            lbz     whl_done        ; if zero we are done
            glo     r7              ; increment x  
            adi      1          
            plo     r7
            dec     r9              ; draw length of w pixels
            lbr     write_h_line            

whl_done:   RETURN

;-------------------------------------------------------
; Name: write_v_line
;
; Draw a vertical line starting at position x,y.
; Calls set pixel to draw line (not optimized).
;
; Parameters: rf   - ptr to display buffer
;             r7.1 - origin y 
;             r7.0 - origin x 
;             r9.0 - length h (0 to 63)   
;                  
; Return: (None) r7, r9 - consumed
;-------------------------------------------------------
write_v_line:
            CALL    set_pixel
            glo     r9              ; check length count
            lbz     wvl_done        ; if zero we are done
            ghi     r7              ; increment y  
            adi      1          
            phi     r7
            dec     r9              ; draw length of h pixels
            lbr     write_v_line            

wvl_done:   RETURN

;-------------------------------------------------------
; Name: set_steep_flag
;
; Compare absolute values of the x difference and y 
; difference to determine if steeply slanted line. 
; 
; Parameters: r7.1 - origin y 
;             r7.0 - origin x 
;             r8.1 - endpoint y 
;             r8.0 - endpoint x 
;             r9.0 - steep flag 
;
; Note: A steep line is a line with a larger change in y
; than the change in x.
;                  
; Return: r9.0 = 1 (true) if steep, 0 (false) if not
;-------------------------------------------------------
set_steep_flag:
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

;-------------------------------------------------------
; Name: write_s_line
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
write_s_line:
            PUSH   ra       ; save calculated x,y register 
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

            CALL   set_pixel
            lbr    sl_cont    ; continue    
sl_steep1:  glo    ra         ; transpose x and y for pixel
            phi    r7         ; put x in pixel y
            ghi    ra         ; put y in pixel x
            plo    r7         ; draw transposed pixel

            CALL   set_pixel 
            
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
                                 
sl_end:     CALL   set_pixel 

            POP    ra
            POP    rb
            POP    rc
            RETURN

;-------------------------------------------------------
; Name: write_line
;
; Write a line in the display buffer from position r7
; to position r8. 
;
; Parameters: r7.1 - origin y 
;             r7.0 - origin x 
;             r8.1 - endpoint y 
;             r8.0 - endpoint x 
;             rf   - ptr to display buffer                  
; Return: r7, r8 - consumed
;-------------------------------------------------------
write_line: PUSH    r9                ; save temp register for length or flag
            ghi     r7                ; get origin y
            str     r2                ; save at M(X)
            ghi     r8                ; get endpoint y
            sd                        ; check for horizontal line 
            lbnz    wl_vchk           ; if not zero check for vertical line
            glo     r7                ; get origin x
            str     r2                ; save at M(X)
            glo     r8                ; get endpoint x
            sm                        ; length = Endpoint - Origin
            plo     r9                ; put in temp register
            lbdf    wl_horz           ; if positive, we're good to go
            glo     r9                ; get negative length 
            sdi     0                 ; negate it (-D = 0 - D)
            plo     r9                ; put length in temp register
            CALL    swap_points       ; make sure origin is left of endpoint

wl_horz:    CALL    write_h_line
            lbr     wl_done

wl_vchk:    glo     r7                ; get origin x
            str     r2                ; save at M(X)
            glo     r8                ; get endpoint x
            sm
            lbnz    wl_slant
                        
            ghi     r7                ; get origin y
            str     r2                ; save at M(X)
            ghi     r8                ; get endpoint y
            sm                        ; length = endpoint - origin
            plo     r9                ; put in temp register
            lbdf    wl_vert           ; if positive, we're good 
            glo     r9                ; get negative length
            sdi     0                 ; negate length 
            plo     r9                ; put length in temp register
            CALL    swap_points       ; make sure origin is above endpoint
wl_vert:    CALL    write_v_line
            lbr     wl_done
                         
wl_slant:   CALL    set_steep_flag    ; set r9.0 to steep flag for sloping line         

            glo     r9                ; check steep flag
            lbz     wl_schk           ; if not steep, jump to check for swap
            CALL    transpose_points  ; for steep line, transpose x,y to y,x      

wl_schk:    glo     r7                ; make sure origin x is left of endpoint x
            str     r2                ; save origin x at M(X)
            glo     r8                ; get endpoint x
            sm                             
            lbdf    wl_slope          ; if positive, the okay (x1 - x0 > 0)
            CALL    swap_points       ; swap so that origin is left of endpoint       
   
wl_slope:   CALL    write_s_line      ; draw a sloping line

wl_done:    POP     r9                ; restore temp register
            CLC                       ; make sure DF = 0
            RETURN



;-------------------------------------------------------------------------------
; Name: draw_lines
;
; Draw a pattern of lines in the buffer  
;-------------------------------------------------------------------------------
draw_lines: LOAD    rf, disp_buff     ; set rf to the display buffer
            LOAD    r7, $0000         ; draw line at top edge
            LOAD    r8, $007F
            CALL    write_line

            LOAD    r7, $3F00         ; draw line at bottom edge
            LOAD    r8, $3F7F
            CALL    write_line
          
            LOAD    r7, $0000         ; draw line at left edge
            LOAD    r8, $3F00
            CALL    write_line
            
            LOAD    r7, $007F         ; draw line at right edge
            LOAD    r8, $3F7F
            CALL    write_line
            
            LOAD    r7, $0000         ; draw diagonal line
            LOAD    r8, $3F7F
            CALL    write_line
            
            LOAD    r7, $007F         ; draw diagonal line
            LOAD    r8, $3F00
            CALL    write_line

            ;-----  draw an intersecting vertical line 
            LOAD    r7, $0040
            LOAD    r8, $3F40
            CALL    write_line
            
            ;-----  draw an intersecting horizontal line 
            LOAD    r7, $2000
            LOAD    r8, $207F
            CALL    write_line
                  
            RETURN 

            ; define buffer for display pattern
disp_buff:  ds     BUFFER_SIZE  

endrom:     equ     $



            
