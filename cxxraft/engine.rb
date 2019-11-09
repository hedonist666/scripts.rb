#!/usr/bin/env ruby

require "./sourcefile.rb"
require 'yaml'
require 'fileutils'

HOMEDIR = File.join Dir.home, ".cxxraft"
$curdir = Dir.new "."
$sources = []

def load_parse(fname)
  y = YAML.load File.read fname
  y[:sources].each do |name, s|
    s[:name] = name
    puts "creating file #{s[:name]}.."
    $sources << (Source.new s)
  end
  unless File.exists? File.join $curdir, "/scr.sh"
    FIleUilts.copy_file (File.join HOMEDIR, "scrs", y[:scr]), 
      (File.join $curdir, "scr.sh")
  end
end
