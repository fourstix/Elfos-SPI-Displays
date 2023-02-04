# Elfos-SPI-Displays
Elf/OS programs for an 1802/Mini system with the 1802/Mini SPI adapter board connected to a display on SPI port 0.

Introduction
------------
*TBD: Add introduction and general overview*

**Note: This is an early release of a work in progress.** 
More work needs to be done to add functions to create a common graphics library with routines that can be used by display-specific libraries.

Platform  
--------
The programs were written to run displays from an [1802-Mini](https://github.com/dmadole/1802-Mini) by David Madole running with the [1802/Mini SPI adapter board](https://github.com/arhefner/1802-Mini-SPI-DMA) by Tony Hefner. These programs were assembled and linked with updated versions of the Asm-02 assembler and Link-02 linker by Mike Riley. The updated versions required to assemble and link this code are available at [arhefner/Asm-02](https://github.com/arhefner/Asm-02) and [arhefner/Link-02](https://github.com/arhefner/Link-02).

Supported Displays
------------------
* SH1106 OLED display
* *TBD: ssd1306 display*

Display Programs
----------------

## clear
**Usage:** clear    
Clear the display.

## splash
**Usage:** splash   
Show the Adafruit splash screen on the display.

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
Draws the same line pattern reversed (black on white) on the display.
     
## boxes
**Usage:** reversed
Draws rectangles in a pattern on the display.

Repository Contents
-------------------
* **/src/**  -- Common source files for assembling programs for SPI displays
* **/src/sh1106/**  -- Source files for the SH1106 display programs.
  * sh1106_lib.asm - Library for SH1106 display routines.
  * clear.asm - Clear the display screen
  * splash.asm - Show the Adafruit splash screen on the display.
  * show.asm - Read an show a bitmap graphics image file on the display. 
  * pixiecvt.asm - Conversion routines used to read and display a graphics image.
  * sh1106build.bat - Windows batch file to assemble and link the sh1106 programs.
* **/src/sh1106/include/**  -- Include files for the SH1106 display programs.  
  * sysconfig.inc - System configuration definitions for sh1106 programs.
  * sh1106.inc - SH1106 display value constants.
  * sh1106_lib.inc - External definitions for routines in the sh1106_lib.
  * ops.inc - Opcode definitions for Asm/02.
  * macros.inc - More opcode definitions for Asm/02. *TODO: merge into ops.inc*
  * bios.inc - Bios definitions from Elf/OS
  * kernel.inc - Kernel definitions from Elf/OS
* **/src/gfx_lib/**  -- Source files for the graphics library programs.
  * gfx_lib.asm - Grapics library for SH1106 display.
  * boxes.asm - Demo program to draw rectangles on the display screen
  * splash.asm - Show the Adafruit splash screen on the display.
  * show.asm - Read an show a bitmap graphics image file on the display. 
  * pixiecvt.asm - Conversion routines used to read and display a graphics image.
  * sh1106build.bat - Windows batch file to assemble and link the sh1106 programs.
    
* **/src/gfx_lib/include/**  -- Include files for the graphics display programs. *TODO: merge these include files with the sh1106 include files*
  * sysconfig.inc - System configuration definitions for sh1106 programs.
  * sh1106.inc - SH1106 display value constants.
  * sh1106_lib.inc - External definitions for routines in the sh1106_lib.
  * ops.inc - Opcode definitions for Asm/02.
  * macros.inc - More opcode definitions for Asm/02. *TODO: merge into ops.inc*
  * bios.inc - Bios definitions from Elf/OS
  * kernel.inc - Kernel definitions from Elf/OS
  * gfx_lib.inc - External definitions for the Graphics Library
* **/bin/sh1106/**  -- Binary files for SH1106 display programs.
* **/bin/gfx_lib/**  -- Binary files for graphics library demo programs.
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
