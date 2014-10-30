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

module Funcs
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

    ang_sum = 0
    fls1, fls2, fls3 = starts

    shift = 0
    shift_step = 10
    pereval = true
    while ang_sum.round(2) != 360.0 do
      fls1 += shift; fls2 += shift; fls3 += shift

      ang1 = get_angle_by_3sides(sides[0], sides[1], fls1)
      ang2 = get_angle_by_3sides(sides[1], sides[2], fls2)
      ang3 = get_angle_by_3sides(sides[2], sides[0], fls3)
      ang_sum = ang1 + ang2 + ang3

      printf format, "#{shift}", "#{fls1.round(2)} - #{ang1.round(2)}", "#{fls2.round(2)} - #{ang2.round(2)}", "#{fls3.round(2)} - #{ang3.round(2)}", "#{ang_sum.round(2)}"

      if ang1.zero? or ang2.zero? or ang3.zero?
        shift = -(shift_step)
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
          pereval = true
        end
        shift = -(shift_step)
      end
    end

    [ang1, ang2, ang3]
  end
end
