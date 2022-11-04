#!/usr/bin/env ruby

require 'json'
require 'shellwords'

class String
  def promote_shell_happiness
    self.gsub(/@/, '_at_').gsub(/[[:punct:]]/, '_').gsub(/ /, '-').downcase
  end
end

def format_entries(entries)
  entries.map do |entry|
    default = ->(){ {value: ""} }

    title = entry.fetch(:title, '').promote_shell_happiness
    next unless entry[:typeName] == "webforms.WebForm"
    pass = {}

    pass[:name] = title
    pass[:title], pass[:location] = entry.values_at(:title, :location)
    contents      = entry[:secureContents]
    fields        = contents[:fields]
    pass[:notes]  = contents[:notesPlain]

    pass[:password] = fields.detect(default) { |f| f[:name] == "password" }[:value]
    pass[:login]    = fields.detect(default) { |f| f[:name] == "username" }[:value]
    pass[:one_password] = entry
    pass
  end
end

def puts_unless_empty(io, prefix_string, arg)
  return if arg.nil? || arg.empty?
  io.puts [prefix_string, arg].join(" ")
end

def insert_entry(entry)
  name, pw, login, url, notes = Hash(entry).values_at(:name, :password, :login, :url, :notes)
  # Make sure entries are unique... same name + '-f' means overwriting entries :(
  name_with_uuid = [login, name, entry[:one_password][:uuid]].reject(&:empty?).map(&:promote_shell_happiness).join("-").squeeze("-")
  puts name_with_uuid
  command = ["pass insert",
             "-f", "-m", name_with_uuid.shellescape, "> /dev/null"].join(" ")

  IO.popen(command, "w") do |io|
    io.puts pw
    puts_unless_empty(io, "LOGIN=", login)
    puts_unless_empty(io, "URL=", url)
    puts_unless_empty(io, "NOTES=", notes)
    io.puts "DATA=#{entry.to_json}"
  end

  if $? == 0
    puts "Imported #{name_with_uuid}"
  else
    $stderr.puts "ERROR: Failed to import #{name_with_uuid}"
  end
end

def main
  file = ARGV.first || "data.1pif"

  content = File.read(file)

  json_entries_txt = content.split(/\n\*\*\*.{,36}\*\*\*\n/)

  xs = json_entries_txt.map do |i|
         JSON.parse(i, symbolize_names: true)
       end.reject(&:nil?)

  entries = format_entries(xs)
  entries.each { |i| insert_entry i }
end

main
