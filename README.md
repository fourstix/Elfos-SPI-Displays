# Elfos-SPI-Displays
Elf/OS programs for an 1802/Mini system with the 1802/Mini SPI adapter board connected to a display on SPI port 0.

Introduction
------------
This repository contains 1802 Assembler code for OLED and GLCD display demo programs. 

The ST7920 GLCD display programs were based on code from the [ST7920_GFX library](https://github.com/BornaBiro/ST7920_GFX_Library) written by Borna Bira and Adafruit's [Adafruit_GFX-Library](https://github.com/adafruit/Adafruit-GFX-Library) written by Ladyada Limor Fried.

The SH1106 OLED display programs use a display library and a graphics library.  The display library and graphics library are based on Adafruit's [Adafruit_GFX-Library](https://github.com/adafruit/Adafruit-GFX-Library) written by Ladyada Limor Fried and on the [Fast SH1106 Library](https://forum.arduino.cc/t/a-fast-sh1106-library-128x64-oled/236309) written by Arthur Liberman.

The OLED programs use a display specific library sh1106_oled.lib.  The graphics demo programs also use a common graphics library gfx_oled.lib.  The source code for the Elf/OS OLED graphics library is available on GitHub in the [Elfos-Gfx-OLED-Library](https://github.com/fourstix/Elfos-Gfx-OLED-Library).

Platform  
--------
The programs were written to run displays from an [1802-Mini](https://github.com/dmadole/1802-Mini) by David Madole running with the [1802/Mini SPI adapter board](https://github.com/arhefner/1802-Mini-SPI-DMA) by Tony Hefner. These programs were assembled and linked with updated versions of the Asm-02 assembler and Link-02 linker by Mike Riley. The updated versions required to assemble and link this code are available at [arhefner/Asm-02](https://github.com/arhefner/Asm-02) and [arhefner/Link-02](https://github.com/arhefner/Link-02).

Supported Displays
------------------
* SH1106 OLED display
* ST7920 GLCD display

GLCD Display Programs
---------------------

## glcd_clear
**Usage:** clear    
Clear the display.

## glcd_ship
**Usage:** spaceship   
Show the classic Elf spaceship program graphic on the display.

## glcd_pixels
**Usage:** pixels    
Draws a simple pixel pattern on the display.
 
## glcd_lines
**Usage:** lines   
Draws a simple line pattern on the display.


OLED Display Library API
------------------------

## OLED Public API List

* init_oled  - initialize the OLED display 
* clear_oled - clear the OLED dispay
* show_oled  - show the contents of a memory buffer on the display
* position_oled - position the display's memory cursor at the byte corresponding to x,y 
* send_oled - send a single byte directly to the display memory
* write_oled - write a buffer of a number of bytes directly to the display memory

<table>
<tr><th>Name</th><th>Description</th><th colspan="2">Parameters</th></tr>
<tr><td>init_oled</td><td>Initialize the display</td><td colspan="2">(None)</td></tr>
<tr><td>clear_oled</td><td>Clear the display</td><td colspan="2">(None)</td></tr>
<tr><td>show_oled</td><td>Update the display</td><td colspan="2">rf - Pointer to 1K byte buffer</td></tr>
<tr><td rowspan="2">position_oled</td><td rowspan="2">Position the display Memory Cursor</td><td colspan="2">r7.1 - y position (0 to 63)</td></tr>
<tr><td>r7.0 - x position (0 to 127)</td></tr>
<tr><td>send_oled</td><td>Send a single byte to the display memory</td><td colspan="2">D - byte to send</td></tr>
<tr><td rowspan="2">write_oled</td><td rowspan="2">Write a number of bytes directly to the display memory</td><td colspan="2">rf - pointer to buffer with bytes.</td></tr>
<tr><td>r8 - count of bytes to write</td></tr>            
</table>

OLED Display Programs
---------------------

## clear
**Usage:** clear    
Clear the display.

## splash
**Usage:** splash   
Show the Adafruit splash screen on the display.

## spaceship
**Usage:** spaceship   
Show the classic Elf spaceship program graphic on the display.

## show
**Usage:** show *filename*   
 Display a bitmap from a file named *filename* on the display. The file should be exactly 1024 bytes and in the native OLED format. A couple of example images are in the test/images folder. 
 
OLED Graphics Library Demos
---------------------------
 
## pixels
**Usage:** pixels    
Draws a simple pixel pattern on the display.
 
## linetest
**Usage:** linetest   
Draws various lines on the display.
 
## lines
**Usage:** lines   
Draws a simple line pattern on the display.
  
## reversed
**Usage:** reversed  
Draws a line pattern reversed (black on white) on the display.
     
## boxes
**Usage:** boxes  
Draws rectangles in a pattern on the display.

## blocks
**Usage:** blocks  
Draws filled rectangles in a pattern on the display.

## bitmaps
**Usage:** bitmaps  
Draws Adafruit bitmaps on the display.

## snowflakes
**Usage:** snowflakes  
Draws falling snowflake bitmaps on the display.

## charset
**Usage:** charset  
Draws the printable ASCII character set on the display.

## helloworld
**Usage:** helloworld  
Draws the classic text greeting on the display.

## textbg
**Usage:** textbg  
Draws text strings on the display, using the transparent and opaque background options.

## direct
**Usage:** direct  
Draw patterns by directly writing to bytes to the display.


SPI Card Pinout
---------------
The following pinout is used to connect the Elf/OS SPI Adapter board to the OLED displays.

<table>
<tr ><td colspan="4"><img src="https://github.com/fourstix/Elfos-SPI-Displays/blob/b_update/docs/spi/1802-Mini-SPI-Connector.jpg"></td></tr>
<tr><th>Pin</th><th>Function</th><th>Wire Color</th><th>Notes</th></tr>
<tr><td>1</td><td rowspan="2">VCC</td><td rowspan="2">Red</td><td rowspan="2">+5V</td></tr>
<tr><td>2</td></tr>
<tr><td>3</td><td>MISO</td><td>Orange</td><td>(Not Used)</td></tr>
<tr><td>4</td><td>MOSI</td><td>Yellow</td><td>Serial Data Out</td></tr>
<tr><td>5</td><td>CS</td><td>Green</td><td>Chip Select</td></tr>
<tr><td>6</td><td>SCK</td><td>Blue</td><td>Serial Clock</td></tr>
<tr><td>7</td><td>DC</td><td>Violet</td><td>Data/Command</td></tr>
<tr><td>8</td><td>RES</td><td>Grey</td><td>Reset</td></tr>
<tr><td>9</td><td rowspan="2">GND</td><td rowspan="2">Black</td><td rowspan="2">Ground</td></tr>
<tr><td>10</td></tr>
</table>

SH1106 OLED Display Pinout
--------------------------
The following wiring is used to connect the Elf/OS SPI Adapter board to the SH1106 OLED display.

<table>
<tr ><td colspan="4"><img src="https://github.com/fourstix/Elfos-SPI-Displays/blob/b_update/docs/sh1106/SH1106_Wiring.jpg"></td></tr>
<tr><th>OLED Pin</th><th>Wire Color</th><th>Function</th><th>SPI Pin</th></tr>
<tr><td>GND</td><td>Black</td><td>Ground</td><td>10</td></tr>
<tr><td>VCC</td><td>Red</td><td>+5V</td><td>2</td></tr>
<tr><td>CLK</td><td>Blue</td><td>Serial Clock</td><td>6</td></tr>
<tr><td>MOSI</td><td>Yellow</td><td>Serial Data</td><td>4</td></tr>
<tr><td>RES</td><td>Grey</td><td>Reset</td><td>8</td></tr>
<tr><td>SDC</td><td>Violet</td><td>Data/Command</td><td>7</td></tr>
<tr><td>CCS</td><td>Green</td><td>Chip Select</td><td>5</td></tr>
</table>

ST7920 GLCD Display Pinout
--------------------------
The following wiring is used to connect the Elf/OS SPI Adapter board to the ST7920 GLCD display.

<table>
<tr ><td colspan="4"><img src="https://github.com/fourstix/Elfos-SPI-Displays/blob/b_update/docs/st7920/ST7920_Wiring.jpg"></td></tr>
<tr><th>GLCD</th><th>Pin</th><th>Wire Color</th><th>Function</th><th>SPI Pin</th></tr>
<tr><td>GND</td><td>1</td><td>Black</td><td>Ground</td><td>10</td></tr>
<tr><td>VCC</td><td>2</td><td colspan="2">External +5V (See Note 1)</td><td>N.C.</td></tr>
<tr><td>Vo</td><td>3</td><td colspan="2">Contrast (See Note 2)</td><td>N.C.</td></tr>
<tr><td>RS</td><td>4</td><td>Violet</td><td>Register Select</td><td>7</td></tr>
<tr><td>RW(SDI)</td><td>5</td><td>Yellow</td><td>Serial Data</td><td>4</td></tr>
<tr><td>E</td><td>6</td><td>Blue</td><td>Serial Clock</td><td>6</td></tr>
<tr><td>PSB</td><td>15</td><td>Green</td><td>Interface Select</td><td>5</td></tr>
<tr><td>RST</td><td>17</td><td>Grey</td><td>Reset</td><td>8</td></tr>
<tr><td>BLA</td><td>19</td><td colspan="2">Backlight Anode, External +5V (See Note 1)</td><td>N.C.</td></tr>
<tr><td>BLK</td><td>20</td><td>Black</td><td>Backlight Cathode (GND)</td><td>10</td></tr>
</table>

##Notes:
  1. The ST7920 GLCD display with a backlight can draw a lot of power, so an external 5v power source was used for the display shown. Be sure to connect the power source ground with the signal ground, but do not connect the 5v lines together.
  2. The contrast voltage is already configured on some displays and pin 3 is not connected like the display shown in the picture. On other displays, connect a 10K ohm potentiometer between +5v and GND and connect Vo to the wiper (middle) connection.  Adjust the potentiometer for the Vo voltage on pin 3 that gives the best display contrast.  Some displays also have a potentiometer on the back that can be adjust Vo.
  
Repository Contents
-------------------
* **/src/glcd/**  -- Source files for demo programs for SPI GLCD display
  * glcd_clear.asm - Clear the display screen
  * glcd_ship.asm - Show the classic Elf spaceship program graphic on the display.
  * glcd_pixels.asm - Demo program to draw a simple pattern with pixels on the display screen.
  * glcd_lines.asm - Demo program to draw lines in a pattern on the display screen.
* **/src/glcd/include/**  -- Include files for the ST7920 GLCD display programs   
* **/src/oled/**  -- Source files for demo programs for SPI OLED displays
  * clear.asm - Clear the display screen
  * splash.asm - Show the Adafruit splash screen on the display.
  * spaceship.asm - Show the classic Elf spaceship program graphic on the display.
  * show.asm - Read an show a bitmap graphics image file on the display. 
  * pixiecvt.asm - Conversion routines used to read and display a graphics image.
  * bitmaps.asm - Demo program to draw Adafruit flower bitmaps on the display screen.
  * blocks.asm - Demo program to draw filled rectangles on the display screen. 
  * boxes.asm - Demo program to draw rectangles on the display screen.
  * lines.asm - Demo program to draw lines in a pattern on the display screen.
  * linetest.asm - Demo program to draw various lines on the display screen. 
  * pixels.asm - Demo program to draw a simple pattern with pixels on the display screen.
  * reversed.asm - Demo program to draw lines in a reversed pattern (black on white) on the display screen.
  * snowflakes.asm - Demo program to draw falling snowflake bitmaps on the display screen.
  * charset.asm - Demo program to draw the printable ASCII character set on the display screen.
  * helloworld.asm - Demo program to draw the classic greeting on the display screen.
  * textbg.asm - Demo program to draw text with transparent and opaque background options on the display screen.
  * direct.asm - Demo program to directly write pattern bytes to the display.
  * build.bat - Windows batch file to assemble and link the sh1106 programs. Replace [Your_Path] with the correct path information for your system.
  * clean.bat - Windows batch file to delete assembled binaries and their associated files.
* **/src/oled/include/**  -- Include files for the SH1106 display programs and the libraries.  
  * sysconfig.inc - System configuration definitions for sh1106 programs.
  * sh1106.inc - SH1106 display value constants.
  * sh1106_lib.inc - External definitions for routines in the SH1106 display library sh1106_oled.lib.
  * gfx_lib.inc - External definitions for the Graphics OLED Library gfx_oled.lib.
  * ops.inc - Opcode definitions for Asm/02.
  * bios.inc - Bios definitions from Elf/OS
  * kernel.inc - Kernel definitions from Elf/OS
* **/src/oled/lib/**  -- Library files for the SH1106 display programs and OLED graphics demos.
  * gfx_oled.lib - Assembled Graphics OLED library. The source files for library functions are in the */src/gfx/* directory.
  * sh1106_oled.lib - Assembled SH1106 OLED display library. The source files for the library functions are in the */src/sh1106/* directory.
* **/src/oled/sh1106/**  -- Source files for the SH1106 OLED display library.
  * *.asm - Assembly source files for library functions.
  * build.bat - Windows batch file to assemble and create the sh1106_oled graphics library. Replace [Your_Path] with the correct path information for your system. 
  * clean.bat - Windows batch file to delete the sh1106_oled library and its associated files. 
* **/bin/glcd/**  -- Binary files for ST7920 GLCD display programs.
* **/bin/oled/**  -- Binary files for SH1106 OLED display programs.
* **/lbr/**  -- Elf/OS library files with GLCD or OLED display programs.
  * sh1106_oled.lbr - Extract the program files with the Elf/OS command *lbr e sh1106_oled*
  * st7920_glcd.lbr - Extract the program files with the Elf/OS command *lbr e st7920_glcd*
* **/docs/**  -- Documentation for various displays
* **/docs/sh1106/**  - Documentation files for the SH1106 display.
  * 1.3inch-SH1106-OLED.pdf - 1.3" SH1106 OLED Users Guide.
  * sh1106_datasheet.pdf - SH1106 Display Datasheet
* **/docs/st7920/**  - Documentation files for the ST7920 GLCD display.
    * st7920.pdf - Sitronix ST7920 GLCD Users Guide.
* **/test/images/** -- Test graphic image files for the show program.
  * imp.img - Test graphic file image of an imp.
  * hres.img - Test graphic file image of a spaceship.
  
License Information
-------------------

This code is public domain under the MIT License, but please buy me a beverage
if you use this and we meet someday (Beerware).

References to any products, programs or services do not imply
that they will be available in all countries in which their respective owner operates.

Adafruit, the Adafruit logo, and other Adafruit products and services are
trademarks of the Adafruit Industries, in the United States, other countries or both. 

Any company, product, or services names may be trademarks or services marks of others.

All libraries used in this code are copyright their respective authors.

This code is based on code written by Tony Hefner and assembled with the Asm/02 assembler and Link/02 linker written by Mike Riley.

Elf/OS  
Copyright (c) 2004-2023 by Mike Riley

Asm/02 1802 Assembler  
Copyright (c) 2004-2023 by Mike Riley

Link/02 1802 Linker  
Copyright (c) 2004-2023 by Mike Riley

The Adafruit_SH1106 Library  
Copyright (c) 2012-2023 by Adafruit Industries   
Written by Limor Fried/Ladyada for Adafruit Industries. 

The Adafruit_GFX Library  
Copyright (c) 2012-2023 by Adafruit Industries   
Written by Limor Fried/Ladyada for Adafruit Industries. 

The Fast SH1106 Arduino Library  
Copyright (c) 2013 by Arthur Liberman (ALCPU) 

The ST7920_GFX library
Copyright 2018 by Borna Bira

The 1802/Mini SPI Adapter Board   
Copyright (c) 2022-2023 by Tony Hefner

The 1802-Mini Microcomputer Hardware   
Copyright (c) 2020-2023 by David Madole

Many thanks to the original authors for making their designs and code available as open source.
 
This code, firmware, and software is released under the [MIT License](http://opensource.org/licenses/MIT).

The MIT License (MIT)

Copyright (c) 2023 by Gaston Williams

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

**THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.**
