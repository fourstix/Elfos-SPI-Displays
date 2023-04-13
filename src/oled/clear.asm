;-------------------------------------------------------------------------------
; Clear the the OLED display using the SH1106 controller chip connected
; to port 0 of the 1802/Mini SPI interface.
;
; Copyright 2023 by Gaston Williams
;
; Based on code from the Elf-Elfos-OLED library
; Written by Tony Hefner
; Copyright 2022 by Tony Hefner
;
; SPI Expansion Board for the 1802/Mini Computer hardware
; Copyright 2022 by Tony Hefner 
;-------------------------------------------------------------------------------

#include include/bios.inc
#include include/kernel.inc
#include include/ops.inc
#include include/sh1106_oled.inc

            org   2000h
start:      br    main


            ; Build information
            ; Build date
date:       db      80h+2         ; Month, 80h offset means extended info
            db      19             ; Day
            dw      2023           ; year
           
            ; Current build number
build:      dw      2              ; build

            db    'Copyright 2023 by Gaston Williams',0


            ; Main code starts here, check provided argument

main:       lda   ra                    ; move past any spaces
            smi   ' '
            lbz   main
            dec   ra                    ; move back to non-space character
            ldn   ra                    ; get byte
            lbz   clr                   ; jump if no argument given
            call  o_inmsg               ; otherwise display usage message
            db    'Usage: clear',10,13,0
            ldi   $0a
            rtn                         ; and return to os

clr:        CALL  init_oled
            CALL  clear_oled

done:       ldi   0
            rtn

            end   start
