@biological_relationships.each_key do |group|
  json.set!(group) do
    json.array! @biological_relationships[group] do |b|
      json.partial! '/biological_relationships/attributes', biological_relationship: b
    end
  end
end
