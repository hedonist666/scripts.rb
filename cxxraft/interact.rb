require_relative './engine.rb'
require 'thor'

$prompt = ">>>"

def gets
  print $prompt
  STDIN.gets
end

class Cxxraft < Thor
  desc "start", "start new proj"
  method_options :silent => :boolean
  def start(name = "")
    unless name.empty?
      Dir.mkdir name
      $curdir = name
    end
    unless @config = find_config
      @config = File.join $curdir, "cxxraft.yml"
      if options.silent?
        puts "silent mode, using default config"
        FileUtils.copy_file (File.join HOMEDIR, "default.yml"), @config
      else
        y = {}
        puts "hi, to proceed you should answer to few questions"
        puts "which scr.sh you want to use? (enter to default.sh)"
        y[:scr] = unless (a = gets.chomp).empty?
                    a
                  else
                    "default.sh"
                  end
        abort "dunno what're u talking 'bout" unless File.exists? (File.join HOMEDIR,
                                                                   "scrs", y[:scr])
        puts "how mane source files? (enter to 1)"
        i = unless (a = gets.chomp).empty?
              a.to_i
            else
              1
            end
        abort "code without files?" unless i > 0
        y[:sources] = {}
        i.times do 
          puts "enter name:"
          abort "I asked one simple qustion" if (name = gets.chomp).empty?
          y[:sources][name]          = {}
          y[:sources][name][:deps]   = {}
          puts "enter sample for #{name} (enter to default)"
          y[:sources][name][:sample] = unless (sample = gets.chomp).empty?
                                         sample
                                       else
                                         "default"
                                       end
          puts "enter deps with format 'lib:source'\\n...\\nend (enter to standart)"
          deps = {}
          input = gets.chomp
          if input.empty?
            deps = {"standart" => "mixin"}
          else
            while not input.include? "end"
              deps[input.split(':')[0]] = input.split(':')[1]
              input = gets.chomp
            end
          end
          y[:sources][name][:deps] = deps

          puts y

          #end of dialog
          File.write @config, y.to_yaml
        end
      end


    end

    load_parse @config

  end

  desc "add", "add source file to proj\n (NAME to do it interactivly ot NAME:TAG)"
  def add(sfn)
    abort "no project here" unless @config = find_config
    name = ""
    tag = {}
    if sfn.include? ':'
      name, tag = sfn.split(':')
      fn = File.join HOMEDIR, "tags", "#{tag}.yml"
      abort "no tagfile with name #{tag}" unless File.exists? fn
      h = YAML.load File.read fn
    else
      puts "enter sample for #{name} (enter to default)"
      h[:sample] = unless (sample = gets.chomp).empty?
                     sample
                   else
                     "default"
                   end
      puts "enter deps with format 'lib:source'\\n...\\nend (enter to standart)"
      deps = {}
      input = gets.chomp
      if input.empty?
        deps = {"standart" => "mixin"}
      else
        while not input.include? "end"
          deps[input.split(':')[0]] = input.split(':')[1]
          input = gets.chomp
        end
      end
      h[:deps] = deps
    end
    h[:name] = name
    add_source(@config, h)
  end
end

def find_config
  opts = ["cxxraft.yml", "Cxxraft.yaml", "cxxraft.yaml", "Cxxraft.yaml"]
  opts.each do |fn|
    return (File.join $curdir, fn) if File.exists? (File.join $curdir, fn)
  end
  return nil
end

#Cxxraft.start
