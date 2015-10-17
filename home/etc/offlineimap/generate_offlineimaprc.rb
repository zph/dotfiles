#!/usr/bin/env ruby

require 'erb'

file = File.read("offlineimaprc.erb")

vars = [
  'SHORT_NAME',
  'EMAIL',
  'LOCAL_FOLDERS',
  'SERVER',
]

def get_ca_bundle
  `find /usr/local/Cellar/curl-ca-bundle -type f -iname ca-bundle.crt`.split("\n").reject(&:empty?)
end

CA_BUNDLE = get_ca_bundle.first
SHORT_NAME, EMAIL, LOCAL_FOLDERS, SERVER = ENV.values_at(*vars)
output = ERB.new(file).run(binding)
