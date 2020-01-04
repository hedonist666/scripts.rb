class Source
  
  attr_accessor :f

  def initialize(h)
    @name = h[:name] 
    @includes = ''
    add_deps h[:deps]
    #h[:name] = "#{h[:name]}.cxx" unless h[:name] =~ /.*\.cxx/
    fpath = File.join $curdir, h[:name]
    unless File.exists? fpath
      puts "[internals]: creating file #{h[:name]}.."
      @f = File.new fpath, 'w'
      sample = File.read (File.join HOMEDIR, "samples", h[:sample])
      flush_deps sample
    else
      puts "[internals]: file #{h[:name]} already exists, opened for reading.."
      @f = File.open fpath
    end

  end

  def flush_deps(txt)
    @content = ""
    _inc = ("\n"*0) + @includes + ("\n"*3)
    txt.lines.each do |line|
      if line.include? "#"
        @content << line
      else
        @content << _inc
        _inc = ""
        @content << line
      end
    end

    @f.write @content
  end

  def add_deps(h)
    puts "[internals]: adding #{h.length} dependencies to file #{@name}"
    h.each do |lib, src|
      case src
      when "stdlib"
        @includes << "#include <#{lib}>\n"
      when  "mixin"
        @includes << (File.read (File.join HOMEDIR, "mixins", lib))
      when "local"
        deps_dir = File.join $curdir, "libs"
        header_file = Dir.new(File.join HOMEDIR, lib).children.first

        FileUtils.mkdir deps_dir unless File.exists? deps_dir

        unless File.exists? File.join deps_dir, header_file
          FileUtils.copy (File.join HOMEDIR, lib, header_file), (File.join deps_dir, header_file)
        end

        @includes << "#include \"libs/#{header_file}\"\n" 
      else abort "[error]: unknown deps"
      end
    end
  end

end
