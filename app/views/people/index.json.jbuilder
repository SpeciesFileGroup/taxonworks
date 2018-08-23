json.array!(@people) do |person|
 json.partial! 'attributes', person: person
end
