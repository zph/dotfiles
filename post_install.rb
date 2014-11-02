#!/usr/bin/env ruby

require 'fileutils'
require 'pathname'

UNAME = `uname -a`

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
  Dir.chdir(File.expand_path("~/dotfiles")) do |dir|
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
  filename = file.split("/").last.split(".").first
  pathname = Pathname.new(file)
  remove_symlinks_and_relink(filename, pathname.dirname, File.join("~/bin", filename))
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

def bring_in_vim_plugins
  `infect`
end

def you_complete_me_setup
  you_complete_me_dir = Dir["home/.vim/bundle/youcompleteme"].first
  return unless you_complete_me_dir

  Dir.chdir(File.expand_path you_complete_me_dir) do |dir|

    `git submodule update --init --recursive`
    unless File.exists?('python/ycm_core.so')
      system "./install.sh"
    else
      puts "YouCompleteMe already installed"
    end
  end
end

def main
  clone_submodules
  ensure_homesick_is_installed

  system "homesick symlink ~/dotfiles"

  install_os_specific_binaries

  bring_in_vim_plugins
  you_complete_me_setup
end

main
