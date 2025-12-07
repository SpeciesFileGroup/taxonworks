@anatomical_parts.each_key do |group|
  json.set!(group) do
    json.array! @anatomical_parts[group] do |ap|
      json.partial! '/anatomical_parts/attributes', anatomical_part: ap
    end
  end
end
