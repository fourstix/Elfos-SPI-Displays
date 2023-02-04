;-------------------------------------------------------------------------------
; Display various lines on an OLED display using the SH1106 controller chip
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
            db    'Usage: linetest',10,13,0
            ldi   $0a
            RETURN                      ; and return to os

good:       LOAD  rf, buffer            ; point rf to display buffer
            CALL  clearBuffer           ; clear out buffer

            ;---------- horizontal line test            
            LOAD   r7, $0010             ; draw along top border
            LOAD   r8, $0070             
            CALL   drawLine
            lbdf   error

            lbnf   test_h2
            CALL   O_INMSG
            db     'H1 Error.',10,13,0
            
            ;---------- horizontal line test (r7, r8 need swapping)
test_h2:    LOAD   r7, $0650             ; draw horizontal line from (2,2)
            LOAD   r8, $0620             ; to endpoint of (50,2)
            CALL   drawLine
            lbnf   test_h3
            CALL   O_INMSG
            db     'H2 Error.',10,13,0

            ;---------- horizontal line test (boundaries)
test_h3:    LOAD   r7, $2000             ; draw horizontal line from (0,32)
            LOAD   r8, $207F             ; to endpoint of (127,32)
            CALL   drawLine
            lbnf   test_v1
            CALL   O_INMSG
            db     'H3 Error.',10,13,0

            ;---------- vertical line test
test_v1:    LOAD   r7, $2030             ; draw vertical line from (48,16)
            LOAD   r8, $0030             ; to endpoint of (48,48)
            CALL   drawLine
            lbnf   test_v2
            CALL   O_INMSG
            db     'V1 Error.',10,13,0

            ;---------- vertical line test (r7, r8 need swapping)
test_v2:    LOAD   r7, $0060             ; draw vertical line from (32,16)
            LOAD   r8, $2060             ; to endpoint of (32,48)
            CALL   drawLine
            lbnf   test_v3
            CALL   O_INMSG
            db     'V2 Error.',10,13,0

            ;---------- vertical line test
test_v3:    LOAD   r7, $0050             ; draw vertical line from (80,0)
            LOAD   r8, $3F50             ; to endpoint of (80,63)
            CALL   drawLine
            lbnf   test_s1
            CALL   O_INMSG
            db     'V3 Error.',10,13,0
            
            ;----------  sloping line test (flat, positive slope)
test_s1:    LOAD     r7, $3213
            LOAD     r8, $3A28
            CALL     drawLine
            lbnf     test_s2
            CALL     O_INMSG
            db       'S1 Error.',10,13,0

            
            ;----------  sloping line test (flat, negative slope)
test_s2:    LOAD     r7, $3843
            LOAD     r8, $3058
            CALL     drawLine
            lbnf     test_s3
            CALL     O_INMSG
            db       'S2 Error.',10,13,0

            ;----------  sloping line test (flat, positive, needs swap)
test_s3:    LOAD     r7, $2A28
            LOAD     r8, $2213
            CALL     drawLine
            lbnf     test_s4
            CALL     O_INMSG
            db       'S3 Error.',10,13,0

            ;----------  sloping line test (steep, positive slope)
test_s4:    LOAD     r7, $2213
            LOAD     r8, $3218
            CALL     drawLine
            lbnf     test_s5
            CALL     O_INMSG
            db       'S4 Error.',10,13,0

            ;----------  sloping line test (steep, negative slope)
test_s5:    LOAD     r7, $3B50
            LOAD     r8, $1B58
            CALL     drawLine
            lbnf     test_done
            CALL     O_INMSG
            db       'S5 Error.',10,13,0

            ;---- udpate the display
test_done:  CALL  sh1106_init          
            
            LOAD  rf, buffer
            CALL  sh1106_display

done:       CLC   
            RETURN
            
error:      CALL o_inmsg
            db 'Error setting pixel.',10,13,0
            RETURN
            
buffer:     ds    BUFFER_SIZE
            end   start
