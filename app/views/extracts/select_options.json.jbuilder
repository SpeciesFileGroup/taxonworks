@extracts.each_key do |group|
  json.set!(group) do
    json.array! @extracts[group] do |k|
      json.partial! '/extracts/attributes', extract: k
    end
  end
end
