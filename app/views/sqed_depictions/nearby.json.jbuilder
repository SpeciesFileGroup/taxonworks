
nearby = @sqed_depiction.nearby_sqed_depictions(params[:before] || 3, params[:after] || 3)

json.current do
  json.partial! '/depictions/attributes', depiction: @sqed_depiction.depiction 
end

json.before(nearby[:before].reverse) do |d|
  json.partial! '/depictions/attributes', depiction: d.depiction
end

json.after(nearby[:after]) do |d|
  json.partial! '/depictions/attributes', depiction: d.depiction
end


