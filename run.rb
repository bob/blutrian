require 'rubygems'
require File.expand_path('../funcs', __FILE__)

include Funcs

p "Hello"

# 1. Define 3 points (AP) coordinates. This will be our triangle. Get ap1x, ap1y, ap2x, ap2y, ap3x, ap3y
@ap1 = [7,7]; @ap2 = [7,63]; @ap3 = [70,25]

# 1.1 Define signals levels
@a = 59; @b = 62; @c = 44

# 2. Calc sides real lengths. ('Real' means plan metrics (mm)). Get l1, l2, l3
@l1 = get_side_real_length(@ap1, @ap2)
@l2 = get_side_real_length(@ap2, @ap3)
@l3 = get_side_real_length(@ap3, @ap1)

p "Length: #{@l1}, #{@l2}, #{@l3}"

# 3. Get percents of sides real lengths
l1_p, l2_p, l3_p = get_percentage_for(@l1, @l2, @l3)

p "Length percents: #{l1_p}, #{l2_p}, #{l3_p}, #{l1_p + l2_p + l3_p}"

# 4. Get start-values for angles discovering.
fls1, fls2, fls3 = get_discovering_starts([@a, @b, @c], [l1_p, l2_p, l3_p])

p "Discovering start values: #{fls1}, #{fls2}, #{fls3}, S: #{fls1 + fls2 + fls3}"

# 5. Get angles. ab_angle, bc_angle, ca_angle
ang1, ang2, ang3 = discover_angles([@a, @b, @c], [fls1, fls2, fls3])

p "Discover angles: #{ang1}, #{ang2}, #{ang3}"

# --- Below are actions for each pair of sides
# 6. Get triangle side fake length via formula for 2 sides and angle
fd = get_side_by_2sides_and_angle(@a, @b, ang1)
p "Side fake length: #{fd}"

# 7. Get fake-b-side-part from formula for circles intersection points
fb = (@b**2 - @a**2 + fd**2) / (2 * fd)
p "Side fake b part: #{fb}"

# 8. Get real-b-side-part via proportion formula. d = l1.
rb = (fb * @l1) / fd
p "Side real b part: #{rb}"

# 9. Get real-a-side-part
ra = @l1 - rb
p "Side real a part: #{ra}"

# 10. Get fake-h via Pythagor formula
fh = Math.sqrt(@b**2 - fb**2)
p "Fake h: #{fh}"

# 11. Get real-h via proportion formula
rh = fh * @l1 / fd
p "Real h: #{rh}"

# 12. Get real side-point coordinates
rcx = @ap1[0] + (ra * (@ap2[0] - @ap1[0]) / @l1)
rcy = @ap1[1] + (ra * (@ap2[1] - @ap1[1]) / @l1)
p "C coords: [#{rcx}, #{rcy}]"

# 13. Get ox, oy coordinates
ox = rcx + ((@ap2[1] - @ap1[1]) * rh / @l1)
oy = rcy + ((@ap2[0] - @ap1[0]) * rh / @l1)
p "Result coords: [#{ox.round(2)}, #{oy.round(2)}]"




