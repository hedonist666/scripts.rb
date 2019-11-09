class Source
  
  def initialize(h)
    @name = h[:name] 
    add_deps h[:deps]
    h[:name] = "#{h[:name]}.cxx" unless h[:name] =~ /.*\.cxx/
    fpath = File.join $curdir, h[:name]
    unless File.exists? fpath
      @f = File.new fpath, "w"
      @f.write @includes
      h[:sample] ||= "default"
      @f.write File.read (File.join HOMEDIR, "samples", h[:sample])
    else
      @f = File.open fpath, "r"
    end

  end
  def add_deps(h)
    @includes = ''
    h.each do |lib, src|
      case src
      when "stdlib"
        @includes << "#include <#{lib}>\n"
      when  "mixin"
        @includes << (File.read (File.join HOMEDIR, "mixins", lib))
      when "local"
        @includes << "#include \"#{Dir["*/**/#{lib}"].first}\"\n"
      else abort "unknown deps"
      end
    end
  end
end
