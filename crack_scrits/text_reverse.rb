#!/usr/bin/env ruby

require 'r2pipe'

MAX_FS = 0x1ffff
#END_ADDR = 0x003ec2bf
#$start_addr = 0x00000ad8
$start_addr = 0x00401521
END_ADDR = 0x00409233



$r2 = R2Pipe.new 'file'
$r2.cmd 'aa'
$r2.cmd "s #{$start_addr}"


res = $r2.cmdj 'pdj'
$ecx = 0
$buf = []
$tmp = 0

def f(s)
  if s["opcode"] =~ /mov\s+.*\[.*\],\s*([0-9a-z]+)/
    $tmp = $1.to_i 16
    puts "1if: tmp: #{$tmp}, opcode: #{s["opcode"]}"
  elsif s["opcode"] =~ /xor\s+(rax|eax|al),\s*([0-9a-z]+)/
    $tmp ^= $2.to_i 16
    puts "2if: tmp: #{$tmp}"
  #elsif s["bytes"] == "740a"
  elsif s["bytes"] == "740b"
    puts "finished one damn cycle"
    $buf << $tmp.chr
    $start_addr = s["offset"]
    puts "ecx: #{$ecx}"
    puts "tmp: #{$tmp}"
    $tmp = nil;
  end
end

def mov_0x(s)
 puts "mov_0x called with #{s["opcode"]}"
  if s["opcode"] =~ /mov\s+.*\[.*\],\s*([0-9a-z]+)/
    $tmp = $1.to_i 16
    def f(s)
      xor_0x(s)
    end
  end
end

def xor_0x(s)
  puts "xor_0x called with #{s["opcode"]}"
  if s["opcode"] =~ /xor\s+(rax|eax|al),\s*([0-9a-z]+)/
    $tmp ^= $2.to_i 16
    $buf << $tmp.chr
    def f(s)
      call_bad(s)
    end
  end
end

def call_bad(s)
  puts "call_bad called with #{s["opcode"]}, #{s["bytes"]}"
  if s["opcode"] =~ /call 0x8f0/
    puts "finished one damn cycle"
    $start_addr = s["offset"]
    puts "ecx: #{$ecx}"
    puts "tmp: #{$tmp}"
    def f(s)
      mov_0x(s)
    end
  end
end

binding.irb

while $start_addr != END_ADDR

  res.each do |e|
    f e
    $ecx += 1
  end

  $r2.cmd "s #{$start_addr}"
  $r2.cmd "so"
  $start_addr = $r2.cmd("s").to_i 16
  puts "now at 0x#{$start_addr.to_s 16}"
  res = $r2.cmdj "pdj @ #{$start_addr}"

end


puts $buf.join
$r2.quit


binding.irb
