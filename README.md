# swift_huge-numbers

This library was created to remove the decimal precision limitation on floats, which is especially useful in scientific applications.

## Current features
- `HugeInt`
- `HugeFloat`
- `HugeRemainder`
- `HugeDecimal`
- addition, subtraction, multiplication, and division
- special arithmetic
  - percent (mod/remainder)
  - factorial
  - factors & shared factors
  - fraction simplification
  - square root (n)
- infinite precision

## Current limitations
- cannot apply arithmetic to a `HugeFloat` with a `HugeDecimal` and another with a `HugeRemainder`, or vice versa
- limited special arithmetic
  - no trigonometry, pi, square root remainder, log
  
## Performance
### Device
iMac19,1 - macOS 13.3.1 - Xcode 14.3 - Swift 5.8 - 1.47 TB free of 2TB - 3.6 GHz 8-Core i9 - 72 GB 2667 MHz DDR4 RAM

**benchmark calculator located in `huge_numbersTests`**
### Compared to native
The table below displays the nanoseconds longer it took this library to calculate the result than native arithmetic.

\***native calculation overflows; only compared to partial calculatation**
|Version      |Unit             |Left Number      |Right Number     |Addition         |Subtraction      |Multiplication   |Division         |
|:------------|:---------------:|:---------------:|:---------------:|:---------------:|:---------------:|:---------------:|:---------------:|
|1.0.6        |`HugeInt`        |8237502387529357 |397653549738     |~2,800           |~2,400           |~43,000\*        |~225,000         |
|1.0.6        |`HugeFloat`      |12345.678        |54321.012        |~8,200           |~8,300           |~24,000          |~13,000,000      |

## Contributing
Adding/improving functionality is always welcome, just make a PR.

## License
Public Domain. Creative Commons Zero v1.0 Universal.
