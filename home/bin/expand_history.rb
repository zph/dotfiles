#!/usr/bin/env ruby

class String
  ENCODING_OPTS = {invalid: :replace, undef: :replace, replace: '', universal_newline: true}
  def remove_non_ascii
    self.encode(Encoding.find('ASCII'), ENCODING_OPTS)
  end
end

# @zsh_history = %x(cat ~/.zsh_history |sed 's/\xc2\x91\|\xc2\x92\|\xc2\xa0\|\xe2\x80\x8e//' 2> /dev/null).split("\n")
# opts = {invalid: :replace, undef: :replace, replace: '', universal_newline: true}

def set_history_aliases(shell)
  [
    %x(cat ~/.#{shell}_history).remove_non_ascii.split("\n"),
    %x(#{shell} -i -c 'alias').remove_non_ascii.split("\n"),
    %x(git config --get-regexp alias*).remove_non_ascii.split("\n"),
  ]
end

case ENV['SHELL']
when /zsh/i
  shell_history, shell_aliases, git_aliases = set_history_aliases('zsh')
when /bash/i
  shell_history, shell_aliases, git_aliases = set_history_aliases('bash')
else
  warn "Unknown shell"
  exit(1)
end

SHELL_ALIASES = {}
shell_aliases.map do |a|
  begin
    array = a.split("=", 2)
    SHELL_ALIASES[array[0]] = array[1].gsub(/['"]?/, '')
  rescue
  end
end


GIT_ALIASES = {}
git_aliases.map do |a|
  array = a.split(" ", 2)
  GIT_ALIASES[array[0].gsub(/alias\./, '')] = array[1]
end

converted_history = shell_history.map do |line|
                      line.split.map do |item|
                        SHELL_ALIASES[item] || GIT_ALIASES[item] || item
                      end.join(" ")
                    end

# converted_history.each { |l| puts l }

history_count = Hash.new(0)

converted_history.each { |item| history_count[item] += 1 }

sorted_history = history_count.sort_by { |k,v| v }.reverse

all_items = sorted_history.each do |arr|
  begin
    $stdout.puts "#{arr[1]}: #{arr[0]}"
  rescue Errno::EPIPE
    exit(74)
  end
end
