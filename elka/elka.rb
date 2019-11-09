#!/usr/bin/env ruby
require 'nokogiri'
require 'open-uri'

def binsearch(arr, el)
  l = 0
  r = arr.length
  while l <= r
    m = (l + r) / 2
    if arr[m] < el
      l = m + 1
    elsif arr[m] > el
      r = m - 1
    end 
  end
  m += 1 if arr[m] <= el 
  return m
end


doc = Nokogiri::HTML(open('https://elektrichkoy.net/raspisanie-elektrichek-universitetskaya-universitet--sankt-peterburg-baltiyskiy-vokzal/'))


arr = doc.css('div.departures').css('div.time').map do |el|
  tmp = el.text.split(':').map {|v| v.to_i}
  tmp[0]*100 + tmp[1]
end

date = Time.now.hour*100 + Time.now.min


m = binsearch(arr, date)

puts "the cloces departure is in #{arr[m]/100}:#{arr[m]%100}" 
puts "(Enter to see next, Ctr-c to finich)"

begin
  while a = gets
    m = (m + 1) % arr.length
    puts "#{arr[m]/100}:#{arr[m]%100}"
    puts "(Enter to see next, Ctr-c to finich)"
  end
rescue SystemExit,Interrupt
  exit
end
