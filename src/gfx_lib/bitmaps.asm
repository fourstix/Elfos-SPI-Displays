;-------------------------------------------------------------------------------
; Display a set of bitmaps on an OLED display using the SH1106 controller 
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
            db      10             ; Day
            dw      2023           ; year
           
            ; Current build number
build:      dw      3              ; build
            db      'Copyright 2023 by Gaston Williams',0


            ; Main code starts here, check provided argument

main:       lda   ra                    ; move past any spaces
            smi   ' '
            lbz   main
            dec   ra                    ; move back to non-space character
            ldn   ra                    ; get byte
            lbz   good                  ; jump if no argument given
            call  o_inmsg               ; otherwise display usage message
            db    'Usage: bitmaps',10,13,0
            ldi   $0a
            RETURN                      ; and return to os

good:       LOAD  rf, buffer            ; point rf to display buffer
            CALL  clearBuffer            ; fill buffer
                  
            ;---- setup the display
            LOAD  rf, buffer            ; point rf to display buffer                        
            CALL  sh1106_init          

                        
            LOAD  rf, buffer            ; show updated display                        
            LOAD  rd, test_bmp          ; point to bitmap buffer             
            LOAD  r8, $1010             ; bitmap h = 16, w = 16
            LOAD  r7, $0008
            CALL  drawBitmap            ; draw bitmap at random location
            lbdf  error

            LOAD  rd, test_bmp          ; point to bitmap buffer             
            LOAD  r8, $1010             ; bitmap h = 16, w = 16
            LOAD  r7, $2020
            CALL  drawBitmap            ; draw bitmap at random location
            lbdf  error

            LOAD  rd, test_bmp          ; point to bitmap buffer             
            LOAD  r8, $1010             ; bitmap h = 16, w = 16
            LOAD  r7, $1045
            CALL  drawBitmap            ; draw bitmap at random location
            lbdf  error

            LOAD  rd, test_bmp          ; point to bitmap buffer             
            LOAD  r8, $1010             ; bitmap h = 16, w = 16
            LOAD  r7, $286F
            CALL  drawBitmap            ; draw bitmap at random location
            lbdf  error

            LOAD  rf, buffer            ; show updated display
            CALL  sh1106_display

            CALL o_inmsg
                db 'Done.',10,13,0
            CLC
            RETURN
                      
error:      CALL o_inmsg
            db 'Error drawing bitmap.',10,13,0
            RETURN
               
;----- Adafruit flower
test_bmp: db $00, $C0, $01, $C0, $01, $C0, $03, $E0, $F3, $E0, $FE, $F8, $7E, $FF, $33, $9F
          db $1F, $FC, $0D, $70, $1B, $A0, $3F, $E0, $3F, $F0, $7C, $F0, $70, $70, $30, $30
            
buffer:     ds    BUFFER_SIZE
            end   start
