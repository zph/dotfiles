require "optparse"
require "uri"
require "net/http"

duration = 10
per_second = 10

opts = OptionParser.new do |opts|
  opts.banner = "Usage: bench_web [options] url"

  opts.on("-t", "--time TIME", OptionParser::DecimalInteger, "Duration to run the test in seconds (default 10)") do |t|
    duration = t
  end

  opts.on("-p", "--per-second REQUESTS", OptionParser::DecimalInteger, "Max number of requests per second (default 10)") do |t|
    per_second = t.to_f
  end

end

opts.parse!

if ARGV.length != 1
 puts opts.banner
 puts
 exit(1)
end


uri = begin
        URI(ARGV[0])
      rescue
        puts opt.banner
        puts
        puts "Invalid URL"
        puts
        exit(1)
      end

GC.disable

finish_time = Time.now + duration
results = []
while (start=Time.now) < finish_time
  res = Net::HTTP.get_response(uri)
  req_duration = Time.now - start
  results << {duration: req_duration, code: res.code, length: res.body.length}

  GC.enable
  GC.start
  GC.disable

  padding = (1 / per_second.to_f) - (Time.now - start)
  if padding > 0
    sleep padding
  end
  putc "."
end

GC.enable

puts
puts "Results"
puts "Total duration: #{duration} second#{duration==1?"":"s"}"
puts "Total requests: #{results.length}"

summary = results.group_by{|r| r[:code]}.map{|code, array| [code, array.count]}.sort{|a,b| a[1] <=> b[1]}

failures = summary.map{|code, count| code == "200" ? 0 : count}.inject(:+)

if failures > 0
 puts "Estimated downtime: #{((failures.to_f * (1.to_f / per_second)) * 1000).to_i}ms"
end

puts
puts "By status code: #{summary.map{|code,count| "[#{code}]x#{count} "}.join}"

puts ""

puts "Percentage of the successful requests served within a certain time (ms)"

good_requests = results.find_all{|r| r[:code] == "200"}.map{|r| r[:duration]}.sort

if good_requests.length > 0
  [25,50,66,75,80,90,95,98,99,100].map{ |percentile|
    time = good_requests[((percentile.to_f / 100.0) * (good_requests.length-1)).to_i]
    puts "  #{percentile}%\t\t#{(time * 1000).to_i}"
  }
end
