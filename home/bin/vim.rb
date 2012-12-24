require 'formula'

class Vim < Formula
  homepage 'http://www.vim.org/'
  url 'https://vim.googlecode.com/hg/', :revision => '6c318419e331'
  version '7.3.515'

  def features; %w(tiny small normal big huge) end
  def interp; %w(lua mzscheme perl python python3 tcl ruby) end

  def options
    [
      ["--with-features=TYPE", "tiny, small, normal, big or huge (default: normal)"],
      ["--enable-interp=NAME,...", "lua, mzscheme, perl, python, python3, tcl and/or ruby (default:python,ruby)"]
    ]
  end

  def install
    def opt_val(opt)
      opt.sub(/.*?=(.*)$/, "\\1") rescue nil
    end

    opts = []
    feature = opt_val(ARGV.find {|s| s =~ /^--with-features=/ }) || "normal"
    # For compatibility and convenience {{{
    feature_shorthand = features.find {|f| ARGV.include? "--#{f}" }
    feature = feature_shorthand if feature_shorthand
    # }}}
    opts << "--with-features=#{feature}"
    opts << "--with-macarchs=i386"

    interps = opt_val(ARGV.find {|s| s =~ /^--enable-interp=/ }) || "python,ruby"
    interps = interps.split(/,/)
    # For compatibility and convenience {{{
    interp.each do |i|
      if ARGV.include? "--#{i}"
        interps << i
      end
    end
    # }}}
    interps.uniq!
    interps.each do |i|
      opts << "--enable-#{i}interp=yes"
      opts << "--with-lua-prefix=/usr/local" if i == "lua"
    end

    system "./configure",
      "--disable-gui",
      "--without-x",
      "--disable-nls",
      "--disable-gpm",
      "--disable-netbeans",
      "--disable-arabic",
      "--disable-farsi",
      "--disable-cscope",
      "--disable-emacs_tags",
      "--disable-keymap",
      "--disable-langmap",
      "--enable-feature=browse",
      "--with-tlib=ncurses",
      "--enable-multibyte",
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      *opts
    system "make install"
  end
end
