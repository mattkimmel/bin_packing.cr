module BinPacking
  module Heuristics
    class BestShortSideFit < BinPacking::Heuristics::Base
      private def calculate_score(free_rect, rect_width, rect_height)
        leftover_horiz = (free_rect.width - rect_width).abs
        leftover_vert = (free_rect.height - rect_height).abs
        args = Tuple(Int64, Int64).from([leftover_horiz, leftover_vert].sort)
        BinPacking::Score.new(*args)
      end
    end
  end
end
