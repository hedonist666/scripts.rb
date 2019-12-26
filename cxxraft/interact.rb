require_relative './engine.rb'
require 'thor'

$prompt = ">>>"

def gets
  print $prompt
  STDIN.gets
end

class Cxxraft < Thor
  desc "start NAME", "start new proj"
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
        abort "[error]: dunno what're u talking 'bout" unless File.exists? (File.join HOMEDIR,
                                                                   "scrs", y[:scr])
        puts "how mane source files? (enter to 1)"
        i = unless (a = gets.chomp).empty?
              a.to_i
            else
              1
            end
        abort "[error]: code without files?" unless i >= 0
        y[:sources] = {}
        i.times do 
          puts "enter name:"
          abort "[error]: I asked one simple qustion" if (name = gets.chomp).empty?
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
        end

        File.write @config, y.to_yaml
      end


    end

    load_parse @config

  end

  desc "add SOURCE", "add source file to proj\n (NAME to do it interactivly ot NAME:TAG)"
  def add(sfn)
    abort "[error]: no project here" unless @config = find_config
    name = ""
    tag = {}
    if sfn.include? ':'
      name, tag = sfn.split(':')
      fn = File.join HOMEDIR, "tags", "#{tag}.yml"
      abort "[error]: no tagfile with name #{tag}" unless File.exists? fn
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

  desc "scr SCR.SH", "change scr.sh file, see $ cxxraft.rb list scrs; for samples"
  def scr(fn)
    abort "no proj here" unless @config = find_config    
    path = File.join HOMEDIR, "scrs", fn
    abort "there's no such scr" unless File.exists? path
    puts "switching scr.sh to #{fn}...."
    @y = YAML.load File.read @config
    FileUtils.copy_file path, (File.join $curdir, "scr.sh")
    @y[:scr] = fn
    File.write @config, @y.to_yaml
  end

  desc "list dir", "show what we've got"
  def list(what)
    desc = {}

    path = File.join HOMEDIR, what
    if File.exists? (File.join path, "description.yml")
      desc = YAML.load File.read (File.join path, "description.yml")
    end

    Dir.new(path).children.each_with_index do |e, i|
      next if e == "description.yml"   
      str = "[#{i}]: #{e}"
      str << ", " << desc[e] unless desc[e].nil?
      puts str
    end
  end

  desc "s NAME ACTION", "shortcut for source"
  def s(name, act, *args)
    source(name, act, *args)
  end
  
  desc "source NAME ACTION ...", "action with source file, source HELP ACTION_NAME to see help :)"
  def source(name, act, *args)
    abort "[error]: no proj here" unless @config = find_config
    case act
    when "help"
      puts "commands:"
      puts "  rename"
      puts "  add_deps"
    when "rename"
      unless name == "help"
        rename @config, name, args[0]
      else
        puts "rename NEW_NAME; renames source file"
      end
    when "add"
      unless name == "help"
        add @config, name, args
      else
        puts "add dep1, dep2, ...; add dependencies to sourcefile"
      end
    else
      abort "unknown command"
    end
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
