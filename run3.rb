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

# define color step from start/end times
#f = File.open('data/laptop.csv')
#file = f.read
#cnt = 0
#file.each_line do |l|
  #line = l.chop.split("\t")
  #t = line[0]
  #@ts = Time.parse(t).to_i

  #@first_ts = @ts if cnt == 0
  #cnt += 1
#end
#@last_ts = @ts
#f.close

p "First: #{@first_ts}, Last: #{@last_ts}"

device_name = "laptop"

# cleanup results directory
results_path = "./results/#{device_name}"
Dir.foreach(results_path) {|f| fn = File.join(results_path, f); File.delete(fn) if f != '.' && f != '..'}

#canvas = ImageFuncs.new("./img/avans-map-cell.jpg", aps.values)
file = File.open("data/#{device_name}.csv").read

stack = {}; vertexes = []
cnt = 0
file.each_line do |l|
  canvas = ImageFuncs.new("./img/avans-map-cell.jpg", aps.values)

  line = l.chop.split("\t")
  p line

  #ts = Time.parse(line[0]).to_i
  #color = 255 - (255 * (@last_ts - ts) / (@last_ts - @first_ts))

  hotspot_id = line[3].to_i
  rssi = line[2].to_i

  #rssi = rssi * 1.05

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

  canvas.draw_signal(aps[vertexes[0]], a)
  canvas.draw_signal(aps[vertexes[1]], b)
  canvas.draw_signal(aps[vertexes[2]], c)

  res_points = []

  p3, p4 = trian.intersection_2circles(a, c, aps[vertexes[0]], aps[vertexes[2]])
  canvas.draw_point(p3[0], p3[1], :orange)
  res_points << p3
  if p4
    canvas.draw_point(p4[0], p4[1], :orange)
    res_points << p4
  end

  p5, p6 = trian.intersection_2circles(a, b, aps[vertexes[0]], aps[vertexes[1]])
  canvas.draw_point(p5[0], p5[1], :orange)
  res_points << p5
  if p6
    canvas.draw_point(p6[0], p6[1], :orange)
    res_points << p6
  end

  i1 = trian.get_lines_intersection(p3, p4, p5, p6)
  canvas.draw_point(i1[0], i1[1], :blue)

  p7, p8 = trian.intersection_2circles(b, c, aps[vertexes[1]], aps[vertexes[2]])
  canvas.draw_point(p7[0], p8[1], :orange)
  res_points << p7
  if p4
    canvas.draw_point(p8[0], p8[1], :orange)
    res_points << p8
  end

  #i2 = trian.get_lines_intersection(p3, p4, p7, p8)
  #canvas.draw_point(i2[0], i2[1], :yellow)
  #i3 = trian.get_lines_intersection(p5, p6, p7, p8)
  #canvas.draw_point(i3[0], i3[1], :green)

  points = trian.get_3nearest(res_points)

  canvas.draw_line(points[0], points[1], :green)
  canvas.draw_line(points[1], points[2], :green)
  canvas.draw_line(points[2], points[0], :green)

  cd = trian.get_centroid(points)
  #canvas.draw_point(cd[0], cd[1], "#00#{"%02x" % color}00")
  canvas.draw_point(cd[0], cd[1], :magenta)

  canvas.annotate(line[0], 20, 20)

  canvas.scale(0.5)
  canvas.write "#{results_path}/#{"%03d" % cnt}.jpg"
  #canvas.display

  cnt += 1
  #break if cnt > 0
end

p "Processed #{cnt} points"

#`cd results; convert *.jpg -set delay 50 laptop.gif`







