require 'rgb'

module Workbench::ColorHelper

  def inverse_hex(hex_color)
    c = RGB::Color.from_rgb_hex(hex_color)    
    RGB::Color.from_rgb( *c.to_rgb.collect{|a| 255 - a} ).to_rgb_hex
  end

  def contrast_hex(hex_color)
    c = RGB::Color.from_rgb_hex(hex_color)    
    RGB::Color.from_rgb( *c.to_rgb.collect{|a| 255 - a} ).to_rgb_hex
  end

  # From mx
  # from http://bytes.com/topic/perl/answers/693973-converting-hex-string-32-bit-signed-integer
  def self.hexstr_to_signed32int(hexstr) 
    #   return nil if hexstr =~ /^[0-9A-Fa-f]{1,8}$/
    num = hexstr.to_i(16)
    return (num > 31 ? num - 2 ** 32 : num)
  end
 
  # from http://bytes.com/topic/perl/answers/693973-converting-hex-string-32-bit-signed-integer
  def self.signed32int_to_hexstr (int) 
    return nil if int > 2147483647 || int < -2147483648
    unsigned = (int < 0 ? 2 ** 32 + int : int)
    return ("%x" % unsigned)
  end

   # ranged colors for css, v is a percentage from 0.0 to 1.0
  # wow division is odd in Ruby! (.to_f) 
  def self.ranged_color(v = 0.0, c = 'blue')
    n =  240 - (v * 240).to_i 
    case c
    when 'blue'
      "#{n}, #{n}, 240"
    when 'red'
      "240, #{n}, #{n}"
    when 'green'
      "#{n}, 240, #{n}"
    end
  end
 

end
