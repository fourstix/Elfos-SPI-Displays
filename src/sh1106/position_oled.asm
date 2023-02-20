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
; Name: position_oled
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
; Parameters: r7.1 - y position (0 to 63)
;             r7.0 - x position (0 to 127)
;
; Return: None
;-------------------------------------------------------------------------------
            proc    position_oled
            sex     r3

          #if SPI_GROUP
            out     EXP_PORT
            db      SPI_GROUP
          #endif
          ;---------------------------------------------------------------------
          ; SH1106 controller RAM has space for 132 bits, but the display is 128
          ; pixels wide, centered.  So we need to offset x by 2 for ram address.
          ;---------------------------------------------------------------------
          
            inc     r7      ; x = x + 2
            inc     r7      ; r7.0 now points to column address

            out     SPI_CTL
            db      COMMAND
            
            sex     r2        ; point x back to stack
            
            ghi     r7        ; get row address (y)
            adi     $B0       ; add $B0 for row address command (B0 + y)
            str     r2        ; save in M(X)
  
            out     SPI_DATA  ; set row address (X register is incremented)
            
            dec     r2        ; point back to bottom of stack  
            glo     r7
            ani     $0F       ; get lower column address (x & 0F)
            str     r2        ; save in M(X)
            
            out     SPI_DATA  ; set lower column address (X reg is incremented)
            dec     r2        ; point back to bottom of stack  
            
            glo     r7
            shr               ; shift x right 4 bits for upper column address
            shr               ; upper column address is (x >> 4)
            shr               
            shr               ; hi nibble shifted down to lo nibble
            ori     $10       ; set bit 5 for upper column address command 
            str     r2        ; save in M(X)
            
            out     SPI_DATA
            dec     r2        ; point back to bottom of stack  

            sex     r3
            out     SPI_CTL
            db      IDLE
            
          #if SPI_GROUP
            out     EXP_PORT
            db      NO_GROUP
          #endif

            sex     r2
            rtn

            endp
