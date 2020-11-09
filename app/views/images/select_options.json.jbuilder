@images.each_key do |group|
  json.set!(group) do
    json.array! @images[group] do |o|
      json.partial! '/images/attributes', image: o 
    end
  end
end
