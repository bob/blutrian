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
  AP3 => [9, 68],
  AP4 => [66, 91]
}

canvas = ImageFuncs.new("./img/avans-map-cell.jpg", aps.values)
file = File.open('data/laptop.csv').read

stack = {}; vertexes = []
cnt = 0
file.each_line do |l|
  line = l.chop.split("\t")
  p line

  hotspot_id = line[3].to_i
  rssi = line[2].to_i

  rssi = rssi * 1.05


  stack[hotspot_id] = rssi.abs
  vertexes.push hotspot_id unless vertexes.include? hotspot_id

  next if stack.keys.count < 3

  if stack.keys.count > 3
    to_delete = vertexes.shift
    stack.delete(to_delete)
  end

  aps_coords = [aps[vertexes[0]], aps[vertexes[1]], aps[vertexes[2]]]
  trian = TrianFuncs.new(aps_coords)

  a = stack[vertexes[0]]
  b = stack[vertexes[1]]
  c = stack[vertexes[2]]
  p "#{line[0]} - a: #{a}, b: #{b}, c: #{c}"

  res_points = []

  p3, p4 = trian.intersection_2circles(a, c, aps[vertexes[0]], aps[vertexes[2]])
  #canvas.draw_point(p3[0], p3[1], :orange)
  res_points << p3
  if p4
    #canvas.draw_point(p4[0], p4[1], :orange)
    res_points << p4
  end

  p3, p4 = trian.intersection_2circles(a, b, aps[vertexes[0]], aps[vertexes[1]])
  res_points << p3
  if p4
    res_points << p4
  end

  p3, p4 = trian.intersection_2circles(b, c, aps[vertexes[1]], aps[vertexes[2]])
  res_points << p3
  if p4
    res_points << p4
  end

  points = trian.get_3nearest(res_points)

  cd = trian.get_centroid(points)
  canvas.draw_point(cd[0], cd[1], "##{"%02x" % cnt}0000")

  cnt += 1
  #break if cnt > 1
end

p "Processed #{cnt} points"

canvas.display





