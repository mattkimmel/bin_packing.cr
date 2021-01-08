require "../spec_helper"

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

describe "for documentation" do
  it "can store extra information" do
    record = Record.new(321_i64, 100_i64, 200_i64)
    bin = BinWithRecord.new(record)
    box = BoxWithColor.new(70_i64, 80_i64, "silver")
    bin.insert(box).should eq true
    bin.record.id.should eq 321
    (bin.boxes.first).as(BoxWithColor).color.should eq "silver"
  end
end
