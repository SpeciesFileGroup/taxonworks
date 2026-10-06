@preparation_types.each_key do |group|
  json.set!(group) do
    json.array! @preparation_types[group] do |n|
      json.partial! '/preparation_types/attributes', preparation_type: n
    end
  end
end
