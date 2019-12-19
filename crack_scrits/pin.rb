#!/usr/bin/env ruby


chars = ('0'..'9').to_a + ('A'..'Z').to_a + ('a'..'z').to_a + ['_']
pass = "." * 30
found = "packers_and_vms_and_xors_oh_m"
pass = found + "."*(30-found.length)
(found.length..30).each do |i|
  puts "pass: #{pass}"
  cnts = {}
  puts "i: #{i}"
  str = pass.chomp
  c = "="
  str[i] = c
  puts `echo #{str} | pin -t inscount0.so -- ./baleful; cat inscount.out`
  (File.read "inscount.out") =~ /Count ([0-9]+)/
  std_cnt = $1.to_i
  str = pass.chomp
  chars.shuffle.each do |c|
    c = c.chr
    str[i] = c
    puts "str: #{str}"
    puts `echo #{str} | pin -t inscount0.so -- ./baleful; cat inscount.out`
    (File.read "inscount.out") =~ /Count ([0-9]+)/
    cnt = $1.to_i
    if cnt != std_cnt
      pass[i] = c
      break
    end
  end
#  puts cnts
#  cnts.each do |n, el|
#    if el.length == 1
#      puts "ok"
#      pass[i] = el.first
#      break
#    end
#  end
end
