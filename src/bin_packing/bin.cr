module BinPacking
  class Bin
    getter width : Int64
    getter height : Int64
    getter boxes
    getter heuristic : BinPacking::Heuristics::Base
    property free_rectangles : Array(BinPacking::FreeSpaceBox)

    def initialize(@width : Int64, @height : Int64, @heuristic = BinPacking::Heuristics::BestShortSideFit.new)
      @boxes = [] of BinPacking::Box
      box = BinPacking::FreeSpaceBox.new(width, height)
      @free_rectangles = [box]
    end

    def efficiency
      boxes_area = 0
      @boxes.each { |box| boxes_area += box.area }
      boxes_area * 100 / area
    end

    def insert(box)
      return false if box.packed?

      @heuristic.find_position_for_new_node!(box, @free_rectangles)
      return false unless box.packed?

      insert_in_known_position(box)
    end

    def insert!(box)
      unless insert(box)
        raise ArgumentError.new("Could not insert box #{box.inspect} into bin #{inspect}.")
      end
      self
    end

    def insert_in_known_position(box)
      num_rectangles_to_process = @free_rectangles.size
      i = 0
      while i < num_rectangles_to_process
        if split_free_node(@free_rectangles[i], box)
          @free_rectangles.delete_at(i)
          num_rectangles_to_process -= 1
        else
          i += 1
        end
      end

      prune_free_list

      @boxes << box
      true
    end

    def score_for(box)
      @heuristic.find_position_for_new_node!(box.clone, @free_rectangles)
    end

    def is_larger_than?(box)
      (@width >= box.width && @height >= box.height) ||
        (@height >= box.width && @width >= box.height)
    end

    def label
      "#{@width}x#{@height} #{efficiency}%"
    end

    private def area
      @width * @height
    end

    private def place_rect(node)
      num_rectangles_to_process = @free_rectangles.size
      i = 0
      while i < num_rectangles_to_process
        if split_free_node(@free_rectangles[i], node)
          @free_rectangles.delete_at(i)
          num_rectangles_to_process -= 1
        else
          i += 1
        end
      end

      prune_free_list

      @boxes << node
    end

    private def split_free_node(free_node, used_node)
      # Test with SAT if the rectangles even intersect.
      if used_node.x >= free_node.x + free_node.width ||
         used_node.x + used_node.width <= free_node.x ||
         used_node.y >= free_node.y + free_node.height ||
         used_node.y + used_node.height <= free_node.y
        return false
      end

      try_split_free_node_vertically(free_node, used_node)

      try_split_free_node_horizontally(free_node, used_node)

      true
    end

    private def try_split_free_node_vertically(free_node, used_node)
      if used_node.x < free_node.x + free_node.width && used_node.x + used_node.width > free_node.x
        try_leave_free_space_at_top(free_node, used_node)
        try_leave_free_space_at_bottom(free_node, used_node)
      end
    end

    private def try_leave_free_space_at_top(free_node, used_node)
      if used_node.y > free_node.y && used_node.y < free_node.y + free_node.height
        new_node = free_node.clone
        new_node.height = used_node.y - new_node.y
        @free_rectangles << new_node
      end
    end

    private def try_leave_free_space_at_bottom(free_node, used_node)
      if used_node.y + used_node.height < free_node.y + free_node.height
        new_node = free_node.clone
        new_node.y = used_node.y + used_node.height
        new_node.height = free_node.y + free_node.height - (used_node.y + used_node.height)
        @free_rectangles << new_node
      end
    end

    private def try_split_free_node_horizontally(free_node, used_node)
      if used_node.y < free_node.y + free_node.height && used_node.y + used_node.height > free_node.y
        try_leave_free_space_on_left(free_node, used_node)
        try_leave_free_space_on_right(free_node, used_node)
      end
    end

    private def try_leave_free_space_on_left(free_node, used_node)
      if used_node.x > free_node.x && used_node.x < free_node.x + free_node.width
        new_node = free_node.clone
        new_node.width = used_node.x - new_node.x
        @free_rectangles << new_node
      end
    end

    private def try_leave_free_space_on_right(free_node, used_node)
      if used_node.x + used_node.width < free_node.x + free_node.width
        new_node = free_node.clone
        new_node.x = used_node.x + used_node.width
        new_node.width = free_node.x + free_node.width - (used_node.x + used_node.width)
        @free_rectangles << new_node
      end
    end

    # Goes through the free rectangle list and removes any redundant entries.
    private def prune_free_list
      i = 0
      while i < @free_rectangles.size
        j = i + 1
        while j < @free_rectangles.size
          if is_contained_in?(@free_rectangles[i], @free_rectangles[j])
            @free_rectangles.delete_at(i)
            i -= 1
            break
          end
          if is_contained_in?(@free_rectangles[j], @free_rectangles[i])
            @free_rectangles.delete_at(j)
          else
            j += 1
          end
        end
        i += 1
      end
    end

    private def is_contained_in?(rect_a, rect_b)
      return rect_a.x >= rect_b.x && rect_a.y >= rect_b.y &&
        rect_a.x + rect_a.width <= rect_b.x + rect_b.width &&
        rect_a.y + rect_a.height <= rect_b.y + rect_b.height
    end
  end
end
