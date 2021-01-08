module BinPacking
  class Box
    property width : Int64
    property height : Int64
    property x : Int64
    property y : Int64
    property area : Int64
    property packed : Bool
    property can_rotate : Bool

    def_clone

    def initialize(@width : Int64, @height : Int64)
      @x = 0
      @y = 0
      @packed = false
      @can_rotate = true
      @area = @width * @height
    end

    def packed?
      @packed
    end

    def can_rotate?
      @can_rotate
    end

    def label
      "#{@width}x#{@height} at [#{@x},#{@y}]"
    end
  end
end
