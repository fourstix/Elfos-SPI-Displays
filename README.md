# Elfos-SPI-Displays
Elf/OS programs for an 1802/Mini system with the 1802/Mini SPI adapter board connected to a display on SPI port 0.

Introduction
------------
This repository contains 1802 Assembler code for an SH1106 display driver and a graphics library.  The display driver and graphics library are based on Adafruit's [Adafruit_GFX-Library](https://github.com/adafruit/Adafruit-GFX-Library) written by Ladyada Limor Fried and on the [Fast SH1106 Library](https://forum.arduino.cc/t/a-fast-sh1106-library-128x64-oled/236309) written by Arthur Liberman. 

These programs use a display specific library sh1106_oled.lib.  The graphics demo programs also use a common graphics library gfx_oled.lib.

Platform  
--------
The programs were written to run displays from an [1802-Mini](https://github.com/dmadole/1802-Mini) by David Madole running with the [1802/Mini SPI adapter board](https://github.com/arhefner/1802-Mini-SPI-DMA) by Tony Hefner. These programs were assembled and linked with updated versions of the Asm-02 assembler and Link-02 linker by Mike Riley. The updated versions required to assemble and link this code are available at [arhefner/Asm-02](https://github.com/arhefner/Asm-02) and [arhefner/Link-02](https://github.com/arhefner/Link-02).

Supported Displays
------------------
* SH1106 OLED display
* *TBD: ssd1306 display*

Display Library API
---------------------

## Public API List

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

Graphics Library API
---------------------

## Public API List

* clear_buffer - clear all bits in the display buffer.
* fill_buffer  - set all bits in the display buffer.
* draw_pixel   - set a pixel at a particular x0,y0 co-ordinates.
* clear_pixel  - clear a pixel at a particular x0,y0 co-ordinates.
* draw_line    - set pixels to form a line from x0,y0 to x1,y1
* clear_line   - clear pixels to form a line from x0,y0 to x1,y1 
* draw_rect    - set pixels to form a rectangle with its upper left corner at x0,y0 with width w and height h.
* clear_rect   - clear pixels to form a rectangle with its upper left corner at x0,y0 with width w and height h.
* draw_block   - set pixels to form a filled rectangle with its upper left corner at x0,y0 with width w and height h.
* clear_block  - clear pixels to form a rectangle with its upper left corner at x0,y0 with width w and height h.
* draw_bitmap  - set pixels to draw a bitmap of width w and height h with its upper left corner at x0,y0.
* clear_bitmap - clear pixels to erase a bitmap of width w and height h with its upper left corner at x0,y0.
* draw_char    - draw a character at x0,y0
* draw_string  - draw a null-terminated string at x0,y0


## API Notes:
* rf = pointer to display buffer for all API
* r7.1 = origin y (row value, 0 to 63)
* r7.0 = origin x (column value, 0 to 127)
* r8.1 = endpoint y, or height
* r8.0 = endpoint x, or width
* r8 = pointer to null-terminated string
* r9.1 = background for characters, GFX_ BG_TRANSPARENT OR GFX_OPAQUE
* r9.0 = ASCII character to draw


<table>
<tr><th rowspan="2">API Name</th><th colspan="2">R7</th><th colspan="2">R8</th><th rowspan="2" colspan="2">Notes</th></tr>
<tr><th>R7.1</th><th>R7.0</th><th>R8.1</th><th>R8.0</th></tr>
<tr><td>clear_buffer</td><td colspan="2"> - </td><td colspan="2"> - </td><td colspan="2">rf = pointer to display buffer for all API</td></tr>
<tr><td>fill_buffer</td><td colspan="2"> - </td><td colspan="2"> - </td><td colspan="2">rf = pointer to display buffer for all API</td></tr>
<tr><td>draw_pixel</td><td>y</td><td>x</td><td colspan="2"> - </td><td colspan="2">Checks x,y values, returns error (DF = 1) if out of bounds</td></tr>
<tr><td>clear_pixel</td><td>y</td><td>x</td><td colspan="2"> - </td><td colspan="2">Checks x,y values, returns error (DF = 1) if out of bounds</td></tr>
<tr><td>draw_line</td><td>origin y</td><td> origin x</td><td>endpoint y</td><td>endpoint x</td><td colspan="2">Checks x,y values, returns error (DF = 1) if out of bounds</td></tr>
<tr><td>clear_line</td><td>origin y</td><td> origin x</td><td>endpoint y</td><td>endpoint x</td><td colspan="2">Checks x,y values, returns error (DF = 1) if out of bounds</td></tr>
<tr><td>draw_rect</td><td>origin y</td><td> origin x</td><td>height</td><td>width</td><td colspan="2">Checks origin x,y values, returns error (DF = 1) if out of bounds. The w and h values may be clipped to edge of display.</td></tr>
<tr><td>clear_rect</td><td>origin y</td><td> origin x</td><td>height</td><td>width</td><td colspan="2">Checks origin x,y values, returns error (DF = 1) if out of bounds. The w and h values may be clipped to edge of display.</td></tr>
<tr><td>draw_block</td><td>origin y</td><td> origin x</td><td>height</td><td>width</td><td colspan="2">Checks origin x,y values, returns error (DF = 1) if out of bounds. The w and h values may be clipped to edge of display.</td></tr>
<tr><td>clear_block</td><td>origin y</td><td> origin x</td><td>height</td><td>width</td><td colspan="2">Checks origin x,y values, returns error (DF = 1) if out of bounds. The w and h values may be clipped to edge of display.</td></tr>
<tr><td>draw_bitmap</td><td>origin y</td><td> origin x</td><td>height</td><td>width</td><td colspan="2">Checks origin x,y values, returns error (DF = 1) if out of bounds. The w and h values may be clipped to edge of display.</td></tr>
<tr><td>clear_bitmap</td><td>origin y</td><td> origin x</td><td>height</td><td>width</td><td colspan="2">Checks origin x,y values, returns error (DF = 1) if out of bounds. The w and h values may be clipped to edge of display.</td></tr>
<tr><th rowspan="3">API Name</th><th colspan="2">R7</th><th colspan="2">R8</th><th colspan="2">R9</th></tr>
<tr></th><th>R7.1</th><th>R7.0</th><th colspan="2"> </th><th>R9.1</th><th>R9.0</th></tr>

<tr><th colspan="6">Notes</th></tr>
<tr><td rowspan="2">draw_char</td><td>origin y</td><td>origin x</td><th colspan="2">-</th><td>background</td><td>character</td></tr>
<tr><td colspan="6">Checks origin x,y values, returns error (DF = 1) if out of bounds.<br>Checks ASCII character value, draws DEL (127) if non-printable.<br> Return: r7 points to next character position (text wraps).</td></tr>
<tr><td rowspan="2">draw_string</td><td>origin y</td><td> origin x</td><td colspan="2">r8 - Pointer to null terminated ASCII string.</td><td>background</td><td>-</td></tr>
<tr><td colspan="6">Checks origin x,y values, returns error (DF = 1) if out of bounds. <br>Checks ASCII character value, draws DEL (127) if non-printable.<br> Return: registers r8 and r9 are consumed.</td></tr>
</table>

Display Programs
----------------

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
 
Graphics Library Demos
----------------------
 
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


Repository Contents
-------------------
* **/src/**  -- Source files for demo programs for SPI displays
  * clear.asm - Clear the display screen
  * splash.asm - Show the Adafruit splash screen on the display.
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
* **/src/include/**  -- Include files for the SH1106 display programs and the libraries.  
  * sysconfig.inc - System configuration definitions for sh1106 programs.
  * sh1106.inc - SH1106 display value constants.
  * sh1106_lib.inc - External definitions for routines in the SH1106 display library sh1106_oled.lib.
  * gfx_lib.inc - External definitions for the Graphics OLED Library gfx_oled.lib.
  * ops.inc - Opcode definitions for Asm/02.
  * bios.inc - Bios definitions from Elf/OS
  * kernel.inc - Kernel definitions from Elf/OS
* **/src/lib/**  -- Library files for the SH1106 display programs and OLED graphics demos.
  * gfx_oled.lib - Assembled Graphics OLED library. The source files for library functions are in the */src/gfx/* directory.
  * sh1106_oled.lib - Assembled SH1106 OLED display library. The source files for the library functions are in the */src/sh1106/* directory.
* **/src/sh1106/**  -- Source files for the SH1106 OLED display library.
  * *.asm - Assembly source files for library functions.
  * build.bat - Windows batch file to assemble and create the sh1106_oled graphics library. Replace [Your_Path] with the correct path information for your system. 
  * clean.bat - Windows batch file to delete the sh1106_oled library and its associated files.    
* **/src/gfx/**  -- Source files for the Graphics OLED library.
  * *.asm - Assembly source files for library functions.
  * build.bat - Windows batch file to assemble and create the gfx_oled graphics library. Replace [Your_Path] with the correct path information for your system. 
  * clean.bat - Windows batch file to delete the gfx_oled library and its associated files.    
* **/bin/**  -- Binary files for SH1106 display programs.
* **/lbr/**  -- Elf/OS library file with SH1106 OLED display programs.
  * sh1106_oled.lbr - Extract the program files with the Elf/OS command *lbr e sh1106_oled*
* **/docs/**  -- Documentation for various displays
* **/docs/sh1106/**  - Documentation files for the SH1106 display.
  * 1.3inch-SH1106-OLED.pdf - 1.3" SH1106 OLED Users Guide.
  * sh1106_datasheet.pdf - SH1106 Display Datasheet
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
