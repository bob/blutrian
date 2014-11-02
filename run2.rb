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

#vertexes = [AP1, AP2, AP3]
#vertexes = [AP2, AP3, AP4]
#vertexes = [AP3, AP4, AP1]
vertexes = [AP4, AP1, AP2]




aps_coords = [aps[vertexes[0]], aps[vertexes[1]], aps[vertexes[2]]]
stack = {}

canvas = ImageFuncs.new("./img/avans-map-cell.jpg", aps_coords)
trian = TrianFuncs.new(aps_coords)
file = File.open('data/laptop.csv').read

cnt = 0
file.each_line do |l|
  line = l.chop.split("\t")
  hotspot_id = line[3].to_i
  next unless vertexes.include? hotspot_id.to_i

  #if cnt < 15
    #cnt += 1
    #next
  #end

  rssi = line[2]

  #stack = process(stack, hotspot_id, rssi)
  stack[hotspot_id] = rssi.to_i.abs
  next if stack.keys.count < 3

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
  #canvas.draw_point(p3[0], p3[1], :magenta)
  res_points << p3
  if p4
    #canvas.draw_point(p4[0], p4[1], :magenta)
    res_points << p4
  end

  p3, p4 = trian.intersection_2circles(b, c, aps[vertexes[1]], aps[vertexes[2]])
  #canvas.draw_point(p3[0], p3[1], :tomato)
  res_points << p3
  if p4
    #canvas.draw_point(p4[0], p4[1], :tomato)
    res_points << p4
  end

  #p res_points
  points = trian.get_3nearest(res_points)
  #p points

  #canvas.draw_line(points[0], points[1], :green)
  #canvas.draw_line(points[1], points[2], :green)
  #canvas.draw_line(points[2], points[0], :green)

  cd = trian.get_centroid(points)
  canvas.draw_point(cd[0], cd[1], :green)

  cnt += 1
  #break if cnt > 1
end

p "Processed #{cnt} points"

#res.each { |i| i.each { |j| canvas.draw_point(j[0], j[1], :yellow) } }

canvas.display




