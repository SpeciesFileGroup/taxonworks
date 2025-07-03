@observations.each_key do |group|
  json.set!(group) do
    json.array! @observations[group] do |o|
      json.partial! '/observations/attributes', observation: o
    end
  end
end
