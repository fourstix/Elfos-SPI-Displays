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
; Name: send_oled
;
; Send a single byte to the display using the SH1106 controller chip connected
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
; Parameters: D - data byte to write
;
; Return: None
;-------------------------------------------------------------------------------
            proc    send_oled
            plo     re              ; save byte in scratch register
            sex     r3              ; set x to P to output data

          #if SPI_GROUP
            out     EXP_PORT
            db      SPI_GROUP
          #endif

            out     SPI_CTL
            db      DATA

            sex     r2              ; set x back to stack

            glo     re              ; get data byte from scratch register
            str     r2              ; save at M(X)

            out     SPI_DATA        ; send byte
            dec     r2              ; fix stack pointer
            
            sex     r3              ; set x for next page commands or exit

            out     SPI_CTL         ; done updating display, prepare to exit
            db      IDLE

          #if SPI_GROUP
            out     EXP_PORT
            db      NO_GROUP
          #endif

            sex     r2              ; set x back to stack for exit
            rtn

            endp
