require File.expand_path('../trian_funcs', __FILE__)
require File.expand_path('../image_funcs', __FILE__)

class Processor
  attr_accessor :aps, :vertexes, :line
  attr_accessor :circles_not_intersect, :lines_not_intersect
  attr_accessor :signals
  attr_accessor :canvas, :trian

  def initialize(aps)
    @aps = aps
    @vertexes = []
    @circles_not_intersect = false
    @lines_not_intersect = false
    @signals = []
  end

  def run(a, b, c)
    @signals = [a, b, c]
    @canvas = ImageFuncs.new("./img/avans-map-cell.jpg", @aps.values)
    @trian = TrianFuncs.new(aps_coords)

    @canvas.draw_signal(aps_coords[0], @signals[0])
    @canvas.draw_signal(aps_coords[1], @signals[1])
    @canvas.draw_signal(aps_coords[2], @signals[2])
    @canvas.annotate(@line[0], 20, 20)

    res1 = circles_intersect(0, 1)
    res2 = circles_intersect(0, 2)
    res3 = circles_intersect(1, 2)

    i1 = @trian.get_lines_intersection(res1[0], res1[1], res2[0], res2[1])
    @canvas.draw_point(i1[0], i1[1], :blue)


    #points = trian.get_3nearest(res_points)

    #canvas.draw_line(points[0], points[1], :green)
    #canvas.draw_line(points[1], points[2], :green)
    #canvas.draw_line(points[2], points[0], :green)

    #cd = trian.get_centroid(points)
    #canvas.draw_point(cd[0], cd[1], :magenta)

    @canvas.display
  end

  def circles_intersect(ind1, ind2)
    res_points = []
    p3, p4 = @trian.intersection_2circles(@signals[ind1], @signals[ind2], @aps[@vertexes[ind1]], @aps[@vertexes[ind2]])

    @canvas.draw_point(p3[0], p3[1], :orange)
    res_points << p3
    if p4
      @canvas.draw_point(p4[0], p4[1], :orange)
      res_points << p4
    end

    res_points
  end

  def aps_coords
    [@aps[@vertexes[0]], @aps[@vertexes[1]], @aps[@vertexes[2]]]
  end
end
