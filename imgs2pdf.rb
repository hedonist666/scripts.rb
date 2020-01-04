#!/usr/bin/env ruby

require 'prawn'
require 'optparse'


dirname = nil
ofname = nil

OptionParser.new do |opts|
  opts.banner = "Usage: imgs2pdf.rb -d DIRNAME -o OUTFILE"
  opts.on('-d', '--directory DIRNAME', 'source directory for images') {|e| dirname = e}
  opts.on('-o', '--output OFNAME', 'output file name') {|e| ofname = e}
end.parse!


x_sz, y_sz = PDF::Core::PageGeometry::SIZES["LETTER"]

begin 
  Prawn::Document.generate(ofname) do |pdf|
    Dir.open(dirname) do |d|
      d.children.sort.each do |fn| 
        if fn =~ /.*\.(jpg|png)/
          puts "adding #{fn}..."
          y_pos = pdf.cursor + 35
          pdf.image (File.join dirname, fn), :at => [-30,y_pos], :fit => [x_sz, y_sz]
          pdf.start_new_page
        end
      end
    end
    pdf.font 'Times-Roman'
    pdf.font_size 42
    pdf.text 'the end.', :valign => :center, :align => :center
  end
  puts "generated file #{ofname}"
rescue
  puts "somethig went wrong, did you specify correct args?"
end
