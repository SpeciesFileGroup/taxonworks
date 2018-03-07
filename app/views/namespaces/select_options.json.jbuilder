@namespaces.each_key do |group|
  json.set!(group) do
    json.array! @namespaces[group] do |n|
      json.partial! '/namespaces/attributes', namespace: n
    end
  end
end
