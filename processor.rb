require File.expand_path('../trian_funcs', __FILE__)
require File.expand_path('../image_funcs', __FILE__)

class Processor
  attr_accessor :aps, :vertexes, :line
  attr_accessor :circles_not_intersect, :lines_not_intersect
  attr_accessor :signals
  attr_accessor :canvas, :trian

  AP1 = 4010142 #8000157
  AP2 = 4010143 #8000393
  AP3 = 4010144 #8000394
  AP4 = 4010145 #8000395
  AP9 = 4010146 #8000438

  # APs coordinates
  COORDS = {
    AP1 => [56, 44],
    AP2 => [8, 30],
    AP3 => [7, 76],
    AP4 => [49, 93],
    AP9 => [25, 5]
  }

  def initialize(aps=nil)
    @aps = aps || COORDS
    @vertexes = []
    @circles_not_intersect = false
    @lines_not_intersect = false
    @signals = []
  end

  def run(a, b, c, recurs = false)
    unless recurs
#      @canvas = ImageFuncs.new("./img/avans-map-cell.jpg", @aps.values)
      @trian = TrianFuncs.new(aps_coords)
    end

    @signals = [a, b, c]
    p @signals.inspect

    res1 = circles_intersect(0, 1)
    res2 = circles_intersect(0, 2)
    res3 = circles_intersect(1, 2)

    if @circles_not_intersect
      @circles_not_intersect = false
      ts = tuned_signals
      return run(ts[0], ts[1], ts[2], true)
    end

    li = lines_intersect_any(res1, res2, res3)

    if @lines_not_intersect
      @lines_not_intersect = false
      ts = tuned_signals
      return run(ts[0], ts[1], ts[2], true)
    end

    #@canvas.draw_signal(aps_coords[0], @signals[0])
    #@canvas.draw_signal(aps_coords[1], @signals[1])
    #@canvas.draw_signal(aps_coords[2], @signals[2])
    #@canvas.annotate(@line[0], 20, 20)

    #points = trian.get_3nearest(res_points)

    #canvas.draw_line(points[0], points[1], :green)
    #canvas.draw_line(points[1], points[2], :green)
    #canvas.draw_line(points[2], points[0], :green)

    #cd = trian.get_centroid(points)
    #canvas.draw_point(cd[0], cd[1], :magenta)

    #@canvas.display
  end

  def tuned_signals
    min = @signals.min
    res = []
    res[0] = @signals[0] == min ? @signals[0] * 1.1 : @signals[0] * 1.01
    res[1] = @signals[1] == min ? @signals[1] * 1.1 : @signals[1] * 1.01
    res[2] = @signals[2] == min ? @signals[2] * 1.1 : @signals[2] * 1.01
    res
  end

  def circles_intersect(ind1, ind2)
    res_points = []
    p3, p4 = @trian.intersection_2circles(@signals[ind1], @signals[ind2], @aps[@vertexes[ind1]], @aps[@vertexes[ind2]])

    #@canvas.draw_point(p3[0], p3[1], :orange)
    res_points << p3
    if p4
      #@canvas.draw_point(p4[0], p4[1], :orange)
      res_points << p4
    else
      @circles_not_intersect = true
    end

    res_points
  end

  def lines_intersect_any(p1, p2, p3)
    res = @trian.get_lines_intersection(p1[0], p1[1], p2[0], p2[1])
    res = @trian.get_lines_intersection(p2[0], p2[1], p3[0], p3[1]) if res == -1
    res = @trian.get_lines_intersection(p1[0], p1[1], p3[0], p3[1]) if res == -1
    if res == -1
      @lines_not_intersect = true
    else
      @canvas.draw_point(res[0], res[1], :blue)
    end
    res
  end

  def aps_coords
    [@aps[@vertexes[0]], @aps[@vertexes[1]], @aps[@vertexes[2]]]
  end
end
