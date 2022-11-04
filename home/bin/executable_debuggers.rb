#!/usr/bin/env ruby

pwd = Dir.pwd

require_pry_binding_pry = %w[require 'pry' ; binding.pry]

DEBUG_REGEXES = [
                  %r{\Abinding\.pry},
                  %r(#{require_pry_binding_pry.join("\\w?")}),
                  %r{\bdebugger\b},
                  %r{console\.log\(?}
                ]

FILE_TYPES = %w[rb coffee js]
def scan_for_debug_statements(file, regexes = DEBUG_REGEXES)
  file_content = File.read(file)
  regexes.each do |regex|
    if file_content[regex]
      puts "Offender: #{file} - #{file_content[regex]}"
    end
  end
end

count = 0
Dir["#{ENV['HOME']}/source/**/*.{#{FILE_TYPES.join(",")}}"].each do |file|
# Dir["#{File.expand_path(Dir.pwd)}/**/*.{#{FILE_TYPES.join(",")}}"].each do |file|
  next if file[/vendor/]
  begin
    scan_for_debug_statements(file)
  rescue => e
    puts "Error: #{e}"
  end
end
