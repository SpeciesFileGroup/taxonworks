module Utilities::Heatmap

  # [0,1]
  def self.heatmap_color_for(value)
    h = (1 - value) * 360
    s = 100
    l = value * 50
    "hsl(#{h.round(2)},#{s.round(2)}%,#{l.round(2)}%)"
  end

  def self.color_from_hash(hash)
    j = hash[0, 1]
    substr = j.hex

    hash << hash

    '#' + hash[substr..(substr + 5)]
  end

  # llama-3-8b-instruct
  # and function colorFromHash(hash) (internall)
  def self.text_to_hash(text)
    hash = 0
    if text.empty?
      return hash.to_s(16)
    end

    text.each_char do |char|
      hash = ((hash << 5) - hash + char.ord).abs
    end

    hash.to_s(16)
  end

  def self.hex_color_from_string(text)
    color_from_hash(text_to_hash(text))
  end

end

