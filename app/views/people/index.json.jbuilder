json.array!(@people) do |person|
 json.partial! '/people/attributes', person: person
end
