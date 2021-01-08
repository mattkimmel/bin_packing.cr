# bin_packing

This is a quick Crystal port of https://github.com/mak-it/bin_packing, a Ruby implementation of the [Maximal Rectangles Algorithm](http://clb.demon.fi/files/RectangleBinPack.pdf). (If anyone has an English translation of that paper, please let me know!)

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     bin_packing:
       github: mattkimmel/bin_packing.cr
   ```

2. Run `shards install`

## Usage

Add boxes to bin in given order:
```crystal
require "bin_packing"

bin = BinPacking::Bin.new(100, 50)
boxes = [
  BinPacking::Box.new(50, 50),
  BinPacking::Box.new(10, 40),
  BinPacking::Box.new(50, 44)
]
remaining_boxes = [] of BinPacking::Box

boxes.each do |box|
  remaining_boxes << box unless bin.insert(box)
end

bin.boxes.size
 => 2
bin.boxes[1].x
 => 50
bin.boxes[1].y
 => 0
bin.boxes[1].packed?
 => true
bin.efficiency # in percent
 => 58.0
remaining_boxes.size
 => 1
```

Add boxes to one or multiple bins in best-fitting order:
```crystal
bin_1 = BinPacking::Bin.new(100, 50)
bin_2 = BinPacking::Bin.new(50, 50)
boxes = [
  BinPacking::Box.new(15, 10), # Should be added last (smaller)
  BinPacking::Box.new(50, 45), # Fits in bin_2 better than in bin_1
  BinPacking::Box.new(40, 40),
  BinPacking::Box.new(200, 200) # Too large to fit
]

packer = BinPacking::Packer.new([bin_1, bin_2])
packed_boxes = packer.pack(boxes)

packed_boxes.size
 => 3
bin_1.boxes.size
 => 2
bin_1.boxes[0].label
 => "40x40 at [0,0]"
bin_1.boxes[1].label
 => "15x10 at [0,40]"
bin_2.boxes.size
 => 1
bin_2.boxes[0].label
 => "50x45 at [0,0]"
boxes.last.packed?
 => false
```

Specify heuristic for box arrangement in bin:
```crystal
bin = BinPacking::Bin.new(100, 50, BinPacking::Heuristics::BestAreaFit.new)
bin.insert(BinPacking::Box.new(50, 100))
=> true
```
Following heuristics are available:
* BestAreaFit - least remaining area
* BestLongSideFit - least remaining side length (worst of both dimensions is more important)
* BestShortSideFit - least remaining side length (best of both dimensions is more important) - __default__
* BottomLeft - most tallest box is taken

Add boxes with specific, previously known location:

```crystal
bin = BinPacking::Bin.new(100, 50)

box = BinPacking::Box.new(40, 40)
box.x = 20
box.y = 10

bin.insert_in_known_position(box)
```

Add custom data to bins and boxes using inheritance:
```crystal
class Record
  property id : Int64
  property width : Int64
  property height : Int64

  def initialize(@id, @width, @height)
  end
end

class BinWithRecord < BinPacking::Bin
  getter record : Record

  def initialize(@record)
    super(record.width, record.height)
    @record = record
  end
end

class BoxWithColor < BinPacking::Box
  getter color : String

  def initialize(width, height, @color)
    super(width, height)
    @color = color
  end
end

rec = Record.new(321_i64, 100_i64, 200_i64)
bin = BinWithRecord.new(rec)
box = BoxWithColor.new(70_i64, 80_i64, "silver")
bin.insert(box)
=> true
bin.record.id
=> 321
(bin.boxes.first).as(BoxWithColor).color
=> "silver"
```

Export results to HTML:

**Not Yet Implemented**

## Development

Feel free to open a PR!

Please ensure that specs are passing and please run `crystal tool format` before submitting code.

## Contributing

1. Fork it (<https://github.com/your-github-user/bin_packing/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Matt Kimmel](https://github.com/mattkimmel) - Crystal port creator and maintainer
- [MAK IT](https://github.com/mak-it) - Original Ruby code and documentation
