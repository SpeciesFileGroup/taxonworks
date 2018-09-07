@taxon_names.each_key do |group|
  json.set!(group) do
    json.array! @taxon_names[group] do |n|
      json.partial! '/taxon_names/attributes', taxon_name: n
    end
  end
end
