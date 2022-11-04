require 'rubygems'
require 'colortail'

Groupings = {

  # This default matching scheme
  'default' => [],
  
  # Matchers for syslog
  'syslog' => [ 
      { :match => /EMERGENCY/,    :color => :red,     :attribute => :reverse },
      { :match => /FATAL/,        :color => :red,     :attribute => :bright },
      { :match => /CRITICAL/,     :color => :red },
      { :match => /DEBUG/,        :color => :green },
      { :match => /ERROR/,        :color => :green },
      { :match => /INFO/,         :color => :none },
      { :match => /WARN/,         :color => :yellow }
  ]

}
