;-------------------------------------------------------------------------------
; Display a set of rectangles on an OLED display using the SH1106 controller 
; chip connected to port 0 of the 1802/Mini SPI interface.
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
#include include/macros.inc
#include include/sh1106.inc
#include include/sh1106_lib.inc
#include include/gfx_lib.inc

            org   2000h
start:      br    main


            ; Build information
            ; Build date
date:       db      80h+2          ; Month, 80h offset means extended info
            db      4              ; Day
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
            db    'Usage: boxes',10,13,0
            ldi   $0a
            RETURN                      ; and return to os

good:       LOAD  rf, buffer            ; point rf to display buffer
            CALL  clearBuffer           ; clear out buffer
            
            LOAD   r7, $0000             ; draw border rectangle
            LOAD   r8, $3F7F             
            CALL   drawRect
            lbdf   error

            LOAD   r7, $0810             ; draw rectangle inside first
            LOAD   r8, $3060             
            CALL   drawRect
            lbdf   error

            LOAD   r7, $1020             ; draw rectangle inside second
            LOAD   r8, $2040             
            CALL   drawRect
            lbdf   error


            LOAD   r7, $1828             ; draw last rectangle
            LOAD   r8, $1030             
            CALL   drawRect
            lbdf   error

            ;---- udpate the display
            CALL  sh1106_init          
            
            LOAD  rf, buffer
            CALL  sh1106_display

done:       CLC   
            RETURN
            
error:      CALL o_inmsg
            db 'Error drawing rectangles.',10,13,0
            RETURN
            
buffer:     ds    BUFFER_SIZE
            end   start
