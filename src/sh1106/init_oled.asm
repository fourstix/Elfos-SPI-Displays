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
; Name: init_oled
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
            proc    init_oled
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
            lbnz    delay1

            out     SPI_CTL
            db      RESET

            mov     rc, 830             ; delay 10 ms
delay2:     dec     rc
            lbrnz   rc, delay2

            out     SPI_CTL
            db      IDLE

            mov     rc, 830             ; delay 10 ms
delay3:     dec     rc
            lbrnz   rc, delay3

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
