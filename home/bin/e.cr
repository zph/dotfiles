#!/usr/bin/env crystal
# To build, `crystal build e.cr --release --static -o ~/bin_local/e`
# crystal rewrite of ruby recreation of `bin/e`

require "option_parser"

class E
  @input : String

  def initialize(args)
    # @options = parse(args)
    @input = if args.empty?
               ""
             else
               args[0].to_s
             end
  end

  def input
    @input
  end

  def has_linenumber?
    !!/:\d+/.match(input)
  end

  def home
    ENV["HOME"]
  end

  def vim_command_for_linenumber
    [filename_without_linenumber, "+#{ linenumber }"].join(" ")
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
    stdout = IO::Memory.new
    process = Process.new("fasd", [input], output: stdout)
    status = process.wait
    !stdout.to_s.chomp.empty?
  end

  def exec_editor(args = "")
    vim = has_bin?("nvim") ? `which nvim`.chomp : `which vim`.chomp
    Process.exec("bash", ["-c", vim + " " + args])
  end

  def fzf_preview
    # Try bat, highlight, coderay, rougify in turn, then fall back to cat
    %{
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
    # # when has_fasd? && options.interactive
    # #   fasd_filename = `fasd -sia #{input}`.chomp
    # #   exec_editor(fasd_filename)
    when has_fasd? && has_fasd_result?
      Process.exec("bash", ["-c", "fasd -a -e $EDITOR #{input}"])
    # when has_ffind?
    #   files = `ffind #{input}`.chomp.split("\n")
    #   puts "Editing: #{files.first}"
    #   exec_editor([files.first])
    else
      error_message
    end
  end

  def filename_without_linenumber
    input.split(":", 2).first
  end

  def linenumber
    @input.split(":", 2)[1]
  end

  # def parse(args)
  #   options = OpenStruct.new
  #   options.interactive = nil

  #   opts = OptionParser.new do |opts|
  #     opts.banner = "Usage: e [options]"

  #     opts.separator ""
  #     opts.separator "Specific options:"

  #     # Mandatory argument.
  #     # opts.on("-i", "--interactive [true/false]", "Interactive!") do { |lib|
  #     #   options.interactive = lib.downcase.to_sym
  #     # end

  #   end

  #   opts.parse!(args)
  #   options
  # end

  def error_message
    msg = "Can't find path with normal or extraordinary methods"
    puts msg
    puts "Exiting..."
    exit(1)
  end
end

E.new(ARGV).execute()
