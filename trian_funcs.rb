require "kdtree"

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
  attr_accessor :debug
  attr_accessor :ap1, :ap2, :ap3, :a, :b, :c, :l1, :l2, :l3
  attr_accessor :result_is_inner
  attr_accessor :results

  def initialize(aps)
    @ap1 = aps[0]
    @ap2 = aps[1]
    @ap3 = aps[2]
    @debug = true
    @result_is_inner = true
    @results = []
  end

  # Returns coordinates of the needed point
  # Point of the a,b,c intersection
  def process(a, b, c)
    # 2. Calc sides real lengths. ('Real' means plan metrics (mm)). Get l1, l2, l3
    @l1 = get_side_real_length(@ap1, @ap2)
    @l2 = get_side_real_length(@ap2, @ap3)
    @l3 = get_side_real_length(@ap3, @ap1)
    p "Length: #{@l1}, #{@l2}, #{@l3}" if @debug

    # 3. Get percents of sides real lengths
    l1_p, l2_p, l3_p = get_percentage_for(@l1, @l2, @l3)
    p "Length percents: #{l1_p}, #{l2_p}, #{l3_p}, #{l1_p + l2_p + l3_p}" if @debug

    # 4. Get start-values for angles discovering.
    fls1, fls2, fls3 = get_discovering_starts([a, b, c], [l1_p, l2_p, l3_p])
    p "Discovering start values: #{fls1}, #{fls2}, #{fls3}, S: #{fls1 + fls2 + fls3}" if @debug

    # 5. Get angles. ab_angle, bc_angle, ca_angle
    ang1, ang2, ang3 = discover_angles([a, b, c], [fls1, fls2, fls3])
    p "Discover angles: #{ang1}, #{ang2}, #{ang3}" if @debug
    return [0,0] if ang1 == 0 or !ang2 == 0 or !ang3 == 0

    # --- Below are actions for each pair of sides
    @results << discover_coords(a, b, ang1, @l1, @ap1, @ap2)
    @results << discover_coords(b, c, ang2, @l2, @ap2, @ap3)
    @results << discover_coords(c, a, ang3, @l3, @ap3, @ap1)

    p "Results: inner?: #{@result_is_inner}, #{@results.inspect}" if @debug

    @results.last[0]
  end

  def discover_coords(ga, gb, gang, gl, gap1, gap2)
    res = []

    # 6. Get triangle side fake length via formula for 2 sides and angle
    fd = get_side_by_2sides_and_angle(ga, gb, gang)
    #p "Side fake length: #{fd}"

    # 7. Get fake-b-side-part from formula for circles intersection points
    fb = (gb**2 - ga**2 + fd**2) / (2 * fd)
    #p "Side fake b part: #{fb}"

    # 8. Get real-b-side-part via proportion formula. d = l1.
    rb = (fb * gl) / fd
    #p "Side real b part: #{rb}"

    # 9. Get real-a-side-part
    ra = gl - rb
    #p "Side real a part: #{ra}"

    # 10. Get fake-h via Pythagor formula
    fh = Math.sqrt(gb**2 - fb**2)
    #p "Fake h: #{fh}"

    # 11. Get real-h via proportion formula
    rh = fh * gl / fd
    #p "Real h: #{rh}"

    # 12. Get real side-point coordinates
    rcx = gap1[0] + (ra * (gap2[0] - gap1[0]) / gl)
    rcy = gap1[1] + (ra * (gap2[1] - gap1[1]) / gl)
    #p "C coords: [#{rcx}, #{rcy}]"

    # 13. Get ox, oy coordinates
    ox = rcx + ((gap2[1] - gap1[1]) * rh / gl)
    oy = rcy - ((gap2[0] - gap1[0]) * rh / gl)
    res << [ox, oy] if @result_is_inner == is_inner?(ox, oy)
    p "Coords 1: [#{ox.round(2)}, #{oy.round(2)}] inner: #{is_inner?(ox, oy)}" if @debug

    ox2 = rcx - ((gap2[1] - gap1[1]) * rh / gl)
    oy2 = rcy + ((gap2[0] - gap1[0]) * rh / gl)
    res << [ox2, oy2] if @result_is_inner == is_inner?(ox2, oy2)
    p "Coords 2: [#{ox2.round(2)}, #{oy2.round(2)}] inner: #{is_inner?(ox2, oy2)}" if @debug

    res
  end

  def intersection_2circles(r2, r1, p2, p1)
    # get d
    d = get_side_real_length(p1, p2)
    #p "d: #{d}" if @debug

    # circles are not intersecting
    if (r1 + r2) < d
      p "Not intersecting" if @debug

      o = r1 + (d - (r1 + r2)) / 2
      p0x = p1[0] + (o * (p2[0] - p1[0]) / d)
      p0y = p1[1] + (o * (p2[1] - p1[1]) / d)

      return [[p0x, p0y]]
    end

    # get b part
    b = (r2**2 - r1**2 + d**2) / (2 * d)
    #p "b: #{b}" if @debug

    # get a part
    a = d - b

    # get h
    h = Math.sqrt(r2**2 - b**2)
    #p "h: #{h}" if @debug

    # get p0
    p0x = p1[0] + (a * (p2[0] - p1[0]) / d)
    p0y = p1[1] + (a * (p2[1] - p1[1]) / d)

    # get p3
    p3x = p0x + ((p2[1] - p1[1]) * h / d)
    p3y = p0y - ((p2[0] - p1[0]) * h / d)
    #p "p3: [#{p3x},#{p3y}]"

    # get p4
    p4x = p0x - ((p2[1] - p1[1]) * h / d)
    p4y = p0y + ((p2[0] - p1[0]) * h / d)
    #p "p4: [#{p4x},#{p4y}]"

    [[p3x, p3y],[p4x, p4y]]
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

    #s = signals[0] + signals[1] + signals[2]

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
    printf format, "", "1", "2", "3", "sum" if @debug

    ang_sum = 0.0
    fls1, fls2, fls3 = starts

    shift = 0
    shift_step = 10
    pereval = true
    cnt = 0
    ang1_outer = false; ang2_outer = false; ang3_outer = false
    #while cnt < 40 do
    while ang_sum.round(2) != 360.0 do
      fls1 += shift; fls2 += shift; fls3 += shift

      ang1 = get_angle_by_3sides(sides[0], sides[1], fls1)
      ang2 = get_angle_by_3sides(sides[1], sides[2], fls2)
      ang3 = get_angle_by_3sides(sides[2], sides[0], fls3)

      ang1_val = (ang1_outer ? (360 - ang1) : ang1)
      ang2_val = (ang2_outer ? (360 - ang2) : ang2)
      ang3_val = (ang3_outer ? (360 - ang3) : ang3)
      ang_sum = ang1_val + ang2_val + ang3_val

      printf format, "#{shift}", "#{"*" if ang1_outer}#{fls1.round(2)} - #{ang1_val.round(2)}", "#{"*" if ang2_outer}#{fls2.round(2)} - #{ang2_val.round(2)}", "#{"*" if ang3_outer}#{fls3.round(2)} - #{ang3_val.round(2)}", "#{ang_sum}" if @debug

      if ang1.zero? or ang2.zero? or ang3.zero?
        if pereval # in this case we think that this are first rough reduces
          shift = -(shift_step)
        else # this case for outer point
          ang1_outer = true if ang1.zero?
          ang2_outer = true if ang2.zero?
          ang3_outer = true if ang3.zero?

          pereval = !pereval
          shift = -(shift_step)
        end
        cnt += 1
        next
      end

      if ang1_outer or ang2_outer or ang3_outer
        conds = "ang_sum.round(2) >= 360.0"
      else
        conds = "ang_sum.round(2) < 360.0"
      end

      if eval(conds)
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

      if cnt > 40
        return [0,0,0]
      end
      cnt += 1
    end

    @result_is_inner = false if ang1_outer or ang2_outer or ang3_outer

    [ang1_val, ang2_val, ang3_val]
  end

  def is_inner?(px, py)
    pp = [px, py]
    s = square(@ap1, @ap2, pp) + square(@ap2, @ap3, pp) + square(@ap3, @ap1, pp)
    (square(@ap1, @ap2, @ap3) - s).abs <= 0.01
  end

  def square(a, b, c)
    #p "Ax: #{a[0]}, Ay: #{a[1]}"
    #p "Bx: #{b[0]}, By: #{b[1]}"
    #p "Cx: #{c[0]}, Cy: #{c[1]}"

    res = b[0]*c[1] - c[0]*b[1] - a[0]*c[1] + c[0]*a[1] + a[0]*b[1] - b[0]*a[1]
    res.abs / 2.0
  end

  def get_3nearest(res_points)
    points = []; res = []
    res_points.each_with_index do |p, index|
      points << [p[0], p[1], index]
    end

    kd = Kdtree.new(points)

    nearests = []
    res_points.each do |p|
      nearests << kd.nearestk(p[0], p[1], 3)
    end

    #p res_points
    #p nearests
    indices = dup_indices(nearests)
    #p indices

    nearest3 = indices.values.select{|v| v.count == 3}.first
    nearest3 = nearests[indices.values.first[0]] unless nearest3
    #p nearest3

    nearest3.each do |n|
      res << res_points[n]
    end if nearest3

    res
  end

  def get_centroid(p)
    rx = (p[0][0] + p[1][0] + p[2][0]) / 3
    ry = (p[0][1] + p[1][1] + p[2][1]) / 3

    [rx, ry]
  end

  def dup_indices(arr)
    a = arr.dup
    a.map{|i| i.sort!}

    dup_indices = Hash.new {|h,k| h[k]=[]}
    a.each_index {|i| dup_indices[a[i]] << i unless 1 == a.count(a[i])}
    dup_indices
  end
end
