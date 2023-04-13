#define DISP_WIDTH      128
#define DISP_HEIGHT     64
#define BUFFER_SIZE     1024

; Byte array is 8 bits horizontally stored with 16 bytes per line, MSB first.
; Each byte is so that byte [x,y], where x is int(column/8) and y is the row, 
; When  0 <= y <= 31 the bytes are for the first half of display and these
; bytes are stored in the odd lines (first, third, etc.) in the display buffer.
; Bytes [x,y] with 32 <= y <= 63 is second half of display and these bytes 
; are stored as the even lines (second, fourth, etc.) in the display buffer
;
; Display buffer bytes are as follows:
; [0, 0]  [1, 0]  [2, 0]  ... [E, 0]  [F, 0]    // row 0, start of first half
; [0, 32] [1, 32] [2, 32] ... [E, 32] [F, 32]   // row 32, start of second half
; [0, 1]  [1, 1]  [2, 1]  ... [E, 1]  [F, 1]    // row 1
; [0, 33] [1, 33] [2, 33] ... [E, 33] [F, 33]   // row 33
;  ...                    ...           ...
; [0, 30] [1, 30] [2, 30] ... [E, 30] [F, 30]   // row 30
; [0, 62] [1, 62] [2, 62] ... [E, 62] [F, 62]   // row 62
; [0, 31] [1, 31] [2, 31] ... [E, 31] [F, 31]   // row 31, end of first half
; [0, 33] [1, 63] [2, 63] ... [E, 63] [F, 63]   // row 63, end of second half


DISP_COL_BYTES:         EQU     32              ; 0 <= y < 32
DISP_ROW_BYTES:         EQU      8              ; 0 <= x < 8 

;-------------------------------------------------------------------------
; ST7920 SPI Control constants
;-------------------------------------------------------------------------
; The bits of the SPI control port are as follows:
;
; Bit 7 - If set to 0, the low 6-bits of the control port are set.
;         If set to 1, the low 6-bits of the DMA count are set.
; Bit 6 - Setting this bit to 1 starts a DMA out operation.
; Bit 5 - Setting this bit to 1 starts a DMA in operation (not used here).
; Bit 4 - The MSB of the DMA count when the count is written.
; Bit 3 - CS1 - used by the micro-SD card.
; Bit 2 - CS0 - Chip Select for the OLED port.
; Bit 1 - Active low reset for the OLED display.
; Bit 0 - 0 = Display Control, 1 = Display Data.
;-------------------------------------------------------------------------
; CS0 is tied to PSB, select serial or parallel 
; D/C is tied to RS, register select is true when high
; When PSB = 0, and RS = 1, serial data can be transmitted.
;-------------------------------------------------------------------------

IDLE:                   EQU     $02       ; SPI bus is idle (PSB is high) 
RESET:                  EQU     $01       ; Display reset (RST low)
STANDBY:                EQU     $06       ; Set PSB low, RS low (data disabled) 
DATA:                   EQU     $07       ; PSB low, RS high, serial data enabled

;-------------------------------------------------------------------------
; ST7920 mode constants sent as first byte in serial communication
; Mode constants are 5 marker bits (11111), RW bit, RE bit, plus 0 bit at end
;-------------------------------------------------------------------------

SET_CMD_MODE:           EQU   $F8         ; RW = 0, RE=0, B11111000      
SET_DATA_MODE:          EQU   $FA         ; RW = 0, RE=1, B11111010

;-------------------------------------------------------------------------
; ST7290 commands each command is sent as two bytes
; first byte is high nibble of command, plus four zeros
; second byte is low nibble of command, plus four zeros
;-------------------------------------------------------------------------

SET_DISP_INIT:          EQU   $0C         ; init display command

SET_EXT_CMD:            EQU   $24         ; extended command set
SET_GFX_MODE:           EQU   $26         ; graphics mode command

SET_BASIC_CMD:          EQU   $20         ; basic command set

SET_POSITION:           EQU   $80         ; position command (OR with x or y)
