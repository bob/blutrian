require 'rubygems'
require 'mysql2'
require File.expand_path('../processor', __FILE__)
require File.expand_path('../../blubase/app/models/api/avans', __FILE__)

@points = ['AP1', 'AP2', 'AP3', 'AP4', 'AP9']

def results_period(date, start, finish)
  dt1 = Time.parse("#{date} #{start}").strftime("%Y-%m-%d %H:%M:%S")
  dt2 = Time.parse("#{date} #{finish}").strftime("%Y-%m-%d %H:%M:%S")

  sql = "
    SELECT
      DISTINCT drl.device_address,"

  concats = []
  @points.each_with_index do |ap, i|
    concats << "CONCAT(t#{i}.rssi, ' (', t#{i}.cnt, ')') AS '#{ap}'"
  end
  sql += concats.join(", ")
  sql += "FROM discovery_raw_logs AS drl "

  @points.each_with_index do |ap, i|
    sql += "
      LEFT JOIN (
        SELECT DISTINCT device_address, MAX(rssi) as rssi, hotspot_id, COUNT(rssi) AS cnt
        FROM discovery_raw_logs WHERE discovered_at >= '#{dt1}' AND discovered_at <= '#{dt2}' AND hotspot_id = #{eval("Processor::#{ap}")} GROUP BY device_address
      ) AS t#{i} ON drl.device_address = t#{i}.device_address AND t#{i}.cnt > 3
    "
  end

  sql += "
    WHERE drl.discovered_at >= '#{dt1}' AND drl.discovered_at <= '#{dt2}'
      AND drl.device_address NOT IN(#{inner_devices_sql(date)})"

  #p sql.gsub(/\n/, "")

  results = @client.query(sql)
end

def inner_devices_sql(day)
  "
  SELECT device_address
  FROM (
    SELECT device_address, (MAX(UNIX_TIMESTAMP(discovered_at)) - MIN(UNIX_TIMESTAMP(discovered_at))) AS dur
    FROM discovery_raw_logs
    WHERE day = '#{day}'
    GROUP BY device_address
  ) t2
  WHERE dur >= 36000
  "
end

def process_period(start, finish)
  # get macs matched on defined five units
  results = results_period('2014-11-27', start, finish)

  cnt = 0
  results.each(:as => :array) do |row|
    mac = row.shift
    # handle only macs matched on 4 or 5 units simultaneously
    next unless row.compact.count > 3

    values = {}
    row.each_with_index do |r, i|
      next unless r

      rssi, c = r.scan(/(\d+)\s\((\d+)\)/)[0]
      #p "#{i}. rssi: #{rssi}, count: #{c}"

      values[i] = {:rssi => rssi.to_i, :count => c.to_i}
    end

    # get 3 units with most number of matches
    top3 = values.sort_by{ |k, v| v[:count] }.last(3)
    #p top3

    vertexes = []
    vertexes[0] = eval("Processor::#{@points[top3[0][0]]}"); a = top3[0][1][:rssi]
    vertexes[1] = eval("Processor::#{@points[top3[1][0]]}"); b = top3[1][1][:rssi]
    vertexes[2] = eval("Processor::#{@points[top3[2][0]]}"); c = top3[2][1][:rssi]

    p "#{vertexes.join('/')}, a: #{a}, b: #{b}, c: #{c}"

    @processor.vertexes = vertexes
    @processor.run a, b, c

    #break if cnt == 10
    cnt += 1
  end



  #processor.canvas.display

  p "All: #{results.count}, Calculate: #{cnt - 1}"
end

@client = Mysql2::Client.new(
  :database => 'blubase',
  :username => 'root',
  :password => '',
  :host     => 'localhost')

@processor = Processor.new
results_path = "./results/2014-11-27"
Dir.foreach(results_path) {|f| fn = File.join(results_path, f); File.delete(fn) if f != '.' && f != '..'}

Api::Avans::PERIODS.each do |period|
  start, finish = period

  @processor.canvas = ImageFuncs.new("./img/avans-map-cell.jpg", @processor.aps.values)
  process_period(start, finish)

  #processor.canvas.scale(0.5)
  @processor.canvas.write "#{results_path}/#{start}-#{finish}.jpg"
end




