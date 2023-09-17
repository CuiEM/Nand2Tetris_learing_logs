# 第二章：布尔运算

## 0.0 目的

构建并仿真 projects/02 目录里面的所有芯片

## 0.1 提示

* 加法器的实现还是建立在第一章构建的芯片逻辑基础之上，并不难。

## 一、半加器（Half-adder）

| a | b | carry | sum | a And b | a Xor b |
|:---:|:---:|:-------:|:-----:|:---------:|:---------:|
| 0 | 0 | 0     | 0   | 0       | 0       |
| 0 | 1 | 0     | 1   | 0       | 1       |
| 1 | 0 | 0     | 1   | 0       | 1       |
| 1 | 1 | 1     | 0   | 1       | 0       |

从表中可得，我们可以轻易的得到 carry 和 sum 如何使用第一章的逻辑实现。所以：

```verilog
PARTS:
// Put you code here:
And(a=a, b=b, out=carry);
Xor(a=a, b=b, out=sum);
```

## 二、全加器（Full-adder）

在 2-位二进制数加法 的基础上进一步演变为 3-位二进制数加法，其实只需要逐个相加，然后对所有的进位（carry）相加即可

```verilog
Parts
// Put you code here:
HalfAdder(a=a, b=b, sum=sum1, carry=carry1);
HalfAdder(a=sum1, b=c, sum=sum, carry=carry2);
Or(a=carry1, b=carry2, out=carry);
```

注意：经过统计，在任何情况下都不会出现 $carry1$ 和 $carry2$ 均为1的情况，所以只需要保证 $0+1=1$ 即可，而不必考虑 $1+1=？$所以在这里

```verilog
Or(a=carry1, b=carry2, out=carry);
```

其实是可以换成

```verilog
Xor(a=carry1, b=carry2, out=carry);
```

两者实现的效果是一样的，均能跑成功！

## 三、加法器（Adder）

同理可得，对第一位取半加法器，接下来所有都取全加法器。

## 四、增量器（incrementer）

这个电路的目的是“对指定数字加一”。其实就是把 Add16 里的输入变量 $b$ 固定为1即可。

* 注意在这里不能用 1 或者 0 像这样：

```verilog
HalfAdder(a=in[0], b=1, sum=out[0], carry=carry0);
FullAdder(a=in[1], b=0, c=carry0, sum=out[1], carry=carry1);
...
```

* 正确的做法应该是把 0 换位 false, 把 1 换为 true。否则在加载芯片的过程中报错 “A pin name is expected"。如下：

```verilog
HalfAdder(a=in[0], b=true, sum=out[0], carry=carry0);
FullAdder(a=in[1], b=false, c=carry0, sum=out[1], carry=carry1);
...
```

## 五、算术逻辑单元（ALU）

ALU 通过六个 **控制位** 来控制对两个输入变量执行什么函数操作，六个控制位都是一位二进制数，不同的组合实现不同的函数效果，所以总计有 $2^6=64$ 种函数，但实际上有一些会重复，书里只列出了18种的函数表。

具体的实现比较复杂，我们可以一步步来：

1. 我们先根据 zx,nx,zy,ny 来判断在执行 f 之前的输入是什么，考虑到 zx 和 zy，nx 和 ny 分别对 x 和 y 执行的效果是一样的，注意在这里其实是有先后顺序的，应该先执行 zx 再执行 nx。我们先看 x

```verilog
// if (zx==1) set x = 0        // 16-bit constant
Mux16(a=x, b=false, sel=zx, out=x1);

// if (nx==1) set x = ~x       // bitwise "not"
Not16(in=x1, out=x2);   
Mux16(a=x1, b=x2, sel=nx, out=x3);
```

同理可得我们也可以写出 y 的输入变化过程

2. 接下来是决定 f 是 + 还是 And

```verilog
// if (f==0)  set out = x & y  // bitwise "and"
And16(a=x3, b=y3, out=out1);

// if (f==1)  set out = x + y  // integer 2's complement addition
Add16(a=x3, b=y3, out=out2);

// 根据 f 的值判断 out 取那个
Mux16(a=out1, b=out2, sel=f, out=out3);
```

3. 然后根据 no 判断对 out 要不要取反

```verilog
// if (no==1) set out = ~out   // bitwise "not"
Not16(in=out3, out=out4);
Mux16(a=out3, b=out4, sel=no, out=out5);
```

4. 最后我们要得到 zr 和 ng 的值，我们先写出 zr 的输出过程判断是不是 0，我们可以通过执行 Or 的多通道来实现，但是我们这里的输入是16位的，所以第一种方法是将 out[16] 拆分为 out[0..7] 和 out[8..15] 分别通过 Or8Way 再对两个输出判断

```verilog
Or8Way(in=out5[0..7], out=zr1);
Or8Way(in=out5[8..15], out=zr2);
Or(a=zr1, b=zr2, out=zr);
```

第二种方法是直接编写一个 Or16Way 的实现芯片，原理同 Or8Way。具体代码已放在同一个目录下。写完之后，直接调用即可。

```verilog
Or16Way(in=out5, out=zr1);
Not(in=zr1, out=zr);
```

5. 现在来实现 ng 的输出，判断一个数是不是负数，只需看它的二进制编码开头是不是 1 即可。但是很奇怪 hdl 不允许如下写，它不支持直接调用一位数字如下所示

```verilog
And(a=out5[15], b=true, out=ng);
```

所以我们和上面一样，写一个新的判断是不是负数的芯片，取名为 Neg.hdl，然后直接调用即可。

```verilog
 CHIP Neg {

    IN in[16];
    OUT out;

    PARTS:
    And(a = in[15], b = true, out = out);
}
```
