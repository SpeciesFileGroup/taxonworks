@people.each_key do |group|
  json.set!(group) do
    json.array! @people[group] do |p|
      json.partial! '/people/base_attributes', person: p
    end
  end
end
