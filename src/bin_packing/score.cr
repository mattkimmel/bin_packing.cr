module BinPacking
  class Score
    include Comparable(BinPacking::Score)

    MAX_INT = (2_i64**(sizeof(Int64) * 8 - 2) - 1)

    getter score_1 : Int64
    getter score_2 : Int64

    def self.new_blank
      new
    end

    def initialize(@score_1 = MAX_INT, @score_2 = MAX_INT)
    end

    # Smaller number is greater (used by original algorithm).
    def <=>(other)
      if self.score_1 > other.score_1 || (self.score_1 == other.score_1 && self.score_2 > other.score_2)
        -1
      elsif self.score_1 < other.score_1 || (self.score_1 == other.score_1 && self.score_2 < other.score_2)
        1
      else
        0
      end
    end

    def assign(other)
      @score_1 = other.score_1
      @score_2 = other.score_2
    end

    def is_blank?
      @score_1 == MAX_INT
    end

    def decrease_by(delta)
      @score_1 += delta
      @score_2 += delta
    end
  end
end
