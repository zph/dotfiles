#!/usr/bin/env ruby
#
# Turn normal git items into submodules

# Dir.glob("../.vim/bundle/*").each do |repo|

# end
require 'pry'
Dir.glob("home/.vim/bundle/*").each do |repo|
  next if repo =~ /vimrepress/
  messy_remote = `(cd #{repo} && git remote -v)`
  puts messy_remote
  # binding.pry
  rough_remote = messy_remote.split("\n")[0].split("\t")[1]
  remote = rough_remote.split[0].gsub(/https?/, 'git')
  puts remote
  `git submodule add #{remote} #{repo}`
end
