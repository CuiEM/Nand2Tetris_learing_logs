// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input. 
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel. When no key is pressed, the
// program clears the screen, i.e. writes "white" in every pixel.

// Put your code here.

@8192
D=A
@size
M=D

(BEGINBLACKING)

@i
M=0                    // i = 0

(BLACKING)             // 开始正式涂黑

@KBD
D=M                    // D = KBD 检测键盘是否有输入

@BEGINCLEANING
D;JEQ                  // 键盘无输入，跳转到 CLEANING

@size
D=M                    // D = size

@i
D=D-M                  // D = size - i

@BLACKING
D;JEQ                  // 如果 size = i，跳转到 BLACKING

@SCREEN
D=A                    // 定位到屏幕第一个像素值

@i
A=D+M                  // SCREEN上的地址 = SCREEN + i
M=-1                   // 涂黑

@i
M=M+1                  // 循环加1

@BLACKING
0;JMP

(BEGINCLEANING)

@i
M=0

(CLEANING)
@KBD
D=M

@BEGINBLACKING
D;JNE

@i
D=M

@size
D=D-M

@CLEANING
D;JEQ

@SCREEN
D=A

@i
A=D+M
M=0

@i
M=M+1

@CLEANING
0;JMP
