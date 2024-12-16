#!/usr/bin/env ruby

class String
  ENCODING_OPTS = {invalid: :replace, undef: :replace, replace: '', universal_newline: true}
  def remove_non_ascii
    self.encode(Encoding.find('ASCII'), ENCODING_OPTS)
  end
end

def swallow_errors
  begin
    yield
  rescue
  end
end

SHELL_ALIAS_EXTRACTOR = ->(a, obj) do
  array = a.split("=", 2)
  obj[array[0]] = array[1].gsub(/['"]?/, '')
end

GIT_ALIAS_EXTRACTOR   = ->(a, obj) do
  array = a.split(" ", 2)
  obj[array[0].gsub(/alias\./, '')] = array[1]
end

def generic_alias_extractor(aliases, func)
  aliases.each_with_object({}) do |a, obj|
    swallow_errors do
      func.call(a, obj)
    end
  end
end

def extract_shell_aliases(aliases, func = SHELL_ALIAS_EXTRACTOR)
  generic_alias_extractor(aliases, func)
end

def extract_git_aliases(aliases, func = GIT_ALIAS_EXTRACTOR)
  generic_alias_extractor(aliases, func)
end

def remove_duplicates(a)
  # HACK:
  # TODO: clean up original implementation so method's unneccessary

  arr = a.split

  arr.map.with_index do |e, i|
    case
    when (i + 1) == arr.length # last element in array
      e
    when e == arr[i + 1]
      nil
    else
      e
    end
  end
end

def expand_word(item, prior_match, sa, ga)
  return item if prior_match == item
  case
  when sa[item]
    cmd = sa[item]
    arr = expand_line(cmd, item, sa, ga)
    remove_duplicates(arr)
  when ga[item]
    ga[item]
  else
    item
  end
end

def expand_line(line, prior_match, sa, ga)
  line.split.map do |item|
    expand_word(item, prior_match, sa, ga)
  end.join(" ")
end

def expand_history(history, shell_aliases, git_aliases)
  history.map do |line|
    expand_line(line, false, shell_aliases, git_aliases)
  end
end

def get_history!(shell)
  [
    %x(cat ~/.#{shell}_history),
    %x(#{shell} -i -c 'alias'),
    %x(git config --get-regexp alias*),
    %x`atuin history list --format '{command}'`,
  ].map { |i| i.remove_non_ascii.chomp.split("\n") }
end

def retrieve_aliases!(shell = ENV['SHELL'])
  bin = case shell
        when /zsh/i
          'zsh'
        when /bash/i
          'bash'
        when /fish/i
          'fish'
        else
          warn "YOLO: Unknown shell"
          shell.split("/").last
          exit if shell.empty?
        end

  get_history!(bin)
end

def print_history!(history, io = STDOUT)
  history.each do |arr|
    begin
      io.puts "#{arr[1]}: #{arr[0]}"
    rescue Errno::EPIPE
      exit(74)
    end
  end
end

def main
  shell_history, shell_aliases, git_aliases = retrieve_aliases!(ENV['SHELL'])

  shell_aliases = extract_shell_aliases(shell_aliases)

  git_aliases = extract_git_aliases(git_aliases)

  # If nesting aliases deeper than this, fix that issue :P
  # TODO: fix incorrect double replaces,
  # - ie double replacing 'grep' on each round through expansion
  history = expand_history(shell_history, shell_aliases, git_aliases)

  history_count = Hash.new(0)

  history.each { |item| history_count[item] += 1 }

  sorted_history = history_count.sort_by { |k,v| v }.reverse
end

history = main

print_history!(history)
