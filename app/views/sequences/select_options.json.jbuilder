@sequences.each_key do |group|
  json.set!(group) do
    json.array! @sequences[group] do |s|
      json.partial! '/sequences/attributes', sequence: s 
    end
  end
end
