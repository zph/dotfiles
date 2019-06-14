#!/usr/bin/env ruby
#
# ruby recreation of `bin/e`

# Load no gems beyond stdlib due to native extensions breaking
# and rebuilding between different ruby versions and chruby/system.
# Also should speed up script timing. ZPH
$LOAD_PATH.delete_if { |l| l[/\/(Site|gems|extensions)\//] }

require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

class E
  attr_accessor :options, :input
  def initialize(args)
    @options = parse(args)
    @input = String( args[0] )
  end

  def has_linenumber?
    !!input[/:\d+/]
  end

  def home
    ENV['HOME']
  end

  def vim_command_for_linenumber
    [filename_without_linenumber, "+#{ linenumber }"].join(' ')
  end

  def has_bin?(bin)
    system "which #{bin} > /dev/null"
  end

  def has_fasd?
    has_bin?("fasd")
  end

  def has_ffind?
    has_bin?("ffind")
  end

  def has_fasd_result?
    fasd_result = `fasd #{input}`.chomp
    !fasd_result.empty?
  end

  def exec_editor(args = "")
    vim = has_bin?("nvim") ? `which nvim`.chomp : `which vim`.chomp
    # vim = `which vim`.chomp
    exec "#{vim} #{args}"
  end

  def fzf_preview
    # Try bat, highlight, coderay, rougify in turn, then fall back to cat
    %W{
fzf --preview '[[ $(file --mime {}) =~ binary ]] &&
                 echo {} is a binary file ||
                 (bat --style=numbers --color=always {} ||
                  highlight -O ansi -l {} ||
                  coderay {} ||
                  rougify {} ||
                  cat {}) 2> /dev/null | head -500'
}
  end

  def execute
    case
    when input.empty? && has_bin?("fzf")
      exec_editor("$(#{File.join([home, "bin", "fzf_file_preview"])})")
    when input.empty?
      exec_editor("")
    when File.exists?(input), Dir.exists?(input)
      exec_editor(input)
    when has_linenumber?
      exec_editor(vim_command_for_linenumber)
    when has_fasd? && options.interactive
      fasd_filename = `fasd -sia #{input}`.chomp
      exec_editor(fasd_filename)
    when has_fasd? && has_fasd_result?
      exec "fasd -a -e $EDITOR #{input}"
    when has_ffind?
      files = `ffind #{input}`.chomp.split("\n")
      puts "Editing: #{files.first}"
      exec_editor(files.first)
    else
      error_message
    end
  end

  def filename_without_linenumber
    input.split(':', 2).first
  end

  def linenumber
    @input.split(':', 2)[1]
  end

  def parse(args)
    options = OpenStruct.new
    options.interactive = nil

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: e [options]"

      opts.separator ""
      opts.separator "Specific options:"

      # Mandatory argument.
      opts.on("-i", "--interactive [true/false]", "Interactive!") do |lib|
        options.interactive = lib.downcase.to_sym
      end

    end

    opts.parse!(args)
    options
  end

  def error_message
    msg = "Can't find path with normal or extraordinary methods"
    warn msg
    warn "Exiting..."
    exit(1)
  end
end

E.new(ARGV).execute
