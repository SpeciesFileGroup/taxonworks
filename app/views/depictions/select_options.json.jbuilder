@depictions.each_key do |group|
  json.set!(group) do
    json.array! @depictions[group] do |d|
      json.partial! '/depictions/attributes', depiction: d
    end
  end
end
