@sources.each_key do |group|
  json.set!(group) do
    json.array! @sources[group] do |s|
      json.partial! '/sources/attributes', source: s
    end
  end
end
