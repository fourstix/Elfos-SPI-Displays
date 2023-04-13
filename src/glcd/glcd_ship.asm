;-------------------------------------------------------------------------------
; glcd_ship - a demo program for displaying the classic spaceship graphic on
; an ST7920 GLCD display via the SPI Expansion Board for the 1802/Mini Computer. 
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
            db    'Usage: glcd_ship',10,13,0
            ldi   $0a
            RETURN                      ; and return to os

good:       ;---- initialize the display and show the graphic
            CALL  st7920_init               
            LOAD  rf, spaceship
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
              out     EXP_PORT
              db      SPI_GROUP
            #endif

              out     SPI_CTL
              db      IDLE

              ldi     83                  ; delay 1 ms
              plo     rc
delay1:       dec     rc
              glo     rc
              lbnz    delay1
;-------------------------------------------------------------------------------            
;   Reset for the st7920
;-------------------------------------------------------------------------------

              out     SPI_CTL
              db      RESET

              mov     rc, 830           ; hold reset for 10 ms
delay2:       dec     rc
              LBRNZ   rc, delay2

              out     SPI_CTL           ; clear reset line
              db      IDLE

              mov     rc, 4150          ; wait 50 ms for reset to complete
delay3:       dec     rc
              LBRNZ   rc, delay3

              out     SPI_CTL
              db      DATA              ; Set PSB Low, turn on RS 

              ldi     83                ; wait 1 ms
              plo     rc
delay4:       dec     rc
              glo     rc
              lbnz    delay4

              sex     r2                ; set x back to stack
              ldi     SET_DISP_INIT     ; initialize display
              plo     rd                ; save command in rd.0
              STC                       ; DF = 1 to send as a command
              CALL    st7920_send

              sex     r3                ; set x for inline data

              out     SPI_CTL           ; clear reset line
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
; Bit 2 - CS0 - Chip Select for the OLED port.
; Bit 1 - Active low reset for the OLED display.
; Bit 0 - 0 = Display Control, 1 = Display Data.
;
; Parameters: RD.0 - byte to send to display
;             DF = 1, send byte as a command
;             DF = 0, send byte as a data
;
; Return: None
;-------------------------------------------------------------------------------
st7920_send:  PUSH    rc
              
              lbnf    s_data              ; DF indicates command or data byte
              ldi     SET_CMD_MODE        ; DF=1 means send byte as command
              plo     re                  ; save command marker in scratch register
              lbr     s_byte              ; send the byte
                
s_data:       ldi     SET_DATA_MODE       ; DF=0, means send byte as data             
              plo     re                  ; save data marker in scratch register

s_byte:       glo     rd                  ; get low nibble of byte to send
              shl                         ; move low nibble to upper 4 bits
              shl                         ; and fill with zeros
              shl 
              shl
              stxd                        ; put low nibble on stack

              glo     rd                  ; get high nibble of byte to send
              ani     $F0                 ; mask high nibble
              stxd                        ; save high byte on stack 
              
              glo     re                  ; get type marker byte
              str     r2                  ; save at M(x)
              
              out     SPI_DATA            ; send marker byte
              out     SPI_DATA            ; Send high nibble of command
              out     SPI_DATA            ; Send low nibble of command
              dec     r2                  ; put stack pointer back to M(X)    
              
              ldi     83                  ; delay 1 ms after sending byte
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
; Bit 2 - CS0 - Chip Select for the OLED port.
; Bit 1 - Active low reset for the OLED display.
; Bit 0 - 0 = Display Control, 1 = Display Data.
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
            
            ldi     83              ; wait 1 ms
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
            plo     rd              ; set byte to send
            CLC                     ; DF=0 to send byte as data
            CALL    st7920_send     ; send byte to display 

            lda     rf              ; get second display byte
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

spaceship:
    db $C3, $00, $CF, $03, $CF, $0C, $CF, $0F, $CF, $30, $FF, $C0, $0C, $FC, $CC, $0F
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3F, $FC, $00
    db $C3, $00, $CF, $03, $CF, $0C, $CF, $0F, $CF, $30, $FF, $C0, $0C, $FC, $CC, $0F
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3F, $FC, $00
    db $FF, $C0, $0F, $FF, $CC, $0C, $FF, $C0, $03, $03, $CC, $03, $F3, $0F, $3F, $0C
    db $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db $FF, $C0, $0F, $FF, $CC, $0C, $FF, $C0, $03, $03, $CC, $03, $F3, $0F, $3F, $0C
    db $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db $3F, $00, $0C, $0C, $3F, $C0, $0C, $0C, $33, $0C, $F0, $30, $F0, $30, $F0, $30
    db $00, $00, $00, $3C, $00, $00, $00, $03, $00, $00, $00, $00, $00, $00, $00, $03
    db $3F, $00, $0C, $0C, $3F, $C0, $0C, $0C, $33, $0C, $F0, $30, $F0, $30, $F0, $30
    db $00, $00, $00, $3C, $00, $00, $00, $03, $00, $00, $00, $00, $00, $00, $00, $03
    db $FF, $C0, $03, $03, $CF, $00, $FF, $C0, $00, $00, $CC, $00, $C0, $00, $FC, $0C
    db $00, $00, $3F, $FF, $FC, $00, $00, $03, $00, $00, $00, $00, $00, $00, $00, $0C
    db $FF, $C0, $03, $03, $CF, $00, $FF, $C0, $00, $00, $CC, $00, $C0, $00, $FC, $0C
    db $00, $00, $3F, $FF, $FC, $00, $00, $03, $00, $00, $00, $00, $00, $00, $00, $0C
    db $FC, $0C, $0C, $00, $CC, $00, $FC, $0C, $0C, $00, $CC, $00, $FC, $0C, $0C, $00
    db $3F, $FF, $F0, $00, $0F, $FF, $FC, $00, $FF, $F0, $FF, $FF, $FF, $FF, $FF, $FC
    db $FC, $0C, $0C, $00, $CC, $00, $FC, $0C, $0C, $00, $CC, $00, $FC, $0C, $0C, $00
    db $3F, $FF, $F0, $00, $0F, $FF, $FC, $00, $FF, $F0, $FF, $FF, $FF, $FF, $FF, $FC
    db $CC, $00, $0F, $F0, $03, $FC, $0F, $00, $00, $FF, $FC, $0C, $3C, $C3, $0F, $FF
    db $30, $00, $00, $FF, $00, $00, $03, $00, $00, $30, $C0, $00, $00, $00, $00, $00
    db $CC, $00, $0F, $F0, $03, $FC, $0F, $00, $00, $FF, $FC, $0C, $3C, $C3, $0F, $FF
    db $30, $00, $00, $FF, $00, $00, $03, $00, $00, $30, $C0, $00, $00, $00, $00, $00
    db $0C, $FF, $3C, $F0, $CC, $30, $0F, $3F, $0F, $0F, $0F, $FF, $0F, $33, $3C, $F0
    db $3F, $FF, $F0, $00, $0F, $FF, $FC, $00, $00, $30, $C0, $00, $00, $00, $00, $00
    db $0C, $FF, $3C, $F0, $CC, $30, $0F, $3F, $0F, $0F, $0F, $FF, $0F, $33, $3C, $F0
    db $3F, $FF, $F0, $00, $0F, $FF, $FC, $00, $00, $30, $C0, $00, $00, $00, $00, $00
    db $33, $30, $03, $30, $0F, $00, $0F, $0F, $00, $00, $3C, $C3, $0C, $0F, $3C, $C3
    db $00, $00, $0F, $FF, $F3, $00, $30, $00, $00, $30, $C0, $00, $00, $00, $00, $00
    db $33, $30, $03, $30, $0F, $00, $0F, $0F, $00, $00, $3C, $C3, $0C, $0F, $3C, $C3
    db $00, $00, $0F, $FF, $F3, $00, $30, $00, $00, $30, $C0, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $FF, $00, $C0, $0C, $00, $00, $30, $C0, $00, $3F, $CC, $03, $FC
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $FF, $00, $C0, $0C, $00, $00, $30, $C0, $00, $3F, $CC, $03, $FC
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $3F, $C3, $00, $00, $30, $C0, $00, $30, $0C, $03, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $3F, $C3, $00, $00, $30, $C0, $00, $30, $0C, $03, $00
    db $3F, $CF, $F3, $FC, $F3, $CF, $F3, $FC, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $03, $C0, $3F, $FF, $FF, $F0, $FF, $00, $3F, $0C, $03, $F0
    db $3F, $CF, $F3, $FC, $F3, $CF, $F3, $FC, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $03, $C0, $3F, $FF, $FF, $F0, $FF, $00, $3F, $0C, $03, $F0
    db $30, $CC, $33, $00, $F3, $CC, $33, $0C, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $0F, $00, $00, $00, $00, $00, $03, $00, $30, $0C, $03, $00
    db $30, $CC, $33, $00, $F3, $CC, $33, $0C, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $0F, $00, $00, $00, $00, $00, $03, $00, $30, $0C, $03, $00
    db $30, $0C, $33, $FC, $CC, $CF, $F3, $00, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $3F, $0F, $FF, $F0, $00, $00, $03, $00, $3F, $CF, $F3, $00
    db $30, $0C, $33, $FC, $CC, $CF, $F3, $00, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $3F, $0F, $FF, $F0, $00, $00, $03, $00, $3F, $CF, $F3, $00
    db $30, $CC, $30, $0C, $C0, $CC, $33, $0C, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $0F, $00, $00, $00, $0F, $FF, $FF, $00, $00, $00, $00, $00
    db $30, $CC, $30, $0C, $C0, $CC, $33, $0C, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $0F, $00, $00, $00, $0F, $FF, $FF, $00, $00, $00, $00, $00
    db $3F, $CF, $F3, $FC, $C0, $CC, $33, $FC, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $03, $C0, $00, $FF, $F0, $00, $00, $00, $00, $00, $00, $00
    db $3F, $CF, $F3, $FC, $C0, $CC, $33, $FC, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $03, $C0, $00, $FF, $F0, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $3F, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $3F, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00
  
            
endrom:     equ     $
