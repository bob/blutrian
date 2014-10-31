# for ruby 1.8.7
class Float
    alias oldround:round
    def round(precision = nil)
        if precision.nil?
            return self
        else
            return ((self * 10**precision).oldround.to_f) / (10**precision)
        end
    end
end

class Numeric
  def percent_of(n)
    self.to_f / n.to_f * 100.0
  end

  def portion_of(n)
    self.to_f * n.to_f / 100.0
  end

  def to_radians
    self * Math::PI / 180
  end

  def to_degrees
    self * 180 / Math::PI
  end
end

class TrianFuncs
  attr_accessor :ap1, :ap2, :ap3, :a, :b, :c, :l1, :l2, :l3

  def initialize(aps)
    @ap1 = aps[0]
    @ap2 = aps[1]
    @ap3 = aps[2]
  end

  # Returns coordinates of the needed point
  # Point of the a,b,c intersection
  def process(a, b, c)
    @a = a; @b = b; @c = c

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
    ox, oy, ox2, oy2 = discover_coords(@a, @b, ang1, @l1, @ap1, @ap2)
    ox, oy, ox2, oy2 = discover_coords(@b, @c, ang2, @l2, @ap2, @ap3)
    ox, oy, ox2, oy2 = discover_coords(@c, @a, ang3, @l3, @ap3, @ap1)

    [ox, oy]
  end

  def discover_coords(ga, gb, gang, gl, gap1, gap2)
    # 6. Get triangle side fake length via formula for 2 sides and angle
    fd = get_side_by_2sides_and_angle(ga, gb, gang)
    p "Side fake length: #{fd}"

    # 7. Get fake-b-side-part from formula for circles intersection points
    fb = (gb**2 - ga**2 + fd**2) / (2 * fd)
    p "Side fake b part: #{fb}"

    # 8. Get real-b-side-part via proportion formula. d = l1.
    rb = (fb * gl) / fd
    p "Side real b part: #{rb}"

    # 9. Get real-a-side-part
    ra = gl - rb
    p "Side real a part: #{ra}"

    # 10. Get fake-h via Pythagor formula
    fh = Math.sqrt(gb**2 - fb**2)
    p "Fake h: #{fh}"

    # 11. Get real-h via proportion formula
    rh = fh * gl / fd
    p "Real h: #{rh}"

    # 12. Get real side-point coordinates
    rcx = gap1[0] + (ra * (gap2[0] - gap1[0]) / gl)
    rcy = gap1[1] + (ra * (gap2[1] - gap1[1]) / gl)
    p "C coords: [#{rcx}, #{rcy}]"

    # 13. Get ox, oy coordinates
    ox = rcx + ((gap2[1] - gap1[1]) * rh / gl)
    oy = rcy - ((gap2[0] - gap1[0]) * rh / gl)
    p "Result coords 1: [#{ox.round(2)}, #{oy.round(2)}]"

    ox2 = rcx - ((gap2[1] - gap1[1]) * rh / gl)
    oy2 = rcy + ((gap2[0] - gap1[0]) * rh / gl)
    p "Result coords 2: [#{ox2.round(2)}, #{oy2.round(2)}]"

    [ox, oy, ox2, oy2]
  end

  def get_side_real_length(p1, p2)
    Math.sqrt((p1[0] - p2[0])**2 + (p1[1] - p2[1])**2)
  end

  def get_percentage_for(i1, i2, i3)
    sum = i1 + i2 + i3
    [i1.percent_of(sum), i2.percent_of(sum), i3.percent_of(sum)]
  end

  def get_discovering_starts(signals, percents)
    s1 = signals[0] + signals[1]
    s2 = signals[1] + signals[2]
    s3 = signals[2] + signals[0]
    s = s1 + s2 + s3

    [percents[0].portion_of(s), percents[1].portion_of(s), percents[2].portion_of(s)]
  end

  def get_angle_by_3sides(a, b, c)
    v1 = a.to_f**2 + b.to_f**2 - c.to_f**2
    val = v1 / (2 * a * b)
    Math.acos(val).to_degrees rescue 0.0
  end

  def get_side_by_2sides_and_angle(a, b, angle)
    v1 = a.to_f**2 + b.to_f**2
    val = v1 - 2 * a * b * Math.cos(angle.to_radians)
    Math.sqrt(val)
  end

  def discover_angles(sides, starts)

    format = "%5s\t| %15s\t| %15s\t| %15s\t| %5s\n"
    printf format, "", "1", "2", "3", "sum"

    ang_sum = 0.0
    fls1, fls2, fls3 = starts

    shift = 0
    shift_step = 10
    pereval = true
    cnt = 0
    while cnt < 15 do
    #while ang_sum.round(2) != 360.0 do
      fls1 += shift; fls2 += shift; fls3 += shift

      ang1 = get_angle_by_3sides(sides[0], sides[1], fls1)
      ang2 = get_angle_by_3sides(sides[1], sides[2], fls2)
      ang3 = get_angle_by_3sides(sides[2], sides[0], fls3)
      ang_sum = ang1 + ang2 + ang3

      printf format, "#{shift}", "#{fls1.round(2)} - #{ang1.round(2)}", "#{fls2.round(2)} - #{ang2.round(2)}", "#{fls3.round(2)} - #{ang3.round(2)}", "#{ang_sum.round(2)}"

      if ang1.zero? or ang2.zero? or ang3.zero?
        shift = -(shift_step) #if shift_step == 10
        cnt += 1
        next
      end

      if ang_sum.round(2) < 360.0
        if pereval
          shift_step = (shift_step.to_f / 10)
          pereval = false
        end
        shift = shift_step.to_f
      else
        if !pereval
          shift_step = (shift_step.to_f / 10)
          pereval = true
        end
        shift = -(shift_step)
      end

      cnt += 1
    end

    [ang1, ang2, ang3]
  end
end
