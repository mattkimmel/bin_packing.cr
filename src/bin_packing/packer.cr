module BinPacking
  property bins : Array(BinPacking::Bin)

  class Packer
    def initialize(@bins : Array(BinPacking::Bin))
      @unpacked_boxes = [] of BinPacking::Box
    end

    def pack(boxes, limit = BinPacking::Score::MAX_INT)
      packed_boxes = [] of BinPacking::Box
      boxes = boxes.reject { |b| b.packed? }
      return packed_boxes if boxes.none?

      board = BinPacking::ScoreBoard.new(@bins, boxes)
      while !board.best_fit.nil?
        entry = board.best_fit.as(BinPacking::ScoreBoardEntry)
        entry.bin.insert!(entry.box)
        board.remove_box(entry.box)
        board.recalculate_bin(entry.bin)
        packed_boxes << entry.box
        break if packed_boxes.size >= limit
      end

      packed_boxes
    end

    def pack!(boxes)
      packed_boxes = pack(boxes)
      if packed_boxes.size != boxes.size
        raise ArgumentError.new("#{boxes.size - packed_boxes.size} boxes not packed into #{@bins.size} bins!")
      end
    end
  end
end
