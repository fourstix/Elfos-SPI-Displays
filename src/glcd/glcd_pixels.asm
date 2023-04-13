;-------------------------------------------------------------------------------
; glcd_pixels - a demo program for displaying pixel patterns on an ST7920 
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
            db    'Usage: glcd_pixels',10,13,0
            ldi   $0a
            RETURN                      ; and return to os

good:       ;---- initialize the display, draw the pattern, show pattern
            CALL  st7920_init               
            LOAD  rf, disp_buff         ; update the display
            CALL  clear_buff            ; clear the buffer
            CALL  draw_plus             ; draw pixels in upper part of display
            CALL  draw_box              ; draw pixels in lower part of display
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
; Return: None
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


;-------------------------------------------------------------------------------
; Name: draw_plus
;
; Draw a small plus sign in the buffer in the top half of display (y < 32) 
;-------------------------------------------------------------------------------
draw_plus:  LOAD    rf, disp_buff     ; set rf to the display buffer
            ;-----  draw a plus sign centered at x=12 ($0C), y=10 ($0A)
            ;-----  draw a horizontal line
            LOAD    r7, $0A0A
            CALL    set_pixel
            LOAD    r7, $0A0B
            CALL    set_pixel
            LOAD    r7, $0A0C
            CALL    set_pixel
            LOAD    r7, $0A0D
            CALL    set_pixel
            LOAD    r7, $0A0E
            CALL    set_pixel

            ;-----  draw an intersecting vertical line 
            LOAD    r7, $080C
            CALL    set_pixel
            LOAD    r7, $090C
            CALL    set_pixel
            ;-----  skip pixel already drawn at $0A0C
            LOAD    r7, $0B0C
            CALL    set_pixel
            LOAD    r7, $0C0C
            CALL    set_pixel
        
            RETURN 

;-------------------------------------------------------------------------------
; Name: draw_box
;
; Draw a small rectangle in the buffer for the bottom half of display (y > 32) 
;-------------------------------------------------------------------------------
draw_box:   LOAD    rf, disp_buff     ; set rf to the display buffer
            ;-----  draw box from x=80 ($50), y=39 ($27) to x=85 ($55), y=43 ($2B)
            ;-----  draw left side
            LOAD    r7, $2750
            CALL    set_pixel
            LOAD    r7, $2850
            CALL    set_pixel
            LOAD    r7, $2950
            CALL    set_pixel
            LOAD    r7, $2A50
            CALL    set_pixel
            LOAD    r7, $2B50
            CALL    set_pixel
            
            ;-----  draw bottom line
            ;-----  skip pixel already drawn at $2B50
            LOAD    r7, $2B51
            CALL    set_pixel
            LOAD    r7, $2B52
            CALL    set_pixel
            LOAD    r7, $2B53
            CALL    set_pixel
            LOAD    r7, $2B54
            CALL    set_pixel
            LOAD    r7, $2B55
            CALL    set_pixel
        
            ;------ draw left side
            LOAD    r7, $2755
            CALL    set_pixel
            LOAD    r7, $2855
            CALL    set_pixel
            LOAD    r7, $2955
            CALL    set_pixel
            LOAD    r7, $2A55
            CALL    set_pixel
            ;-----  skip pixel already drawn at $2B55

            ;-----  draw top line
            ;-----  skip pixel already drawn at $2750
            LOAD    r7, $2751
            CALL    set_pixel
            LOAD    r7, $2752
            CALL    set_pixel
            LOAD    r7, $2753
            CALL    set_pixel
            LOAD    r7, $2754
            CALL    set_pixel
            ;-----  skip pixel already drawn at $2755
            
            RETURN 

            ; define buffer for display pattern
disp_buff:  ds     BUFFER_SIZE  

endrom:     equ     $



            
