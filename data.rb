require 'rubygems'

def process(stack, hotspot_id, rssi)
  stack[hotspot_id] = rssi

  stack
end

aps = {
  8000157 => [74, 26],
  8000393 => [10, 8],
  8000394 => [9, 68]
}
stack = {}

file = File.open('data/laptop.csv').read
cnt = 0
file.each_line do |l|
  line = l.chop.split("\t")
  hotspot_id = line[3]
  next unless aps.keys.include? hotspot_id.to_i

  rssi = line[2]

  #stack = process(stack, hotspot_id, rssi)
  stack[hotspot_id] = rssi
  next if stack.keys.count < 3

  p stack.inspect



  cnt += 1
  break if cnt > 10
end
