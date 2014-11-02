require 'rubygems'
require File.expand_path('../trian_funcs', __FILE__)
require File.expand_path('../image_funcs', __FILE__)

AP1 = 8000157
AP2 = 8000393
AP3 = 8000394

# APs coordinates
aps = {
  AP1 => [74, 26],
  AP2 => [10, 8],
  AP3 => [9, 68],
  AP4 => [66, 91]
}
aps_coords = [aps[AP1], aps[AP2], aps[AP3]]
stack = {}

canvas = ImageFuncs.new("./img/avans-map-cell.jpg", aps_coords)
trian = TrianFuncs.new(aps_coords)
file = File.open('data/laptop.csv').read

cnt = 0
file.each_line do |l|
  line = l.chop.split("\t")
  hotspot_id = line[3].to_i
  next unless aps.keys.include? hotspot_id.to_i

  rssi = line[2]

  #stack = process(stack, hotspot_id, rssi)
  stack[hotspot_id] = rssi.to_i.abs
  next if stack.keys.count < 3

  p "#{line[0]} - a: #{stack[AP1]}, b: #{stack[AP2]}, c: #{stack[AP3]}"
  ox, oy = trian.process(stack[AP1], stack[AP2], stack[AP3])
  p "Ox: #{ox}, Oy: #{oy}"
  canvas.draw_point(ox, oy, :green)
  trian.results = []

  cnt += 1
  break if cnt > 30
end

p "Processed #{cnt} points"

#res.each { |i| i.each { |j| canvas.draw_point(j[0], j[1], :yellow) } }

canvas.display



