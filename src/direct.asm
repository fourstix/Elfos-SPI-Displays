;-------------------------------------------------------------------------------
; Display a simple pattern made by writing bytes directly to the
; SH1106 controller chip connected to port 0 of the 1802/Mini SPI interface.
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
#include include/sh1106.inc
#include include/sysconfig.inc
#include include/sh1106_oled.inc
#include include/gfx_oled.inc

            org   2000h
start:      br    main


            ; Build information
            ; Build date
date:       db      80h+3          ; Month, 80h offset means extended info
            db      8              ; Day
            dw      2023           ; year
           
            ; Current build number
build:      dw      2             ; build
            db    'Copyright 2023 by Gaston Williams',0


            ; Main code starts here, check provided argument

main:       lda   ra                    ; move past any spaces
            smi   ' '
            lbz   main
            dec   ra                    ; move back to non-space character
            ldn   ra                    ; get byte
            lbz   good                  ; jump if no argument given
            call  o_inmsg               ; otherwise display usage message
            db    'Usage: direct',10,13,0
            ldi   $0a
            RETURN                      ; and return to os

good:       ;---- initialize and clear the display
            CALL  init_oled          
            CALL  clear_oled          

            ; position display cursor to write single bytes
            LOAD   r7, $0A14
            CALL   position_oled
            ; write a 4 byte test pattern
            ldi    $AA
            CALL   send_oled   
            ldi    $55
            CALL   send_oled   
            ldi    $AA
            CALL   send_oled   
            ldi    $55
            CALL   send_oled   

            ; position the display cursor to write a buffer
            LOAD   r7, $3050
            CALL   position_oled

            LOAD   rf, vert_bmp       ; set ptr to vertical bitmap buffer
            LOAD   r8, 32             ; set counter for 32 bytes
            CALL   write_oled   



done:       CLC   
            RETURN
            
error:      CALL o_inmsg
            db 'Error setting pixel.',10,13,0
            RETURN

;----- simple pattern of 32 x 8 bits 
vert_bmp: db $FF, $81, $99, $99, $81, $FF, $81, $99, $99, $81, $FF, $81, $99, $99, $81, $FF
          db $81, $99, $99, $81, $FF, $81, $99, $99, $81, $FF, $81, $99, $99, $81, $FF, $00

            end   start
            
