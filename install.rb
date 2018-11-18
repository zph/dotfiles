#!/usr/bin/env ruby

require 'fileutils'
require 'pathname'

UNAME = `uname -a`
DOTFILES = "$HOME/.homesick/repos/dotfiles"
REPO = "git@github.com:zph/zph.git"
HOMESICK="$HOME/.homesick/repos/homeshick/bin/homeshick"

def is_osx?
  !! UNAME[/Darwin/]
end

def is_linux?
  !! UNAME[/Linux/]
end

def remove_symlinks_and_relink(file, source, dest)
  FileUtils.rm_rf(File.expand_path(File.join(dest, file)))
  puts "Removing dead symlinks"
  FileUtils.ln_s(File.expand_path(File.join(source, file)), File.expand_path("#{dest}"), :force => true)
  puts "Creating symlink for #{dest}"
end

def clone_submodules
  Dir.chdir(File.expand_path(DOTFILES)) do |dir|
    system "git submodule init"
    system "git submodule update"
  end
end

def ensure_homesick_is_installed
  require 'open3'
  _, status = Open3.capture2('which homesick')
  unless status.exitstatus == 0
    `gem install homesick`
  end
end

def os_specific_binaries(os)
  files = Dir["os_specific_binaries/#{os}/*"]
  files.map { |f| File.expand_path(f) }
end

def link_file(file)
  old_filename = file.split("/").last
  filename = old_filename.split(".").first
  pathname = Pathname.new(file)
  remove_symlinks_and_relink(old_filename, pathname.dirname, File.join("~/bin", filename))
  `chmod +x #{File.join("~/bin", filename)}`
end

def install_os_specific_binaries
  case
  when is_osx?
    os_specific_binaries("osx").each {|f| link_file(f) }
  when is_linux?
    os_specific_binaries("linux").each {|f| link_file(f) }
  when is_bsd?
    os_specific_binaries("bsd").each {|f| link_file(f) }
    warn "Many golang bins don't supply BSD compiled variants."
  end
end

def main
  system "git clone #{REPO} #{DOTFILES}"
  system "git clone git://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick"

  system "#{HOMESICK} link #{DOTFILES}"

  system "bash #{DOTFILES}/linker.sh"
  case
  when is_osx?
    system "cd #{DOTFILES}/home/.config/brewfile && brew bundle"
  else
    puts "OS unsupported for easy install please read Brewfile for which tools are helpful"
  end
end

main
