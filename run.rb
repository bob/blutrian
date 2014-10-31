require 'rubygems'
require File.expand_path('../trian_funcs', __FILE__)
require File.expand_path('../image_funcs', __FILE__)

# APs coordinates
#@ap1 = [10,8]; @ap2 = [9,68]; @ap3 = [74,26]
@ap1 = [74,26]; @ap2 = [10,8]; @ap3 = [9,68]
aps = [@ap1, @ap2, @ap3]

canvas = ImageFuncs.new("./img/avans-map-cell.jpg", aps)
trian = TrianFuncs.new(aps)

# 1.1 Define signals levels
#a = 59; b = 62; c = 44

#a = 44; b = 59; c = 62
#ox, oy = trian.process(a, b, c)
#p "Ox: #{ox}, Oy: #{oy}"
#canvas.draw_point(ox, oy, :yellow)

a = 44; b = 68; c = 64
ox, oy = trian.process(a, b, c)
p "Ox: #{ox}, Oy: #{oy}"
canvas.draw_point(ox, oy, :yellow)


#canvas.display



