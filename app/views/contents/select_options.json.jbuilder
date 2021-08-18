@contents.each_key do |group|
  json.set!(group) do
    json.array! @contents[group] do |c|
      json.partial! '/contents/attributes', content: c
    end
  end
end
