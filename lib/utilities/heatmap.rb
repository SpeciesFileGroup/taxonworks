module Utilities::Heatmap
  #
  # Written with CLAUDE code
  #
  # Curve types for different emphasis patterns
  CURVES = {
    # Linear curve - equal emphasis across range
    linear: ->(x) { x },

    # Logarithmic curve - emphasizes higher values more
    # Good for data where high values should stand out
    logarithmic: ->(x) {
      return 0 if x <= 0
      Math.log(1 + x * 99) / Math.log(100)
    },

    # Citation emphasis curve - designed for citation counts
    # No color for 1, strong differentiation at low end (2-10), moderate at high end
    citation_count: ->(x, count: nil) {
      return 0 if x <= 0

      # If actual count is provided and it's 1, return 0 (no color)
      return 0 if count && count <= 1

      # Use a power curve with very strong differentiation at low end
      # Optimized for max values around 50-200
      if x < 0.0125    # ~2 records when max is 160
        0.15           # Start with visible color for 2
      elsif x < 0.019  # ~3 records
        0.15 + (x - 0.0125) * 15.0
      elsif x < 0.025  # ~4 records
        0.25 + (x - 0.019) * 12.0
      elsif x < 0.0375 # ~5-6 records
        0.32 + (x - 0.025) * 8.0
      elsif x < 0.0625 # ~7-10 records
        0.42 + (x - 0.0375) * 4.0
      elsif x < 0.125  # ~11-20 records
        0.52 + (x - 0.0625) * 2.0
      elsif x < 0.31   # ~21-50 records
        0.645 + (x - 0.125) * 1.0
      elsif x < 1.0    # ~51+ records
        0.83 + (x - 0.31) * 0.5
      else
        0.975 + (x - 1.0) * 0.025  # Extreme emphasis above max
      end
    },

    # Exponential curve - emphasizes higher values extremely
    exponential: ->(x) {
      (Math.exp(x * 2) - 1) / (Math.exp(2) - 1)
    },

    # Square root curve - de-emphasizes very high values
    sqrt: ->(x) {
      Math.sqrt(x)
    }
  }.freeze

  # [0,1]
  # @param value [Float] normalized value between 0 and 1
  # @param curve [Symbol, Proc] curve type from CURVES or custom proc
  # @return [String] HSL color string
  def self.heatmap_color_for(value, curve: :linear, count: nil)
    curve_fn = curve.is_a?(Proc) ? curve : CURVES[curve] || CURVES[:linear]

    # Apply the curve transformation, passing count if the curve accepts it
    transformed_value = if curve == :citation_count && count
      curve_fn.call(value, count: count)
    else
      curve_fn.call(value)
    end

    # Clamp between 0 and 1
    transformed_value = [[transformed_value, 0].max, 1].min

    # Map to hue (red=0, yellow=60, green=120, cyan=180, blue=240)
    # We want: low values = blue/cyan (cool), high values = red/orange (hot)
    # So we reverse: 1 - transformed_value
    h = (1 - transformed_value) * 240  # 240=blue to 0=red
    s = 100
    l = 30 + (transformed_value * 30)  # Vary lightness from 30% to 60%

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
