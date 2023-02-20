;-------------------------------------------------------------------------------
; Display a greeting on an OLED display using the SH1106 controller 
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
            db    'Usage: helloworld',10,13,0
            ldi   $0a
            RETURN                      ; and return to os

good:       LOAD  rf, buffer            ; point rf to display buffer
            CALL  clear_buffer          ; clear buffer
                  
            ;---- setup the display
            LOAD  rf, buffer            ; point rf to display buffer                        
            CALL  init_oled          

            


            ;---- draw text with background cleared
            LOAD  r7, $0C00             ;---- Set R7 to beginning of line 12
            LOAD  r8, greeting          ;---- set string buffer
            ldi   GFX_BG_OPAQUE         ; background cleared
            phi   r9    
            
            LOAD  rf, buffer            ; point rf to display buffer                        
            CALL  draw_string            ; draw character   
            
show:       LOAD  rf, buffer            ; show updated display
            CALL  show_oled

            CALL o_inmsg
                db 'Done.',10,13,0
            CLC
            RETURN
                      
error:      CALL o_inmsg
            db 'Error drawing string.',10,13,0
            RETURN
            
greeting:   db 'Hello, World!',0            
                           
buffer:     ds    BUFFER_SIZE
            end   start
