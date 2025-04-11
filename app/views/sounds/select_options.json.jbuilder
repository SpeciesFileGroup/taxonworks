@sounds.each_key do |group|
  json.set!(group) do
    json.array! @sounds[group] do |o|
      json.partial! '/sounds/attributes', sound: o 
    end
  end
end
