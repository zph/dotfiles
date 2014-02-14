#!/usr/bin/env ruby

require 'fileutils'

def remove_symlinks_and_relink(file, source, dest)
  FileUtils.rm_rf(File.expand_path("#{dest}#{file}"))
  puts "Removing dead symlinks"
  FileUtils.ln_s(File.expand_path("#{source}#{file}"), File.expand_path("#{dest}#{file}"), :force => true)
  puts "Creating symlink for #{dest + file}"
end

Dir.chdir(File.expand_path("~/dotfiles")) do |dir|
  system "git submodule init"
  system "git submodule update"
end

system "homesick symlink ~/dotfiles"

%w[sack sag F].each do |file|
 remove_symlinks_and_relink(file, "~/bin_repos/sack/", "~/bin/")
end

remove_symlinks_and_relink("sack.zsh", "~/bin_repos/sack/", "~/.zsh.d/")

# recompile YouCompleteMe
you_complete_me_dir = Dir["home/.vim/bundle/youcompleteme"].first
Dir.chdir(File.expand_path you_complete_me_dir) do |dir|
 system "./install.sh"
end

