require 'rubygems'
require File.expand_path('../processor', __FILE__)

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

processor = Processor.new(aps)

device_name = "laptop"

# cleanup results directory
results_path = "./results/#{device_name}"
Dir.foreach(results_path) {|f| fn = File.join(results_path, f); File.delete(fn) if f != '.' && f != '..'}

file = File.open("data/#{device_name}.csv").read

stack = {}; vertexes = []
cnt = 0
file.each_line do |l|
  line = l.chop.split("\t")
  p line

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

  a = stack[vertexes[0]]
  b = stack[vertexes[1]]
  c = stack[vertexes[2]]

  teststr = "#{line[0]} - a: #{a}, b: #{b}, c: #{c}"
  p teststr

  next if teststr != "2014-10-17 12:09:30 - a: 57, b: 31, c: 58"
  #next if teststr != "2014-10-17 12:05:18 - a: 80, b: 72, c: 44"

  processor.vertexes = vertexes
  processor.line = line

  processor.run a, b, c



  cnt += 1
  break
  #break if cnt > 0
end

p "Processed #{cnt} points"

#`cd results; convert *.jpg -set delay 50 laptop.gif`








