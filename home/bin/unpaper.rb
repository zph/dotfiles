#!/usr/bin/env ruby
#
# Author : tevic@civet.ws
# License: MIT
# Function: Wrapper for unpaper & imagemagick to allow easy conversions
# Date 2012.04.06
# Credits:
# Requirements:
  # Linux
  # unpaper
  # imagemagick
  # RMagick Ruby Gem 
  # Must 'mkdir /media/ramdisk' && add 'mount -t tmpfs -o size=500M tmpfs /media/ramdisk' to /etc/rc.local
  # => Source - http://neo4j.rubyforge.org/guides/configuration.html

# Commands in order
# convert INPUT.jpg -colorspace Gray OUTPUT.ppm
# unpaper --grayfilter-size 1,1 --grayfilter-step 1,1 --grayfilter-threshold 0.4 tmp.ppm tmp_out.ppm
# convert tmp_out.ppm final.jpg
#
# TODO
#
# use unix pipes instead of saving to hard drive, pipe STDIN / STDOUT to unpaper and from unpaper
# Implement RMagick conversions in memory
# Calculate image histograms to convert images based on prototypes (Range of 5 image styles)
# Localthresh command with very good though speckled results: bash localthresh -n yes -m 3 -r 35 -b 20 ../test_photos/IMG_2519.JPG IMG12.jpg
#   source: http://peterhansen.ca/blog/using-imagemagick-to-filter-page-scans.html
# Then run isonoise to remove flecks
#=======================================================
# Notes on RMagick
# case sensitive require 'RMagick'

require 'pry'
require 'systemu'
require 'pathname'
require 'RMagick'

# binding.pry
def process_file(file)
  tmp_dir = ("/media/ramdisk/" if File.exists?('/media/ramdisk'))  || "#{Dir.pwd}/"  
  full_name = Pathname.new(File.expand_path(file))
  name = full_name.basename.to_s.split(full_name.extname)[0]
  output_ppm = "#{tmp_dir}#{name}.ppm"
  improved_ppm = "#{tmp_dir}#{name}_improved.ppm"
  pdf_name = "#{name}.pdf"
  jpg_name = "bw_#{name}.jpg"
  intermediary_jpg = "#{tmp_dir}#{name}_tmp.jpg"
  intermediary_jpg2 = "#{tmp_dir}#{name}_tmp2.jpg"
  isonoise_location = File.expand_path("docs/isonoise")
  localthresh_location = File.expand_path("docs/localthresh")
  

# Commandline testing options for convert
#  -channel Red -threshold 70% -channel Blue -black-threshold 70% 

  convert_to_ppm = %Q(convert #{file} -colorspace Gray #{output_ppm})

  run_unpaper = %Q(unpaper --overwrite --grayfilter-size 1,1 --grayfilter-step 1,1 --grayfilter-threshold 2.0 #{output_ppm} #{improved_ppm})
  convert_to_pdf = %Q(convert #{improved_ppm} -compress zip #{pdf_name})
  localthresh = %Q(bash #{localthresh_location} -n yes -m 3 -r 35 -b 20 #{full_name} #{intermediary_jpg})
  isonoise = %Q(bash #{isonoise_location} #{intermediary_jpg} #{intermediary_jpg2})
  compress = %Q(convert #{intermediary_jpg2} -quality 10 #{jpg_name})
  pre_compress = %Q(convert #{full_name} -quality 20 #{full_name})
  # RMagick Methods for replacing system calls
  # rimage = Magick::Image::read(full_name)
  # gray_image = rimage.first.quantize(2, Magick::GRAYColorspace )
  # gray_image.write(output_ppm)

# RMagic Method to convert ppm to pdf
  # ppm_image = Magick::Image::read(improved_ppm)
  # ppm_image.write(pdf_name)

  def system_u(command)
   status, stdout, stderr = systemu(command)
   [status, stdout, stderr]
  end
  #binding.pry
  #
  # hack while testing to remove prior pdf
  File.unlink(pdf_name) if File.exists?(pdf_name)

  # puts %x[#{convert_to_ppm}]
  # puts %x[#{run_unpaper}]
  # puts %x[#{convert_to_pdf}]

  
# system_u("#{convert_to_ppm}")
#rimage = Magick::Image::read(full_name)
#gray_image = rimage.first.quantize(64, Magick::GRAYColorspace )
#gray_image.write(output_ppm)
#a = system_u("#{run_unpaper}")
#puts a
#system_u("#{convert_to_pdf}")
system_u("#{localthresh}")
system_u("#{isonoise}")
system_u("#{compress}")

  File.unlink(improved_ppm) if File.exists?(improved_ppm)

  File.unlink(output_ppm) if File.exists?(output_ppm)

  # Cleanup process
  # Clear ramdisk
  Dir.glob('/media/ramdisk/*').each { |f| File.unlink(f) } 

  end

if File.identical?(__FILE__, $0)
  
  input_jpg = ARGV[0].dup
  process_file(ARGV) if ARGV.is_a?(String)

  ARGV.each { |f| process_file(f) } if ARGV.is_a?(Array)
end


=begin
# Notes gathered from internet
#=======================================
# => Links
  http://www.imagemagick.org/discourse-server/viewtopic.php?f=1&t=7867&start=0
  http://www.imagemagick.org/discourse-server/viewtopic.php?f=1&t=16916&sid=a7cc7c8175c3af78ff0dd0486922821e&start=15
  http://stackoverflow.com/questions/9608279/cleaning-scanned-grayscale-images-with-imagemagick
  http://www.imagemagick.org/Usage/color_mods/#sigmoidal
  http://www.imagemagick.org/Usage/color_mods/#level
  http://www.simplesystems.org/RMagick/doc/constants.html#ColorspaceType

#!/bin/bash
#
# Digital Camera + This Software + Printer = A Document Photocopier
#
# Input:  pictures of B&W Text documents taken with a digital camera using
#         flash from about 3 feet away with no dark border around the page.
#
# Output1: b-file.tif (a very small B&W TIF file)
# Output2: g-file.jpg (a alternative grayscale file)
#
# If input is purely black and white,  Output1 should be better
# If input is not purely black and white, Output2 may be better
# Source: http://staff.washington.edu/corey/camscan/scancvt
# Corey Satten, corey @ cac.washington.edu, March 2007

do1 () {
   echo starting $1 1>&2
   BASE="${1##*/}"; NAME=${BASE%.[jJ][pP][gG]}; TMP1="t-$BASE"; TMP2="x-$BASE"
   trap 'rm -f "$TMP1" "$TMP2"; exit' 0 1 2 13 15
   CGQ="-colorspace gray -quality"
   CGT="-compress group4 -density 480x480"

   convert $CGQ 99 "$1" -resize 5120x5120 "$TMP2"
   convert $CGQ 99 "$1" -resize 1024x1024 -negate -blur 15,15 -resize 5120x5120 "$TMP1"
   composite $CGQ 99 -compose plus "$TMP2" "$TMP1" "$TMP1"
   convert $CGQ 60 "$TMP1" -normalize -level 50,85% "g-$BASE"
   convert $CGT "$TMP1" -normalize -threshold 85% "b-$NAME.tif"
   rm -f "$TMP1" "$TMP2"
}

# This tries to detect multiprocessors and run 2 conversions in parallel
# Move CPUS=1 after the test to effectively disable the test.
CPUS=1
if [ -f /proc/cpuinfo ] ;then
    CPUS=`grep ^processor /proc/cpuinfo | wc -l`
    if [ "$CPUS" -lt 2 ] ;then CPUS=1; fi
fi

for i in "$@"; do
   case $#/$CPUS in
    0/*) exit;;                                     # done
    1/*) do1 "$1"; shift;;                          # only one file to do
    */1) do1 "$1"; shift;;                          # only one cpu to use
      *) do1 "$1" & do1 "$2"; wait; shift; shift;;  # process 2 files at once
   esac
done

exit 0

__________________
ORsame source
==================
mogrify -format tif -colorspace gray -compress group4 -resize 5120x5120 -normalize -threshold 65% *.jpg 
=end
