module BinPacking
  class ScoreBoardEntry
    getter bin : BinPacking::Bin
    getter box : BinPacking::Box
    getter score : BinPacking::Score?

    def initialize(bin, box)
      @bin = bin
      @box = box
      @score = nil
    end

    def calculate
      @score = @bin.score_for(@box)
    end

    def fit?
      !@score.nil? && !@score.as(BinPacking::Score).is_blank?
    end
  end
end
