require 'RMagick'

class ImageFuncs
  include Magick
  attr_accessor :canvas, :ap1, :ap2, :ap3

  def initialize(filename, aps)
    canvas = ImageList.new(filename)
    @canvas = canvas.flip
    @ap1 = aps[0]
    @ap2 = aps[1]
    @ap3 = aps[2]

    mark_aps
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

  def display
    @canvas.flip.display
  end

  private
  def mark_aps
    draw_point(@ap1[0], @ap1[1], :red)
    draw_point(@ap2[0], @ap2[1], :red)
    draw_point(@ap3[0], @ap3[1], :red)
  end

  def scale_coords(a, b)
    # image width should be correct
    sidesize = @canvas.columns

    x = sidesize * a.to_f / 100.0
    y = sidesize * b.to_f / 100.0

    [x, y]
  end



end
