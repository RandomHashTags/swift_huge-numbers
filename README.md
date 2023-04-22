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

## Contributing
Adding/improving functionality is always welcome, just make a PR.

## License
Public Domain. Creative Commons Zero v1.0 Universal.
