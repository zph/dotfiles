#!/usr/bin/env ruby

# Hard override assuming we don't have permissions on default bundler location

ENV['GEM_HOME'] = '~/.ruby/vendor/bundle'
require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'git-smart', github: 'zph/git-smart'
end

# Use forked repo due to lack of maintenance on main repo

def main
  cmd = ARGV.shift
  case cmd
  when 'pull', 'merge', 'log' then GitSmart.run("smart-#{cmd}", ARGV)
  else
    puts "Received unknown command #{cmd} when only pull, smart, and log are valid"
    exit(1)
  end
end

main
