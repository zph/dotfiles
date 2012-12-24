#!/usr/bin/env ruby
require 'nokogiri'
require 'open-uri'
#
# Download and replace current Metes and Bounds App

DL_LINK = "http://www.tabberer.com/sandyknoll/files/MetesandBoundsOSX.dmg"
DMG_NAME = DL_LINK.split('/')[-1]
APP_NAME = "Metes and Bounds.app"
DL_DESTINATION = "#{ENV['HOME']}/Downloads/#{DMG_NAME}"
APP_DIR = "/Applications/#{APP_NAME}"
VOLUME_DIR = "/Volumes/MetesandBoundsOSX"

def get_version
  if Dir.exists?(APP_DIR)
    plist = Dir.glob("/Applications/Metes and Bounds.app/Contents/*.plist")[0]
    plist_content = Nokogiri::XML.parse(open(plist).read)
    version = "v#{plist_content.xpath('/plist/dict/string[5]').text}"
  end
end

def get_website_version
  # xpath_to_version = "/html/body/table[1]/tbody/tr[2]/td[3]/p/font[3]/text()"
  xpath_to_version = '/html/body/table[1]/tr[2]/td[3]/p/font[3]'
  web_link = "http://www.tabberer.com/sandyknoll/"
  webpage_content = open(web_link).read
  parsed_content = Nokogiri::HTML.parse(webpage_content)
  version = parsed_content.xpath(xpath_to_version).text.strip
end

class String
  def to_machine_format
    strip.gsub(/[v\.]?/, '')[0..2]
  end
end


def unmount_disk_image#
  `hdiutil eject #{VOLUME_DIR}` if Dir.exists?(VOLUME_DIR)
end

def display_versions
  puts "Current Version: #{@local_version || "Does not exist"}"
  puts "Newest Version: #{@website_version}"
end

def final_message
  puts "Updated Version from #{@local_version || "N/A"} to #{@website_version}"
end

def print_initial_version_and_remove_if_present
  if File.exists?(DL_DESTINATION)
    puts "Initial Version #{@local_version || "Not present"}"
    FileUtils.rm_r(DL_DESTINATION)
  end
end

def download_new_version
  `wget #{DL_LINK} -O #{DL_DESTINATION}`
  puts "Download Complete"
end
#
# Compare current version to website version
def compare_versions
  if @local_version && 
            (@local_version.to_machine_format >=  @website_version.to_machine_format)
    display_versions
    puts "You have the most recent version."
    puts "Exiting..."
    exit 0
  end
end

def mount_dmg
  # Mount DMG and keep the mount folder as output
  directory = `echo "Y" | $(which hdid) #{DL_DESTINATION}| tail -n 1 | cut -f3`.chomp
  puts "Mounted DMG Installation Image"
end

def remove_application
  FileUtils.rm_r(APP_DIR) if Dir.exists?(APP_DIR)
end

def move_new_version_into_app_dir
  source = Dir.glob("/Volumes/MetesandBoundsOSX/**/*.app")[0]
  FileUtils.cp_r(source, APP_DIR)
end

#######
# The def stops here but the inst. begins
#######

@local_version = get_version
@website_version = get_website_version

compare_versions

# Proceed if compare_versions doesn't terminate program
display_versions

puts "Proceeding to Update Metes and Bounds..."

unmount_disk_image

print_initial_version_and_remove_if_present

download_new_version

mount_dmg

remove_application

move_new_version_into_app_dir

final_message

# Cleanup
unmount_disk_image
