@serials.each_key do |group|
  json.set!(group) do
    json.array! @serials[group] do |l|
      json.partial! '/serials/attributes', serial: l
    end
  end
end
