require 'RMagick'

class ImageFuncs
  include Magick
  attr_accessor :canvas, :aps

  def initialize(filename, aps)
    canvas = ImageList.new(filename)
    @canvas = canvas.flip
    @aps = aps

    mark_aps aps
  end

  def draw_point(x, y, color)
    x, y = scale_coords(x, y)

    circle = Magick::Draw.new
    circle.stroke(color.to_s)

    circle.fill_opacity(0)
    circle.stroke_opacity(0.75)
    circle.stroke_width(4)
    #circle.stroke_linecap('round')
    #circle.stroke_linejoin('round')
    circle.ellipse(x, y, 3, 3, 0, 360)

    circle.draw(@canvas)
  end

  def draw_line(pa, pb, color)
    return unless pa.class.name == "Array"

    x1, y1 = scale_coords(pa[0], pa[1])
    x2, y2 = scale_coords(pb[0], pb[1])

    draw = Magick::Draw.new
    draw.stroke(color.to_s)

    draw.line(x1, y1, x2, y2)
    draw.draw(@canvas)
  end

  def display
    @canvas.flip.display
  end

  private
  def mark_aps(aps)
    aps.each do |ap|
      draw_point(ap[0], ap[1], :red)
    end
  end

  def scale_coords(a, b)
    # image width should be correct
    sidesize = @canvas.columns

    x = sidesize * a.to_f / 100.0
    y = sidesize * b.to_f / 100.0

    [x, y]
  end



end
