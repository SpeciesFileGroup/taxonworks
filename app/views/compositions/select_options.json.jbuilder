@compositions.each_key do |group|
  json.set!(group) do
    json.array! @compositions[group] do |c|
      json.partial! '/compositions/attributes', composition: c
    end
  end
end
