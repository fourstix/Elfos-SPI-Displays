#define DISP_WIDTH      128
#define DISP_HEIGHT     64
#define BUFFER_SIZE     1024

DISP_PAGES:             EQU     8               ; (DISP_HEIGHT / 8)

IDLE:                   EQU     $02             ; SPI bus is idle
RESET:                  EQU     $01             ; Display reset active
COMMAND:                EQU     $06             ; Write command
DATA:                   EQU     $07             ; Write data

;--- SH1106 specific constants
SET_PAGE:               EQU   $B0
SET_START_LINE:         EQU   $40
SET_COL_LOW:            EQU   $02
SET_COL_HIGH:           EQU   $10
SET_DISP_OFF:           EQU   $AE
SET_DISP_ON:            EQU   $AF
SET_DISP_CLK_DIV:       EQU   $D5
SET_MUX_RATIO:          EQU   $A8
SET_DISP_OFFSET:        EQU   $D3
SET_CHARGEPUMP:         EQU   $8D
SET_MEM_ADDR_MODE:      EQU   $20
HORZ_MODE:              EQU   $00
VERTICAL_MODE:          EQU   $01
PAGE_MODE:              EQU   $02
SET_SEG_REMAP_ON:       EQU   $A1
SET_COM_SCAN_DEC:       EQU   $C8
SET_COM_PIN_CFG:        EQU   $DA
SET_CONTRAST:           EQU   $81
SET_PRECHARGE:          EQU   $D9
SET_VCOM_DETECT:        EQU   $DB
SET_ALL_ON_RESUME:      EQU   $A4
SET_NORMAL_DISP:        EQU   $A6
ACTIVATE_SCROLL:        EQU   $2F
DEACTIVATE_SCROLL:      EQU   $2E
