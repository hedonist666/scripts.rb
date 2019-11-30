#!/usr/bin/env ruby



require 'r2pipe'
require 'json'


$r2 = R2Pipe.new ARGV[0], '-w'
$entry = 0x00400080


puts $r2.cmd 'aaa'

def cycle(start_addr)
  puts "start_addr: #{start_addr.to_s 16}"
  puts $r2.cmd "s #{start_addr}"

  res = $r2.cmdj 'pdj'

  address_to_unpack = 0
  len_to_unpack = 0
  len_i = 0

  res.each_with_index do |ins, i|
    opc = ins["opcode"]
    if opc =~ /call\s+(.*)/
      address_to_unpack = $1.to_i 16
      puts "updated address_to_unpack: #{address_to_unpack.to_s 16}"
    end
    if opc =~ /add\s+[er]bx,\s+(.*)/
      address_to_unpack += $1.to_i 16
      puts "updated address_to_unpack twice: #{address_to_unpack.to_s 16}"
    end
    if opc =~ /mov\s+[er]cx,\s+(.*)/
      len_to_unpack = $1.to_i 16
      len_i = i
      break
    end
  end


  instrs = []
  res[len_i+2..].each do |ins|
    break if ins["opcode"].include? "m"
    instrs << ins["opcode"]
  end


  instrs.map! do |str|
    oper = str.split(" ")[0]
    unless oper =~ /not/
      int = str.split(",")[1]
      int = int[1..].to_i 16
    else
      int = -1
    end
    [oper, int]
  end

  puts "address to unpack: #{address_to_unpack.to_s 16}"
  puts "len to unpack: #{len_to_unpack.to_s 16}"
  puts "instructions:"
  instrs.each do |i|
    puts "#{i[0]} => #{i[1].to_s 16}"
  end


  def dword_sub(a, b)
    return 0     if a == b
    return a - b if a > b
    0xffffffff - (b - a - 1)   
  end

  def dword_add(a, b)
    (a + b) % 0x100000000 
  end

  def dword_not(a)
    i = 0
    res = 0
    str = ("0"*(32 - a.to_s(2).length) + a.to_s(2))
    str.reverse.each_char do |b|
      b = if b == "0"
            1
          else
            0
          end
      res += b << i
      i += 1
    end
    return res
  end


  patchmem = lambda do
    addr = address_to_unpack
    len_to_unpack.times do 
      arr = []
      bytes = $r2.cmd("p8 4 @ #{addr}")
      bytes.chars.each_slice(2) do |a,b|
        break if a.nil? or b.nil?
        arr << a+b
      end
      edx = arr.reverse.join('').to_i 16
#      puts "edx before: #{edx.to_s 16}"
      instrs.each do |com|
        case com[0]
        when "sub"
          edx = dword_sub(edx, com[1])
        when "add"
          edx = dword_add(edx, com[1])
        when "xor"
          edx ^= com[1]
        when "not"
          edx = dword_not edx
        else
          abort "patchmem"
        end
      end
      arr = []
      bytes = ("0"*(8 - edx.to_s(16).length) + edx.to_s(16))
      bytes.chars.each_slice(2).each do |a,b|
        arr << a+b
      end
      edx = arr.reverse.join
      $r2.cmd "wx #{edx}@ #{addr}"
#      puts "edx after: #{edx}"
      addr += 4
    end
  end


  put_instrs = lambda do
    res = $r2.cmdj 'pdj'
    i = 0
    res.each_with_index do |ins, _i|
      if ins["offset"] == address_to_unpack
        i = _i
        break
      end
    end
    res[i..].each do |ins|
      puts "#{ins["offset"]}: #{ins["opcode"]}"
    end
    return "end"
  end

  puts "patching memory..."
  patchmem.call

  res = $r2.cmdj 'pdj'
  return res, address_to_unpack
end

  
res, atu = cycle $entry
instr = nil
res.each do |com|
  if com["offset"] == atu
    instr = com["bytes"]
    break
  end
end

addr = atu


binding.irb

while instr == "e800000000"
  res, atu = cycle addr
  res.each do |com|
    if com["offset"] == atu
      instr = com["bytes"]
      break
    end
  end
  addr = atu
end


puts "finish addr: #{addr}" # 0x004019a6

binding.irb

$r2.quit

#here goes some code analysis

puts "getting the password...."

a=0x98dd8c8f;  b=0xcafebabe

def to_bytes(x)
  res = []
  x.to_s(16).chars.each_slice(2) do |q,w| res<<q+w end
  return res
end

a = to_bytes a
a.map! do |w| w.to_i 16 end
b = to_bytes b
b.map! do |w| w.to_i 16 end
a.zip b
#a = [[152, 202], [221, 254], [140, 186], [143, 190]]
a.map! do |q| q[0]^q[1] end
a.map! do |q| q.chr end
puts a.reverse.join

#HY7MKB20T7CGVESK36M5TD8A4FAD523=
