;-------------------------------------------------------------------------------
; glcd_clear - a demo program for clearing an ST7920 GLCD display
; via the SPI Expansion Board for the 1802/Mini Computer. 
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
            db    'Usage: glcd_clear',10,13,0
            ldi   $0a
            RETURN                      ; and return to os

good:       ;---- initialize and draw the display
            CALL  st7920_init               
            CALL  st7920_clear
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

              sex     r2                  ; set x for stack

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
; Name: st7920_clear
;
; Clear the display by sending zeros to the display using the st7920 controller
; chip connected to port 0 of the 1802/Mini SPI interface. 
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
; Parameters: (None)
;
; Return: None
;-------------------------------------------------------------------------------
st7920_clear:
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

d_loop:     ldi     0               ; set first display byte to zero
            plo     rd              ; set byte to send
            CLC                     ; DF=0 to send byte as data
            CALL    st7920_send     ; send byte to display 

            ldi     0               ; set second display byte to zero
            plo     rd              ; set byte to send
            CLC                     ; DF=0 to send byte as data
            CALL    st7920_send     ; send byte to display 
                      
            dec     rc              ; count down 
            glo     rc              ; check line byte counter
            bnz     d_loop          ; keep sending all 16 bytes for two lines

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
            
endrom:     equ     $
