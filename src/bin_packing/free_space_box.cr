module BinPacking
  class FreeSpaceBox
    property x : Int64
    property y : Int64
    property width : Int64
    property height : Int64

    def_clone

    def initialize(width, height)
      @width = width
      @height = height
      @x = 0
      @y = 0
    end
  end
end
