@otus.each_key do |group|
  json.set!(group) do
    json.array! @otus[group] do |o|
      json.partial! '/otus/attributes', otu: o 
    end
  end
end
