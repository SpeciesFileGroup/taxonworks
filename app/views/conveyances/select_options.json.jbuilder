@conveyances.each_key do |group|
  json.set!(group) do
    json.array! @conveyances[group] do |c|
      json.partial! '/conveyances/attributes', conveyance: c
    end
  end
end
