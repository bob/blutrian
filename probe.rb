require 'rubygems'
require File.expand_path('../trian_funcs', __FILE__)
require File.expand_path('../image_funcs', __FILE__)

AP1 = 8000157
AP2 = 8000393
AP3 = 8000394
AP4 = 8000395

# APs coordinates
aps = {
  AP1 => [74, 26],
  AP2 => [10, 8],
  AP4 => [66, 91]
}
aps_coords = [aps[AP1], aps[AP2], aps[AP4]]
stack = {}

canvas = ImageFuncs.new("./img/avans-map-cell.jpg", aps_coords)
trian = TrianFuncs.new(aps_coords)

a = 48; b = 61; c = 61
p "a: #{a}, b: #{b}, c: #{c}"
ox, oy = trian.process(a, b, c)
p "Ox: #{ox}, Oy: #{oy}"
canvas.draw_point(ox, oy, :green)

#res.each { |i| i.each { |j| canvas.draw_point(j[0], j[1], :yellow) } }

canvas.display




