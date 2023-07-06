# swift_huge-numbers

This library was created to remove the decimal precision limitation on floats, which is especially useful in scientific applications.

## Installation
### Requirements
- Swift >= 5.1
- macOS >= 10.15
- iOS >= 13.0
- tvOS >= 13.0
- watchOS >= 6.0
### CocoaPods
```ruby
pod 'HugeNumbers', '~> 1.0.15'
```
or for latest version (may not be uploaded to CocoaPods yet)
```ruby
pod 'HugeNumbers', :git => 'https://github.com/RandomHashTags/swift_huge-numbers.git'
```
### Swift Package Manager
```swift
.package(url: "https://github.com/RandomHashTags/swift_huge-numbers.git", from: "1.0.15")
```

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
The tables below display the nanoseconds longer it took this library to calculate the result than native arithmetic.

\***native calculation overflows; only compared to partial calculation**
#### `HugeInt`
|Version      |Scheme           |Left Number      |Right Number     |Addition         |Subtraction      |Multiplication   |Division         |
|:------------|:---------------:|:---------------:|:---------------:|:---------------:|:---------------:|:---------------:|:---------------:|
|1.0.6        |DEBUG            |8237502387529357 |397653549738     |~2,800           |~2,400           |~43,000\*        |~225,000         |
|1.0.13       |DEBUG            |8237502387529357 |397653549738     |~2,450           |~2,350           |~38,100\*        |~208,700         |
|1.0.14       |RELEASE          |8237502387529357 |397653549738     |~170             |~200             |~3,950\*         |~15,400          |
#### `HugeFloat`
|Version      |Scheme           |Precision        |Left Number      |Right Number     |Addition         |Subtraction      |Multiplication   |Division         |
|:------------|:---------------:|:---------------:|:---------------:|:---------------:|:---------------:|:---------------:|:---------------:|:---------------:|
|1.0.6        |DEBUG            |100              |12345.678        |54321.012        |~8,200           |~8,300           |~24,000          |~13,000,000      |
|1.0.13       |DEBUG            |6                |12345.678        |54321.012        |~8,000           |~8,300           |~22,000          |~410,000         |
|1.0.13       |DEBUG            |100              |12345.678        |54321.012        |-                |-                |-                |~9,306,000       |
|1.0.14       |RELEASE          |6                |12345.678        |54321.012        |~790             |~1,080           |~3,300           |~39,500          |
|1.0.14       |RELEASE          |100              |12345.678        |54321.012        |-                |-                |-                |~660,000         |

## Contributing
Adding/improving functionality is always welcome, just make a PR.

## Funding
Support the development of this project by sponsoring the developers.
- [RandomHashTags](https://github.com/sponsors/RandomHashTags)

## License
Public Domain. Creative Commons Zero v1.0 Universal.
