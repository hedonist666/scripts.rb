#!/usr/bin/env ruby

require_relative "./sourcefile.rb"
require 'yaml'
require 'fileutils'

#HOMEDIR = File.join Dir.home, ".cxxraft"
HOMEDIR = File.join __dir__, "materials"
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
    scrsh y
  end
  return nil
end

def scrsh(y)
  puts "creating scr.sh..."
  FileUtils.copy_file (File.join HOMEDIR, "scrs", y[:scr]), 
    (File.join $curdir, "scr.sh")
  return y[:scr]
end

def add_source(fname, h)
  puts "[internals]: adding source #{h[:name]} with config #{fname}"
  y = YAML.load File.read fname
  y[:sources] = {} unless y[:sources]
  abort "[error]: source file already exists" if y[:sources].include? h[:name]
  $sources << (Source.new h)
  name = h[:name]
  h.delete :name
  y[:sources][name] = h   
  File.write fname, y.to_yaml 
end

def rename(fname, old, new)
  y = YAML.load File.read fname
  abort "[error]: no such file here"            unless File.exists? File.join $curdir, fname
  abort "[error]: no such sourcefile in config" unless y[:sources][old]
  puts "[internals]: renaming source #{old} to #{new}"
  File.rename (File.join $curdir, old), (File.join $curdir, new)
  h = y[:sources][old]
  y[:sources][new] = h
  y[:sources].delete old
  File.write fname, y.to_yaml
end

def add(fname, name, *args)
  deps = args
  y = YAML.load File.read fname
  abort "[error]: no sourcefile with name #{name}" unless y[:sources][name].nil?
  h = y[:sources][name]
  h[:name] = name
  s = Source.new h
  s.add_deps deps
  s.flush_deps(s.f.read)
  h[:deps].merge! deps
  h.delete :name
  y[:sources][name] = h
  File.write fname, y.to_yaml
end

#binding.irb
