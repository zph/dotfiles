#!/usr/bin/env ruby

# TODO:
# - learn to install default gems || create standalones automatically
#
require 'fileutils'

def remove_symlinks_and_relink(file, source, dest)
  FileUtils.rm_rf(File.expand_path("#{dest}#{file}"))
  puts "Removing dead symlinks"
  FileUtils.ln_s(File.expand_path("#{source}#{file}"), File.expand_path("#{dest}"), :force => true)
  puts "Creating symlink for #{dest}"
end

Dir.chdir(File.expand_path("~/dotfiles")) do |dir|
  system "git submodule init"
  system "git submodule update"
end

def ensure_homesick_is_installed
  require 'open3'
  _, status = Open3.capture2('which homesick')
  unless status.exitstatus == 0
    `gem install homesick`
  end
end

ensure_homesick_is_installed

system "homesick symlink ~/dotfiles"

if `uname`[/Darwin/]
  remove_symlinks_and_relink("sack", "~/bin_repos/go-sack/dist/", "~/bin/sack")
else
  remove_symlinks_and_relink("sack.linux_amd64", "~/bin_repos/go-sack/dist/", "~/bin/sack")
end

def bring_in_vim_plugins
  `infect`
end

bring_in_vim_plugins
#
# recompile YouCompleteMe
you_complete_me_dir = Dir["home/.vim/bundle/youcompleteme"].first
Dir.chdir(File.expand_path you_complete_me_dir) do |dir|

  `git submodule update --init --recursive`
  unless File.exists?('python/ycm_core.so')
    system "./install.sh"
  else
    puts "YouCompleteMe already installed"
  end
end

