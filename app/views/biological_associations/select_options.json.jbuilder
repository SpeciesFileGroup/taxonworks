@biological_associations.each_key do |group|
  json.set!(group) do
    json.array! @biological_associations[group] do |b|
      json.partial! '/biological_associations/attributes', biological_association: b
    end
  end
end
