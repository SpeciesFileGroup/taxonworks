module Utilities::Heatmap

  # [0,1]
  def self.heatmap_color_for(value)
    h = (1 - value) * 360
    s = 100
    l = value * 50
    "hsl(#{h.round(2)},#{s.round(2)}%,#{l.round(2)}%)"
  end

end

