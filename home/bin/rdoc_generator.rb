#!/usr/bin/env ruby

`gem list | cut -d'(' -f1`.split("\n").map(&:rstrip).each { |g| `gem rdoc #{g} --rdoc --overwrite` ; puts "#{g} rdoc generated"}
