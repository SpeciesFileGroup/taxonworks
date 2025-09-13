@field_occurrences.each_key do |group|
  json.set!(group) do
    json.array! @field_occurrences[group] do |o|
      json.partial! '/field_occurrences/attributes', field_occurrence: o
      json.object_tag field_occurrence_tag(o)
    end
  end
end
