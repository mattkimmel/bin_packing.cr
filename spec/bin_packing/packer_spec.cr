require "../spec_helper"

describe BinPacking::Packer do
  describe "#pack" do
    it "does nothing when no bin and no box passed" do
      packer = BinPacking::Packer.new([] of BinPacking::Bin)
      packer.pack([] of BinPacking::Box).empty?.should be_true
    end

    it "puts single box in single bin" do
      bin = BinPacking::Bin.new(9_600, 3_100)
      box = BinPacking::Box.new(9_000, 3_000)
      packer = BinPacking::Packer.new([bin])
      packer.pack([box]).should eq [box]
      bin.boxes.size.should eq 1
      box.width.should eq 9_000
      box.height.should eq 3_000
      box.x.should eq 0
      box.y.should eq 0
      box.packed?.should be_true
    end

    it "puts rotated box in single bin" do
      bin = BinPacking::Bin.new(9_600, 3_100)
      box = BinPacking::Box.new(1_000, 9_000)
      packer = BinPacking::Packer.new([bin])
      packer.pack([box]).size.should eq 1
      bin.boxes.size.should eq 1
      box.width.should eq 9_000
      box.height.should eq 1_000
      box.x.should eq 0
      box.y.should eq 0
      box.packed?.should be_true
    end

    it "puts large box in large bin" do
      bin_1 = BinPacking::Bin.new(9_600, 3_100)
      bin_2 = BinPacking::Bin.new(10_000, 4_500)
      bin_3 = BinPacking::Bin.new(12_000, 4_500)
      box = BinPacking::Box.new(11_000, 2_000)
      packer = BinPacking::Packer.new([bin_1, bin_2, bin_3])
      packer.pack([box]).size.should eq 1
      bin_1.boxes.size.should eq 0
      bin_2.boxes.size.should eq 0
      bin_3.boxes.size.should eq 1
      box.width.should eq 11_000
      box.height.should eq 2_000
    end

    it "puts two boxes in single bin" do
      bin = BinPacking::Bin.new(9_600, 3_100)
      box_1 = BinPacking::Box.new(8_000, 1_500)
      box_2 = BinPacking::Box.new(1_000, 9_000)
      packer = BinPacking::Packer.new([bin])
      packer.pack([box_1, box_2]).size.should eq 2
      bin.boxes.size.should eq 2
    end

    it "puts two boxes in separate bins" do
      bin_1 = BinPacking::Bin.new(9_600, 3_100)
      bin_2 = BinPacking::Bin.new(9_600, 3_100)
      box_1 = BinPacking::Box.new(5_500, 2_000)
      box_2 = BinPacking::Box.new(5_000, 2_000)
      packer = BinPacking::Packer.new([bin_1, bin_2])
      packer.pack([box_1, box_2]).size.should eq 2
      bin_1.boxes.size.should eq 1
      bin_2.boxes.size.should eq 1
    end

    it "does not put in bin too large box" do
      bin = BinPacking::Bin.new(9_600, 3_100)
      box = BinPacking::Box.new(10_000, 10)
      packer = BinPacking::Packer.new([bin])
      packer.pack([box]).size.should eq 0
      bin.boxes.size.should eq 0
      box.packed?.should be_false
    end

    it "puts in bin only fitting boxes" do
      bin = BinPacking::Bin.new(9_600, 3_100)
      box_1 = BinPacking::Box.new(4_000, 3_000)
      box_2 = BinPacking::Box.new(4_000, 3_000)
      box_3 = BinPacking::Box.new(4_000, 3_000)
      boxes = [box_1, box_2, box_3]
      packer = BinPacking::Packer.new([bin])
      packer.pack(boxes).size.should eq 2
      bin.boxes.size.should eq 2
      boxes.size.should eq 3 # Should not modify input array
      boxes.count { |b| b.packed? }.should eq 2
    end

    it "respects limit" do
      bin = BinPacking::Bin.new(9_600, 3_100)
      box_1 = BinPacking::Box.new(1_000, 1_000)
      box_2 = BinPacking::Box.new(1_000, 1_000)
      boxes = [box_1, box_2]
      packer = BinPacking::Packer.new([bin])
      packer.pack(boxes, limit: 1).size.should eq 1
      bin.boxes.size.should eq 1
      boxes.size.should eq 2
      boxes.count { |b| b.packed? }.should eq 1
    end

    it "does not pack box twice" do
      bin = BinPacking::Bin.new(9_600, 3_100)
      box = BinPacking::Box.new(1_000, 9_000)
      packer = BinPacking::Packer.new([bin])
      packer.pack([box]).size.should eq 1
      packer.pack([box]).size.should eq 0
    end

    it "respects the can_rotate property" do
      bin = BinPacking::Bin.new(9_600, 3_100)
      box = BinPacking::Box.new(1_000, 9_000)
      box.can_rotate = false
      packer = BinPacking::Packer.new([bin])
      packer.pack([box]).size.should eq 0
      bin.boxes.size.should eq 0
      box.width.should eq 1_000
      box.height.should eq 9_000
      box.packed?.should be_false

      bin = BinPacking::Bin.new(9_600, 3_100)
      box = BinPacking::Box.new(1_000, 9_000)
      box.can_rotate = true
      packer = BinPacking::Packer.new([bin])
      packer.pack([box]).size.should eq 1
      bin.boxes.size.should eq 1
      box.packed?.should be_true
    end
  end

  describe "#pack!" do
    it "throws error when some of boxes not packed" do
      box_1 = BinPacking::Box.new(9_000, 3_000)
      box_2 = BinPacking::Box.new(8_000, 2_500)
      packer = BinPacking::Packer.new([BinPacking::Bin.new(9_600, 3_100)])
      expect_raises(ArgumentError, "1 boxes not packed into 1 bins!") do
        packer.pack!([box_1, box_2])
      end
    end
  end

  describe "for documentation" do
    it "puts multiple boxes into multiple bins" do
      bin_1 = BinPacking::Bin.new(100, 50)
      bin_2 = BinPacking::Bin.new(50, 50)
      boxes = [
        BinPacking::Box.new(15, 10), # Should be added last (smaller)
        BinPacking::Box.new(50, 45), # Fits in bin_2 better than in bin_1
        BinPacking::Box.new(40, 40),
        BinPacking::Box.new(200, 200), # Too large to fit
      ]
      packer = BinPacking::Packer.new([bin_1, bin_2])
      packed_boxes = packer.pack(boxes)
      packed_boxes.size.should eq 3
      bin_1.boxes.size.should eq 2
      bin_1.boxes[0].label.should eq "40x40 at [0,0]"
      bin_1.boxes[1].label.should eq "15x10 at [0,40]"
      bin_2.boxes.size.should eq 1
      bin_2.boxes[0].label.should eq "50x45 at [0,0]"
      boxes.last.packed?.should be_false
    end
  end
end
