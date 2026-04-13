@gazetteers.each_key do |group|
  json.set!(group) do
    json.array! @gazetteers[group] do |k|
      json.partial! '/gazetteers/attributes', gazetteer: k
    end
  end
end
