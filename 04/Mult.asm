// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[3], respectively.)

// Put your code here.

@i
M=0           //i=0

@R2
M=0           //R2=0

(LOOP)

@i
D=M           //D=i

@R0
D=D-M         //D=i-R0

@END
D;JEQ         //if D=0 即 i=R0, jump to END, 即跳出循环

@R1
D=M           //D=R1

@R2
M=M+D         //R2=R2+R1

@i
M=M+1         //i=i+1

@LOOP
0;JMP         //jump to LOOP, 返回循环

(END)

@END
0;JMP         //无限循环，程序结束