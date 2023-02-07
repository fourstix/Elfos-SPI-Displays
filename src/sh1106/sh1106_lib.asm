;-------------------------------------------------------------------------------
; sh1106_lib - a library for updating a SH1106 display via
; the SPI Expansion Board for the 1802/Mini Computer. 
;
; Copyright 2023 by Gaston Williams
;
; Based on code from the Elf-Elfos-OLED library
; Written by Tony Hefner
; Copyright 2022 by Tony Hefner
;
; Based on code from Adafruit_SH110X library
; Written by Limor Fried/Ladyada for Adafruit Industries  
; Copyright xxx by Adafruit Industries
;
; SPI Expansion Board for the 1802/Mini Computer hardware
; Copyright 2022 by Tony Hefner 
;-------------------------------------------------------------------------------
#include    include/bios.inc
#nclude     include/kernel.inc
#include    include/macros.inc
#include    include/sysconfig.inc
#include    include/sh1106.inc

.link       .align  page

;-------------------------------------------------------------------------------
; Name: sh1106_init
;
; Initializes the OLED display using the SH1106 controller chip connected
; to port 0 of the 1802/Mini SPI interface. 
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
; Parameters: None
;
; Return: None
;-------------------------------------------------------------------------------
            proc    sh1106_init
            push    rc

            sex     r3

          #if SPI_GROUP
            out     EXP_PORT
            db      SPI_GROUP
          #endif

            out     SPI_CTL
            db      IDLE

            ldi     83                  ; delay 1 ms
            plo     rc
delay1:     dec     rc
            glo     rc
            bnz     delay1
;-------------------------------------------------------------------------------            
;   No need to reset for the SH1106
;-------------------------------------------------------------------------------

;            ; out     SPI_CTL
;            ; db      RESET

;            mov     rc, 830             ; delay 10 ms
; delay2:     dec     rc
;             brnz    rc, delay2

            out     SPI_CTL
            db      IDLE

            mov     rc, 830             ; delay 10 ms
delay3:     dec     rc
            brnz    rc, delay3

            mov     r0, dma_init
            sex     r0

            out     SPI_CTL             ; Set DMA count
            out     SPI_CTL             ; Start control DMA out

            sex     r3

            out     SPI_CTL
            db      IDLE

          #if SPI_GROUP
            out     EXP_PORT
            db      NO_GROUP
          #endif

            sex     r2

            pop     rc
            rtn

dma_init:   db      $19 | $80           ; set low 6-bits of count
                                        ; = (init_end - init_start)
            db      $46                 ; enable control dma

            ;---------------------------------------------
            ; Init sequence for SH1106 displays.          
            ; Source: Adafruit SH1106 Display driver      
            ; https://github.com/adafruit/Adafruit_SH110x 
            ;---------------------------------------------
init_start: db      SET_DISP_OFF                    ; 0xAE,
            db      SET_DISP_CLK_DIV, $80           ; 0xD5, 0x80
            db      SET_MUX_RATIO, DISP_HEIGHT - 1  ; 0xA8, 0x3F,
            db      SET_DISP_OFFSET, $00            ; 0xD3, 0x00, 
            db      SET_START_LINE                  ; 0x40, 
            db      SET_CHARGEPUMP, $14             ; 0x8D, 0x14            
            db      SET_MEM_ADDR_MODE, HORZ_MODE    ; 0x20, 0x00
            db      SET_SEG_REMAP_ON                ; 0xA1,             
            db      SET_COM_SCAN_DEC                ; 0xC8,
            db      SET_COM_PIN_CFG, $12            ; 0xDA, 0x12,
            db      SET_CONTRAST, $CF               ; 0x81, 0xCF,
            db      SET_PRECHARGE, $F1              ; 0xD9, 0xF1,
            db      SET_VCOM_DETECT, $40            ; 0xDB, 0x40,
            db      SET_ALL_ON_RESUME               ; 0xA4
            db      SET_NORMAL_DISP                 ; 0xA6 
            db      SET_DISP_ON                     ; 0xAF
init_end:
           endp

;-------------------------------------------------------------------------------
; Name: sh1106_clear
;
; Clear the the OLED display using the SH1106 controller chip connected
; to port 0 of the 1802/Mini SPI interface.
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
; Parameters: None
;
; Return: None
;-------------------------------------------------------------------------------
            proc    sh1106_clear
            push    rc              ; save reg used as byte count
            push    r8              ; save reg used as page count
            sex     r3

          #if SPI_GROUP
            out     EXP_PORT
            db      SPI_GROUP
          #endif

            out     SPI_CTL
            db      COMMAND
            out     SPI_DATA
            db      SET_COL_LOW
            out     SPI_DATA
            db      SET_COL_HIGH
            out     SPI_DATA
            db      SET_START_LINE
            out     SPI_CTL
            db      IDLE
            
            mov     r8, 0              ; set up page counter

fillpage:   out     SPI_CTL
            db      COMMAND
            sex     r2
            ldi     SET_PAGE
            str     r2              ; put base page in m(x)
            glo     r8              ; get page count
            add                     ; D = M(X) + D
            str     r2          
            out     SPI_DATA        ; send page command
            dec     r2              ; fix stack pointer
            inc     r8              ; bump counter
            sex     r3
            out     SPI_DATA
            db      SET_COL_LOW     ; set lower column address
            out     SPI_DATA
            db      SET_COL_HIGH    ; set higer column address
            out     SPI_CTL
            db      IDLE

            out     SPI_CTL
            db      DATA

            sex     r2

            mov     rc, 128         ; send a whole page of data at once

            ldi     0               ; clear display
            str     r2

f_loop:     out     SPI_DATA        ; send byte
            dec     r2              ; fix stack pointer

            dec     rc
            lbrnz   rc, f_loop        

            sex     r3              ; set x for next page commands or exit
            glo     r8              ; get the page count
            smi     08              ; check to see if we have sent all 8 pages

            lbnf    fillpage        ; if negative (DF = 0) fill next page
      
            out     SPI_CTL         ; end spi and prepare to exit
            db      IDLE

          #if SPI_GROUP
            out     EXP_PORT
            db      NO_GROUP
          #endif

            sex     r2

            pop     r8          ; restore reg used as page count
            pop     rc          ; restore reg used as byte count
            rtn

            endp


;-------------------------------------------------------------------------------
; Name: sh1106_display
;
; Copy a complete image from frame buffer to display using the SH1106 
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
            proc    sh1106_display
            push    rc              ; save reg used as byte count
            push    r8              ; save reg used as page count

            sex     r3

          #if SPI_GROUP
            out     EXP_PORT
            db      SPI_GROUP
          #endif

            out     SPI_CTL
            db      COMMAND
            out     SPI_DATA
            db      SET_COL_LOW
            out     SPI_DATA
            db      SET_COL_HIGH
            out     SPI_DATA
            db      SET_START_LINE
            out     SPI_CTL
            db      IDLE
            
            mov     r8, 0           ; set up page counter

disp_page:  out     SPI_CTL
            db      COMMAND
            sex     r2
            ldi     SET_PAGE
            str     r2              ; put base page in m(x)
            glo     r8              ; get page count
            add                     ; D = M(X) + D
            str     r2          
            out     SPI_DATA        ; send page command
            dec     r2              ; fix stack pointer
            inc     r8              ; bump counter
            sex     r3
            out     SPI_DATA
            db      SET_COL_LOW     ; set lower column address
            out     SPI_DATA
            db      SET_COL_HIGH    ; set higer column address
            out     SPI_CTL
            db      IDLE

            out     SPI_CTL
            db      DATA

            sex     r2

            mov     rc, 128         ; send a whole page of data at once

d_loop:     lda     rf              ; get byte from buffer
            str     r2              ; save at M(X)

            out     SPI_DATA        ; send byte
            dec     r2              ; fix stack pointer

            dec     rc
            lbrnz   rc, d_loop        

            sex     r3              ; set x for next page commands or exit

            glo     r8              ; get the page count
            smi     08              ; check to see if we have sent all 8 pages

            lbnf    disp_page       ; if negative (DF = 0) fill next page
      

            out     SPI_CTL         ; done updating display, prepare to exit
            db      IDLE

          #if SPI_GROUP
            out     EXP_PORT
            db      NO_GROUP
          #endif

            sex     r2

            pop     r8          ; restore reg used as page count
            pop     rc          ; restore reg used as byte count
            rtn

            endp
            
