@documents.each_key do |group|
  json.set!(group) do
    json.array! @documents[group] do |o|
      json.partial! '/documents/attributes', document: o
    end
  end
end
