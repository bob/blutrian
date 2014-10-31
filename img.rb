require "rubygems"
require File.expand_path('../image_funcs', __FILE__)

@ap1 = [10,8]; @ap2 = [9,68]; @ap3 = [74,26]

canvas = ImageFuncs.new("./img/avans-map-cell.jpg", [@ap1, @ap2, @ap3])

canvas.display


exit
