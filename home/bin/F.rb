#!/usr/bin/env ruby
# Ruby replacement for F, which is a ~/bin/F for github.com/zph/sack
# Which was created by another author and tweaked by @ZPH
def main
  args = ARGV
    sack_shortcuts = File.open(File.expand_path "~/.sack_shortcuts").readlines.map(&:chomp)
  case args.count
  when 0
    sack_shortcut = sack_shortcuts[0]
    system "$EDITOR +#{sack_shortcut}"
  when 1
    sack_shortcut = sack_shortcuts[args.first.to_i - 1]
    system "$EDITOR +#{sack_shortcut}"
  else
    vim_commands = args.map.with_index do |value, index|
      current_sack = sack_shortcuts[index + 1]
      line_no = current_sack.split[0]
      filename = current_sack.split[1]
      command = [
      "-c ",
      "'tabe +#{line_no} #{filename}'"
      ].join
    end.reverse

    complete_command = "$EDITOR #{vim_commands.join(" ")} -c 'tabclose 1'"
    puts complete_command
    system complete_command
  end
rescue => e
  raise e, "Something went wrong"
  exit 1
end

main
