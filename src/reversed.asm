;-------------------------------------------------------------------------------
; Display a set of reversed (black on white) lines on an OLED display using the  
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
            db    'Usage: reversed',10,13,0
            ldi   $0a
            RETURN                      ; and return to os

good:       LOAD  rf, buffer            ; point rf to display buffer
            CALL  fill_buffer           ; fill buffer for all white background
            
            LOAD   r7, $0000            ; clear top border
            LOAD   r8, $007F             
            CALL   clear_line
            lbdf   error

            LOAD   r7, $0000            ; clear left border
            LOAD   r8, $3F00             
            CALL   clear_line
            lbdf   error


            LOAD   r7, $007F            ; clear right border
            LOAD   r8, $3F7F             
            CALL   clear_line
            lbdf   error


            LOAD   r7, $3F00            ; clear bottom border
            LOAD   r8, $3F7F             
            CALL   clear_line
            lbdf   error

            LOAD   r7, $0000            ; clear diagonals
            LOAD   r8, $3F7F             
            CALL   clear_line
            lbdf   error

            LOAD   r7, $007F            ; clear diagonals
            LOAD   r8, $3F00             
            CALL   clear_line
            lbdf   error

            LOAD   r7, $0040            ; clear vertical line
            LOAD   r8, $3F40             
            CALL   clear_line
            lbdf   error

            LOAD   r7, $2000            ; clear horizontal line
            LOAD   r8, $207F             
            CALL   clear_line
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
