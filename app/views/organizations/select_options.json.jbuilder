@organizations.each_key do |group|
  json.set!(group) do
    json.array! @organizations[group] do |o|
      json.partial! '/organization/attributes', organization: o
    end
  end
end
