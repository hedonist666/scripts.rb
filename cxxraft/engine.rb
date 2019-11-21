#!/usr/bin/env ruby

require_relative "./sourcefile.rb"
require 'yaml'
require 'fileutils'

HOMEDIR = File.join Dir.home, ".cxxraft"
$curdir = Dir.new "."
$sources = []

def load_parse(fname, y = nil)
  puts "loading and parsing config..."
  y ||= YAML.load File.read fname
  if y[:sources]
    y[:sources].each do |name, s|
      s[:name] = name
      $sources << (Source.new s)
    end
  end
  unless File.exists? File.join $curdir, "/scr.sh"
    puts "creating scr.sh..."
    FileUtils.copy_file (File.join HOMEDIR, "scrs", y[:scr]), 
      (File.join $curdir, "scr.sh")
  end
end

def add_source(fname, h)
  puts "[internals]: adding source #{h[:name]} with config #{fname}"
  y = YAML.load File.read fname
  y[:sources] = {} unless y[:sources]
  abort "source file already exists" if y[:sources].include? h[:name]
  $sources << (Source.new h)
  name = h[:name]
  h.delete :name
  y[:sources][name] = h   
  File.write fname, y.to_yaml 
end

#binding.irb
