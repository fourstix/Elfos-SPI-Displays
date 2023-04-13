;-------------------------------------------------------------------------------
; Display a set of lines on an OLED display using the SH1106 controller chip 
; connected to port 0 of the 1802/Mini SPI interface.
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
#include include/sh1106_oled.inc
#include include/gfx_oled.inc

            org   2000h
start:      br    main


            ; Build information
            ; Build date
date:       db      80h+2          ; Month, 80h offset means extended info
            db      19             ; Day
            dw      2023           ; year
           
            ; Current build number
build:      dw      2              ; build
            db      'Copyright 2023 by Gaston Williams',0


            ; Main code starts here, check provided argument

main:       lda   ra                    ; move past any spaces
            smi   ' '
            lbz   main
            dec   ra                    ; move back to non-space character
            ldn   ra                    ; get byte
            lbz   good                  ; jump if no argument given
            call  o_inmsg               ; otherwise display usage message
            db    'Usage: lines',10,13,0
            ldi   $0a
            RETURN                      ; and return to os

good:       LOAD  rf, buffer            ; point rf to display buffer
            CALL  clear_buffer          ; clear out buffer
            
            LOAD   r7, $0000             ; draw top border
            LOAD   r8, $007F             
            CALL   draw_line
            lbdf   error

            LOAD   r7, $0000             ; draw left border
            LOAD   r8, $3F00             
            CALL   draw_line
            lbdf   error


            LOAD   r7, $007F             ; draw right border
            LOAD   r8, $3F7F             
            CALL   draw_line
            lbdf   error


            LOAD   r7, $3F00             ; draw bottom border
            LOAD   r8, $3F7F             
            CALL   draw_line
            lbdf   error

            LOAD   r7, $0000             ; draw diagonals
            LOAD   r8, $3F7F             
            CALL   draw_line
            lbdf   error

            LOAD   r7, $007F             ; draw diagonals
            LOAD   r8, $3F00             
            CALL   draw_line
            lbdf   error

            LOAD   r7, $0040             ; draw vertical line
            LOAD   r8, $3F40             
            CALL   draw_line
            lbdf   error

            LOAD   r7, $2000             ; draw horizontal line
            LOAD   r8, $207F             
            CALL   draw_line
            lbdf   error

            ;---- udpate the display
            CALL  init_oled          
            
            LOAD  rf, buffer
            CALL  show_oled

done:       CLC   
            RETURN
            
error:      CALL o_inmsg
            db 'Error drawing line.',10,13,0
            RETURN
            
buffer:     ds    BUFFER_SIZE
            end   start
