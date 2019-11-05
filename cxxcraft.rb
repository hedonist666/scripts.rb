require 'fileutils'
require 'yaml'
require 'thor'
require 'git'
require 'gist'


class F < File; end


def to_this_dir(fn)
  File.join(File.dirname(__FILE__), fn)
end


def add_deps(data, libs = {})
  libs.each do |libname, source|
    if source == :stdlib
      data << "#include <#{libname.to_s}>\n"   
    else
      if Dir.new("#{homedir}/cache").include? source       
        data << "#include <#{homedir}/cache/#{source}>\n"
      elif source.include? "github.com"
        abort "not yet implemented"
      end
    end
  end
  return data
end

def create_default_scr

commands = %{
#!/bin/bash
g++ $1 -g -fconcepts && ./a.out
}[1..]

create_scr commands

end

def create_scr(commands)
  if File.exists? to_this_dir "scr.sh"
    File.write "scr.sh", commands
  else
    f = File.open "scr.sh", "w"
    f.write commands
    `chmod +x scr.sh` #TODO with f.cmod
    f.close
  end
end

def create_git
  
end



def init_dirs
  tests = Dir.mkdir to_this_dir "tests"
  deps  = Dir.mkdir to_this_dir "deps"
  res   = Dir.mkdir to_this_dir "res"
  return tests, deps, res
end


class Cxxraft < Thor
  
  desc "start NAME", "start new proj"
  def start(name)
    if    
  end

end


binding.irb



#add_deps :iostream => :stdlib, :vector => :stdlib, 
