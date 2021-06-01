json.array!(@people) do |person|
 json.partial! '/people/api/v1/attributes', person: person
end
