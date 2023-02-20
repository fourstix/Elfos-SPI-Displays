;-------------------------------------------------------------------------------
; sh1106_oled - a library for updating a SH1106 OLED display via
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
#include    ../include/bios.inc
#nclude     ../include/kernel.inc
#include    ../include/ops.inc
#include    ../include/sysconfig.inc
#include    ../include/sh1106.inc

;-------------------------------------------------------------------------------
; Name: clear_oled
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
            proc    clear_oled
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
