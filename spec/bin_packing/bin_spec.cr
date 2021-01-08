require "../spec_helper"

describe BinPacking::Bin do
  describe "for documentation" do
    it "allows to insert boxes while space available" do
      bin = BinPacking::Bin.new(100, 50)
      boxes = [
        BinPacking::Box.new(50, 50),
        BinPacking::Box.new(10, 40),
        BinPacking::Box.new(50, 44),
      ]
      remaining_boxes = [] of BinPacking::Box
      boxes.each do |box|
        remaining_boxes << box unless bin.insert(box)
      end
      bin.boxes.size.should eq(2)
      bin.boxes[0].should eq boxes[0]
      bin.boxes[1].should eq boxes[1]
      remaining_boxes.size.should eq 1
      remaining_boxes[0].should eq boxes[2]
      bin.boxes[0].x.should eq 0
      bin.boxes[0].y.should eq 0
      bin.boxes[0].packed?.should eq true
      bin.boxes[1].x.should eq 50
      bin.boxes[1].y.should eq 0
      bin.boxes[1].packed?.should eq true
      bin.efficiency.should eq 58
      remaining_boxes[0].x.should eq 0
      remaining_boxes[0].y.should eq 0
      remaining_boxes[0].packed?.should eq false
    end

    it "allows to use custom heuristic" do
      bin = BinPacking::Bin.new(100, 50, BinPacking::Heuristics::BestAreaFit.new)
      bin.insert(BinPacking::Box.new(50, 100)).should eq true
    end
  end

  describe "insert_in_known_position" do
    it "should allow inserting a box without updating its position" do
      bin = BinPacking::Bin.new(100, 50)
      box = BinPacking::Box.new(50, 50)
      box.x = 40
      box.y = 10

      bin.insert_in_known_position(box).should eq(true)

      box.x.should eq(40)
      box.y.should eq(10)
    end

    it "should not be movable by inserting new boxes" do
      bin = BinPacking::Bin.new(100, 50)
      box = BinPacking::Box.new(50, 50)
      box.x = 25
      box.y = 25

      bin.insert_in_known_position(box)

      other_box = BinPacking::Box.new(30, 30)

      bin.insert(other_box).should eq(false)
      other_box.packed?.should eq(false)
    end

    it "should allow insertion of boxes if known boxes leave space" do
      bin = BinPacking::Bin.new(100, 50)

      big_box = BinPacking::Box.new(50, 50)
      big_box.x = 0
      big_box.y = 0

      bin.insert_in_known_position(big_box)

      smaller_box = BinPacking::Box.new(30, 20)
      smaller_box.x = 50
      smaller_box.y = 0

      bin.insert_in_known_position(smaller_box)

      fitting_box = BinPacking::Box.new(20, 20)

      bin.insert(fitting_box).should eq(true)

      too_big_box = BinPacking::Box.new(40, 40)

      bin.insert(too_big_box).should eq(false)
    end

    it "should allow insertion of overlapping boxes" do
      bin = BinPacking::Bin.new(100, 50)
      box_a = BinPacking::Box.new(50, 50)
      box_a.x = 0
      box_a.y = 0

      box_b = BinPacking::Box.new(50, 50)
      box_b.x = 5
      box_b.y = 5

      bin.insert_in_known_position(box_a).should eq(true)
      bin.insert_in_known_position(box_b).should eq(true)
    end

    it "should allow insertion of boxes too big for bins" do
      bin = BinPacking::Bin.new(100, 50)
      box = BinPacking::Box.new(100, 100)
      box.x = 0
      box.y = 0

      bin.insert_in_known_position(box).should eq(true)
    end
  end
end
